//
//  ViewControllerExtension.swift
//  OnTheMap
//
//  Created by ying yang on 4/10/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert (message: String){
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}