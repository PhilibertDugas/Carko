//
//  ReservationCollectionViewCell.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-05.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import MapKit

class ReservationCollectionViewCell: UICollectionViewCell, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var label: UILabel!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dayOfWeekLabel: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var calendarView: RoundedCornerView!

    var gradient: CAGradientLayer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyGradient()
        layer.cornerRadius = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyGradient()
        layer.cornerRadius = 10
    }

    fileprivate func applyGradient() {
        gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.accentGradientColor.cgColor, UIColor.accentColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.cornerRadius = 10
        self.layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
    }

    var reservation: Reservation? {
        didSet {
            if let reservation = reservation {
                let event = reservation.event
                label.text = event?.label ?? Translations.t("Event")
                monthLabel.text = DateHelper.getMonth(reservation.startTime)
                dayLabel.text = String(DateHelper.getDay(reservation.startTime))
                dayOfWeekLabel.text = DateHelper.getDayOfWeek(reservation.startTime)

                self.setEventImage(event)
                self.setMapRegion(reservation)
                self.setMapPin(reservation)
            }
        }
    }

    fileprivate func setEventImage(_ event: Event?) {
        if let url = event?.photoURL {
            ImageLoaderHelper.loadImageFromUrl(eventImageView, url: url)
        }
    }

    fileprivate func setMapRegion(_ reservation: Reservation) {
        self.mapView.layer.cornerRadius = 10
        guard let center = reservation.parking?.coordinate() else { return }
        let range = CLLocationDistance.init(reservation.event?.range ?? 500)
        let region = MKCoordinateRegionMakeWithDistance(center, range, range)
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
        self.mapView.delegate = self
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tappedMap))
        self.mapView.addGestureRecognizer(tapGesture)
    }

    func tappedMap() {
        guard let parking = self.reservation?.parking else { return }
        let region = MKCoordinateRegionMakeWithDistance(parking.coordinate(), 500, 500)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue.init(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue.init(mkCoordinateSpan: region.span)
        ]
        let placemark = MKPlacemark.init(coordinate: parking.coordinate())
        let mapItem = MKMapItem.init(placemark: placemark)
        mapItem.name = parking.address
        mapItem.openInMaps(launchOptions: options)
    }

    fileprivate func setMapPin(_ reservation: Reservation) {
        guard let parking = reservation.parking else { return }
        let centerAnnotation = MKPointAnnotation.init()
        centerAnnotation.coordinate = parking.coordinate()
        self.mapView.addAnnotation(centerAnnotation)

        let annotation = ParkingAnnotation.init(parking: parking, event: reservation.event)
        self.mapView.addAnnotation(annotation)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingAnnotation {
            let annotationView = ParkingAnnotationView.init(annotation: annotation, reuseIdentifier: nil)
            return annotationView
        }
        return nil
    }
}
