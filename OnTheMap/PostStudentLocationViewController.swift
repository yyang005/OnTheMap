//
//  PostStudentLocationViewController.swift
//  OnTheMap
//
//  Created by ying yang on 3/23/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit
import MapKit

class PostStudentLocationViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mediaTextField: UITextField!
    
    @IBAction func findButton(sender: UIButton) {
        if locationTextField.text!.isEmpty {
            // TODO: error handling
            return
        }
        updateUI()
        getUserLocation()
    }
    @IBAction func Cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submit(sender: UIButton) {
        if mediaTextField.text!.isEmpty {
            // TODO: error handling
            return
        }
        let service = StudentInfoService.sharedInstance
        let userID = service.userID
        print(userID)
        service.getUserData(StudentInfoService.method.User, userId: userID!) { (results, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if let results = results {
                let student = Student()
                if let firstName = results[StudentInfoService.JSONResponseKey.FirstName] as? String,
                    let lastName = results[StudentInfoService.JSONResponseKey.LastName] as? String {
                    student.firstName = firstName
                    student.lastName = lastName
                    student.mediaURL = self.mediaTextField.text
                    service.postUserLocations(student) { (results, error) -> Void in
                        guard error == nil else {
                            print(error)
                            return
                        }
                    }
                }
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.hidden = true
        mediaTextField.hidden = true
        submitButton.hidden = true
    }
    
    func updateUI() {
        label1.hidden = true
        label2.hidden = true
        label3.hidden = true
        findButton.hidden = true
        locationTextField.hidden = true
        mapView.hidden = false
        submitButton.hidden = false
        mediaTextField.hidden = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if (locationTextField.isFirstResponder() && touch != locationTextField){
                locationTextField.resignFirstResponder()
            }
            if (mediaTextField.isFirstResponder() && touch != mediaTextField) {
                mediaTextField.resignFirstResponder()
            }
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    func getUserLocation(){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationTextField.text!) { (placeMark, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            if let placeMark = placeMark,
                let place = placeMark.first,
                let location = place.location{
                    let lat = location.coordinate.latitude
                    let long = location.coordinate.longitude
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.mapView.addAnnotation(annotation)
                    })
            }
        }
    }
}
