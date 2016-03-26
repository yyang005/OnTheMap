//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by ying yang on 3/13/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let service = StudentInfoService.sharedInstance

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        /*if emailTextField.text!.isEmpty || passwordTextfield.text!.isEmpty {
            print("Please provide email and password")
            emailTextField.text = "bme_image@hotmail.com"
            passwordTextfield.text = "imageimage"
        }else {
            emailTextField.text = "bme_image@hotmail.com"
            passwordTextfield.text = "imageimage"
            service.getUserID(emailTextField.text!, password: passwordTextfield.text!, completionHandlerForPost: { (userID, sessionID, error) -> Void in
                guard error != nil else{
                    print(error)
                    return
                }
                self.completeLogin()
            })
        }*/
        emailTextField.text = "bme_image@hotmail.com"
        passwordTextfield.text = "imageimage"
        service.getUserID(emailTextField.text!, password: passwordTextfield.text!, completionHandlerForPost: { (userID, sessionID, error) -> Void in
            guard error == nil else{
                print(error)
                return
            }
            self.service.userID = userID
            self.service.sessionID = sessionID
            self.completeLogin()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        emailTextField.text = ""
        passwordTextfield.text = ""
    }
    
    private func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UserLocations") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
}

