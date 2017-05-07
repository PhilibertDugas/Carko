import UIKit
import Foundation

protocol ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: AvailabilityInfo)
}

class AvailabilityViewController: UIViewController {
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var mainButton: RoundedCornerButton!

    var delegate: ParkingAvailabilityDelegate?

    var availability: AvailabilityInfo!
    var dateFormatter: DateFormatter!
    var parking: Parking!
    var newParking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if !newParking {
            mainButton.setTitle("SAVE", for: UIControlState.normal)
        }

        availability = parking.availabilityInfo
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAvailability()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushPhoto" {
            let vc = segue.destination as! NewPhotoViewController
            vc.parking = parking
        }
    }

    @IBAction func mainButtonTapped(_ sender: Any) {
        self.availability.startTime = "00:00"
        self.availability.stopTime = "23:59"
        if newParking {
            self.performSegue(withIdentifier: "pushPhoto", sender: nil)
        } else {
            delegate?.userDidChangeAvailability(value: availability)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func dayToggle(_ sender: UIButton) {
        let dayId = sender.tag
        let newAvailability = !availability.daysAvailable[dayId]
        availability.daysAvailable[dayId] = newAvailability
        updateButton(isOn: newAvailability, button: sender)
        if availability.daysAvailable.contains(true) {
            enableMainButton()
        } else {
            disableMainButton()
        }
    }

    func updateAvailability() {
        let daysAvailable = availability.daysAvailable
        if daysAvailable.contains(true) {
            enableMainButton()
        } else {
            disableMainButton()
        }

        updateButton(isOn: daysAvailable[0], button: mondayButton)

        for index in 1...6 {
            updateButton(isOn: daysAvailable[index], button: findDayButton(tag: index))
        }
    }

    func updateButton(isOn: Bool, button: UIButton!) {
        if isOn {
            button.backgroundColor = UIColor.init(netHex: 0x00C441)
        }
        else {
            button.backgroundColor = UIColor.clear
        }
    }

    private func findDayButton(tag: Int) -> UIButton {
        return self.view.viewWithTag(tag) as! UIButton
    }

    fileprivate func enableMainButton() {
        mainButton.isEnabled = true
        mainButton.alpha = 1.0
    }

    fileprivate func disableMainButton() {
        mainButton.isEnabled = false
        mainButton.alpha = 0.5
    }
}
