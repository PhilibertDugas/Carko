import UIKit
import IQKeyboardManagerSwift

protocol ParkingDescriptionDelegate: class {
    func userDidChangeDescription(value: String)
}

class ParkingDescriptionViewController: UIViewController {
    
    @IBOutlet weak var descriptionText: UITextView!
    
    var delegate: ParkingDescriptionDelegate!
    var parkingDescription: String!
    var placeholderTextPresent = true

    override func viewDidLoad() {
        super.viewDidLoad()
        if !parkingDescription.isEmpty {
            descriptionText.text = parkingDescription
            descriptionText.textColor = UIColor.primaryWhiteTextColor
        } else {
            descriptionText.text = Translations.t("Add a short description of your parking and details to help people use your parking.")
        }
        descriptionText.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        if !placeholderTextPresent {
            delegate.userDidChangeDescription(value: descriptionText.text)
        }
    }
}

extension ParkingDescriptionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionText.textColor = UIColor.primaryWhiteTextColor
        if placeholderTextPresent {
            descriptionText.text = ""
            placeholderTextPresent = false
        }
    }
}
