import UIKit
import Foundation

protocol ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: AvailabilityInfo)
}

class AvailabilityViewController: UIViewController {
    @IBOutlet var mondayButton: UISwitch!
    @IBOutlet var mainButton: RoundedCornerButton!

    var delegate: ParkingAvailabilityDelegate?

    var availability: AvailabilityInfo!
    var dateFormatter: DateFormatter!
    var parking: Parking!
    var newParking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clipsToBounds = true
        self.availability = parking.availabilityInfo
        self.availability.startTime = "00:00"
        self.availability.stopTime = "23:59"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.newParking {
            self.mainButton.isHidden = false
        } else {
            self.mainButton.isHidden = true
        }
        updateAvailability()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.userDidChangeAvailability(value: availability)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushPhoto" {
            let vc = segue.destination as! NewPhotoViewController
            vc.parking = parking
        }
    }

    @IBAction func mainButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "pushPhoto", sender: nil)
    }

    @IBAction func dayToggle(_ sender: UISwitch) {
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

    func updateButton(isOn: Bool, button: UISwitch!) {
        if isOn {
            button.isOn = true
        }
        else {
            button.isOn = false
        }
    }

    private func findDayButton(tag: Int) -> UISwitch {
        return self.view.viewWithTag(tag) as! UISwitch
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
