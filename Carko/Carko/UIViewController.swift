//
//  KeyboardDimissExtension.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-13.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Crashlytics

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    func getDefaultAlertController(_ message: String) -> UIAlertController {
        let alert = UIAlertController.init(title: Translations.t("Error"), message: message, preferredStyle: UIAlertControllerStyle.alert)
        return alert
    }

    func getAlertController(_ message: String) -> UIAlertController {
        let alert = UIAlertController.init(title: Translations.t("Error"), message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: Translations.t("Ok"), style: UIAlertActionStyle.default, handler: nil))
        return alert
    }

    func displayErrorMessage(_ message: String) {
        Crashlytics.sharedInstance().recordError(NSError.init(domain: message, code: 0, userInfo: nil))
        self.present(getAlertController(message), animated: true, completion: nil)
    }

    func displayMessage(_ message: String, title: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: Translations.t("Ok"), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func displayDestructiveMessage(_ message: String, title: String, handle: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: Translations.t("Ok"), style: UIAlertActionStyle.destructive, handler: handle))
        alert.addAction(UIAlertAction.init(title: Translations.t("Cancel"), style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
