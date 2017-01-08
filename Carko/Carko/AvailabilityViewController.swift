import UIKit
import Foundation
import _10Clock

protocol ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: AvailabilityInfo)
}

class AvailabilityViewController: UIViewController {
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var clock: TenClock!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet var progressView: UIView!
    @IBOutlet var mainButton: RoundedCornerButton!

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
        self.dateFormatter = DateFormatter.init()
        self.dateFormatter.dateFormat = "HH:mm"
        setupClock()
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

    func setupClock() {
        self.clock.delegate = self
        self.clock.minorTicksEnabled = false
        self.clock.centerTextColor = UIColor.black
        // FIXME: For some reasone endDate & startDate are reversed
        self.clock.endDate = self.availability.startDate()
        self.clock.startDate = self.availability.stopDate()
    }

    func updateAvailability() {
        let daysAvailable = availability.daysAvailable

        // findDayButton with tag=0 returns every other views. Creating a mondayButton reference is easier than changing the tag for every view in the scene
        updateButton(isOn: daysAvailable[0], button: mondayButton)

        for index in 1...6 {
            updateButton(isOn: daysAvailable[index], button: findDayButton(tag: index))
        }

        updateTimeLabel(startTime: availability.startTime, endTime: availability.stopTime)
    }

    func updateTimeLabel(startTime: String, endTime: String) {
        fromLabel.text = startTime
        toLabel.text = endTime
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

extension AvailabilityViewController: TenClockDelegate {
    func timesChanged(_ clock: TenClock, startDate: Date, endDate: Date) {
        let startTime = dateFormatter.string(from: endDate)
        let stopTime = dateFormatter.string(from: startDate)
        availability.startTime = startTime
        availability.stopTime = stopTime
    }

    func timesUpdated(_ clock: TenClock, startDate: Date, endDate: Date) {
        // FIXME: For some reason, startDate & endDate are reversed
        let startTime = dateFormatter.string(from: endDate)
        let stopTime = dateFormatter.string(from: startDate)
        updateTimeLabel(startTime: startTime, endTime: stopTime)
    }
}
