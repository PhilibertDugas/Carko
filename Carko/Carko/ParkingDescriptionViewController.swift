import UIKit
import IQKeyboardManagerSwift

protocol ParkingDescriptionDelegate: class {
    func userDidChangeDescription(value: String)
}

class ParkingDescriptionViewController: UIViewController {
    
    @IBOutlet weak var descriptionText: UITextView!
    
    var delegate: ParkingDescriptionDelegate!
    var parkingDescription: String!
    
    @IBAction func saveChange(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
        delegate.userDidChangeDescription(value: descriptionText.text)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionText.text = parkingDescription
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
    }
}
