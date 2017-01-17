import UIKit
import Foundation

protocol ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: AvailabilityInfo)
}

class AvailabilityViewController: UIViewController {
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var progressView: UIView!
    @IBOutlet var mainButton: RoundedCornerButton!
    @IBOutlet var fromPicker: UIDatePicker!
    @IBOutlet var toPicker: UIDatePicker!

    var delegate: ParkingAvailabilityDelegate?

    var availability: AvailabilityInfo!
    var dateFormatter: DateFormatter!
    var parking: Parking!
    var newParking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if !newParking {
            progressView.isHidden = true
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
        let startTime = AvailabilityInfo.formatter().string(from: fromPicker.date)
        let stopTime = AvailabilityInfo.formatter().string(from: toPicker.date)
        self.availability.startTime = startTime
        self.availability.stopTime = stopTime
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
    }

    func updateAvailability() {
        let daysAvailable = availability.daysAvailable

        // findDayButton with tag=0 returns every other views. Creating a mondayButton reference is easier than changing the tag for every view in the scene
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
}
