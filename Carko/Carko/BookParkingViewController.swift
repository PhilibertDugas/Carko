//
//  BookParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-20.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe
import FirebaseStorageUI
import FirebaseAuthUI
import FirebaseAuth
import FirebaseFacebookAuthUI
import FBSDKCoreKit
import UserNotifications

protocol ReservationDelegate {
    func reservationCompleted()
}

protocol MapSheetDelegate {
    func didAppear()
    func didDisappear()
}

class BookParkingViewController: UIViewController {
    @IBOutlet var confirmButton: SmallRoundedCornerButton!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var parkingLabel: UILabel!
    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var paymentPopup: PaymentPopup!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var parkingInfoView: UIView!
    @IBOutlet var mainButtonWidth: NSLayoutConstraint!
    @IBOutlet var mainButtonLabel: UILabel!

    let photoCellIdentifier = "PhotoCell"

    var paymentContext: STPPaymentContext!
    var parking: Parking!
    var event: Event!
    var delegate: ReservationDelegate!
    var sheetDelegate: MapSheetDelegate!
    var bluredView: UIVisualEffectView!

    let fullView: CGFloat = 10
    var partialView: CGFloat {
        return 0.75 * UIScreen.main.bounds.height
    }
    var minimalView: CGFloat {
        return UIScreen.main.bounds.height - confirmButton.frame.maxY - 40
    }

    @IBAction func tappedConfirm(_ sender: Any) {
        if AuthenticationHelper.customerAvailable() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
                (granted, error) in
                if let error = error {
                    super.displayErrorMessage(error.localizedDescription)
                } else if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            self.handleConfirmTapped()
        } else {
            let authController = AuthenticationHelper.shared.getAuthController()
            self.present(authController, animated: true, completion: nil)
        }
    }

    private func handleConfirmTapped() {
        let bookingManager = BookingManager.init(parking: self.parking, paymentContext: self.paymentContext, event: self.event)
        if let error = bookingManager.bookingHasAnyErrors() {
            switch error {
            case .ownParking:
                super.displayErrorMessage(Translations.t("The parking is your own. You can't rent your own parking"))
                break
            case .noPaymentMethod:
                let controller = bookingManager.getAlertController(title: Translations.t("Missing payment method"), message: Translations.t("Please select a payment method"), okHandler: { (_) in
                    self.paymentContext.presentPaymentMethodsViewController()
                })
                self.present(controller, animated: true, completion: nil)
                break
            case .noVehicule:
                let controller = bookingManager.getAlertController(title: Translations.t("Missing vehicule"), message: Translations.t("Please set your vehicule information in the profile section"), okHandler: { (_) in
                    self.performSegue(withIdentifier: "showVehicule", sender: nil)
                })
                self.present(controller, animated: true, completion: nil)
                break
            case .reservationConflict:
                let controller = bookingManager.getAlertController(title: Translations.t("Reservation conflict"), message: Translations.t("There is already a reservation scheduled on this date, do you wish to continue?"), okHandler: { (_) in
                    self.promptCompletion()
                })
                controller.addAction(UIAlertAction.init(title: Translations.t("Cancel"), style: .cancel , handler: nil))
                self.present(controller, animated: true, completion: nil)
                break
            }
        } else {
            self.promptCompletion()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.paymentPopup.isHidden = true
        self.photoCollectionView.delegate = self
        self.photoCollectionView.backgroundColor = UIColor.clear

        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BookParkingViewController.panGesture))
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(BookParkingViewController.tapGesture))
        view.addGestureRecognizer(gesture)
        view.addGestureRecognizer(tapGesture)

        self.roundViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareBackgroundView()

        self.paymentPopup.indicator.isHidden = true

        addressLabel.text = parking.address
        timeLabel.text = Translations.t("Midnight") + ", \(DateHelper.getDay(self.event.startTime)) \(DateHelper.getMonth(self.event.startTime))"
        costLabel.text = self.event.price.asLocaleCurrency
        parkingLabel.text = self.parking.pDescription

        // sizeToFit() to make sure the label is vertically aligned at the top of the view instead of in the center
        parkingLabel.sizeToFit()
        eventLabel.text = self.event.label
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if AuthenticationHelper.customerAvailable() {
            // FIXME CHANGE THIS
            self.paymentContext = STPPaymentContext.init(apiAdapter: APIClient.shared)
            self.paymentContext.paymentCurrency = "CAD"
            self.paymentContext.delegate = self
            self.paymentContext.hostViewController = self
        }
        animateToPartial()
        setButtonState()
    }

    private func setButtonState() {
        if self.parking.isAvailable {
            self.confirmButton.alpha = 1.0
            self.confirmButton.isEnabled = true
            self.parkingInfoView.isHidden = false
            updateConstraint(multiplier: 0.38)
            self.mainButtonLabel.text = Translations.t("Reserve Now")
        } else {
            self.confirmButton.alpha = 0.6
            self.confirmButton.isEnabled = false
            self.parkingInfoView.isHidden = true
            updateConstraint(multiplier: 0.9)
            self.mainButtonLabel.text = Translations.t("This parking is currently busy")
        }
    }

    private func updateConstraint(multiplier: CGFloat) {
        let newConstraint = self.mainButtonWidth.constraintWithMultiplier(multiplier)
        self.view.removeConstraint(self.mainButtonWidth)
        self.view.addConstraint(newConstraint)
        self.view.layoutIfNeeded()
    }

    fileprivate func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let vibrancyEffect = UIVibrancyEffect.init(blurEffect: UIBlurEffect.init(style: .light))
        let visualEffect = UIVisualEffectView.init(effect: vibrancyEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }

    func tapGesture(_ recognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
            let currentOrigin = self.view.frame.origin.y
            if currentOrigin == self.fullView {
                self.sheetDisappeared()
            } else if currentOrigin == self.partialView {
                self.sheetAppeared()
            } else {
                self.sheetPartialView()
            }
        }, completion: nil)
    }

    func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= minimalView ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }

        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
                let currentOrigin = self.view.frame.origin.y
                if velocity.y > 0 {
                    if currentOrigin > self.partialView {
                        self.sheetMinimalView()
                    } else {
                        self.sheetDisappeared()
                    }
                } else if velocity.y < 0 {
                    if currentOrigin > self.partialView {
                        self.sheetPartialView()
                    } else {
                        self.sheetAppeared()
                    }
                } else {
                    if self.view.frame.origin.y < (self.view.frame.height / 2) {
                        self.sheetAppeared()
                    } else if self.view.frame.origin.y < self.partialView {
                        self.sheetDisappeared()
                    } else {
                        self.sheetMinimalView()
                    }
                }
            }, completion: nil)
        }
    }

    fileprivate func sheetAppeared() {
        self.view.frame = CGRect(x: 0, y: self.fullView, width: UIScreen.main.bounds.width, height: self.view.frame.height)
        self.sheetDelegate.didAppear()
    }

    fileprivate func sheetDisappeared() {
        self.sheetPartialView()
        self.sheetDelegate.didDisappear()
    }

    fileprivate func animateToPartial() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.sheetDisappeared()
        }, completion: nil)
    }

    func animateToMinimal() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.sheetMinimalView()
        }, completion: nil)

    }

    fileprivate func sheetPartialView() {
        self.view.frame = CGRect(x: 0, y: self.partialView, width: UIScreen.main.bounds.width, height: self.view.frame.height)
    }

    fileprivate func sheetMinimalView() {
        self.view.frame = CGRect(x: 0, y: self.minimalView, width: UIScreen.main.bounds.width, height: self.view.frame.height)
    }

    fileprivate func roundViews() {
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }
}

// MARK -- Handling the payment popup
extension BookParkingViewController {
    func promptCompletion() {
        self.didPressPark()
        self.paymentPopup.priceLabel.text = self.event.price.asLocaleCurrency
        self.paymentPopup.creditCardLabel.text = self.paymentContext.selectedPaymentMethod?.label
        self.paymentPopup.creditCardLabel.sizeToFit()
        self.paymentPopup.creditCardImage.image = self.paymentContext.selectedPaymentMethod?.image

        self.paymentPopup.confirmButton.addTarget(self, action: #selector(self.completeBooking), for: UIControlEvents.touchUpInside)
        self.paymentPopup.cancelButton.addTarget(self, action: #selector(self.cancelBooking), for: UIControlEvents.touchUpInside)

        self.paymentPopup.view.backgroundColor = UIColor.primaryBlack
        self.paymentPopup.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.paymentPopup.view.alpha = 0.0
        self.paymentPopup.isHidden = false
        self.paymentPopup.view.center = (self.view.superview?.center)!
        self.view.superview?.insertSubview(self.paymentPopup.view, aboveSubview: self.bluredView)
        UIView.animate(withDuration: 0.25, animations: {
            self.paymentPopup.view.alpha = 1.0
            self.paymentPopup.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    func completeBooking() {
        self.paymentPopup.indicator.isHidden = false
        self.paymentPopup.indicator.startAnimating()
        self.paymentContext.paymentAmount = Int(self.event.price * 100)
        self.paymentContext.requestPayment()
    }

    func cancelBooking() {
        self.didDismissPaymentPopup()
    }

    func didPressPark() {
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        self.view.superview?.insertSubview(self.bluredView, aboveSubview: self.view)
    }

    func didDismissPaymentPopup() {
        self.bluredView.removeFromSuperview()
        UIView.animate(withDuration: 0.25, animations: {
            self.paymentPopup.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.paymentPopup.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if (finished) {
                self.paymentPopup.isHidden = true
            }
        })
    }
}

// MARK -- Handling Stripe methods
extension BookParkingViewController: STPPaymentContextDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        let charge = Charge.init(
            customer: AppState.shared.customer.stripeId,
            amount: paymentContext.paymentAmount,
            currency: paymentContext.paymentCurrency,
            parkingId: parking.id!
        )

        let reservation = NewReservation.init(
            parkingId: parking.id!,
            customerId: AuthenticationHelper.getCustomer().id,
            eventId: event.id,
            isActive: true,
            startTime: self.event.startTime,
            stopTime: self.event.stopTime,
            totalCost: self.event.price,
            charge: charge
        )

        reservation.persist() { (successfulReservation, error) in
            self.paymentPopup.indicator.isHidden = true
            self.paymentPopup.indicator.stopAnimating()
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if successfulReservation != nil {
                self.delegate.reservationCompleted()
                self.sheetDisappeared()
                self.didDismissPaymentPopup()
            }
        }
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.paymentContext = paymentContext
        return
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        return
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        return
    }
}

extension BookParkingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! ParkingPhotoCollectionViewCell
        if indexPath.section == 0 {
            ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: parking.multiplePhotoUrls[0])
        } else {
            if parking.multiplePhotoUrls.count > 1 {
                ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: parking.multiplePhotoUrls[1])
            } else if let url = event.photoURL {
                ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: url)
            }
        }
        cell.layer.cornerRadius = 10
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat!
        if indexPath.section == 0 {
            width = 0.64 * self.photoCollectionView.frame.width
        } else {
            width = 0.32 * self.photoCollectionView.frame.width
        }
        let height = self.photoCollectionView.frame.height
        return CGSize.init(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 4.0, bottom: 0, right: 4.0)
    }
}
