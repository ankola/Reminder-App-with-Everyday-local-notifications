//
//  CommonFunctions.swift
//  reminderApp
//
//  Created by Savan Ankola on 03/03/21.
//

import Foundation
import UIKit

class CommonFunctions {
    
    static var shared = CommonFunctions()

    // Show Alert
    func showAlertMessage(vc: UIViewController, titleStr:String, messageStr:String) -> Void {
        
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
