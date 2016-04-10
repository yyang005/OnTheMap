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

    var lat: Double?
    var long: Double?
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mediaTextField: UITextField!
    
    @IBAction func findButton(sender: UIButton) {
        if locationTextField.text!.isEmpty {
            let alertView = UIAlertController(title: "Error", message: "location field is empty", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        updateUI()
        activityIndicator.startAnimating()
        getUserLocation()
        activityIndicator.stopAnimating()
    }
    @IBAction func Cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submit(sender: UIButton) {
        if mediaTextField.text!.isEmpty {
            let alertView = UIAlertController(title: "Error", message: "Please provide link", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        let service = StudentInfoService.sharedInstance
        service.getUserData(service.userID!) { (user, error) -> Void in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertView = UIAlertController(title: "Error", message: error!, preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
                return
            }
            if let user = user {
                user.mediaURL = self.mediaTextField.text
                user.mapString = self.locationTextField.text
                user.uniqueKey = service.userID
                user.longitude = self.long!
                user.latitude = self.lat!
                
                service.postUserLocations(user, completionHandlerForPost: { (results, error) -> Void in
                    guard error == nil else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alertView = UIAlertController(title: "Error", message: error!, preferredStyle: .Alert)
                            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alertView, animated: true, completion: nil)
                        })
                        return
                    }
                    guard results != nil else{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alertView = UIAlertController(title: "Error", message: "Posting info fails", preferredStyle: .Alert)
                            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alertView, animated: true, completion: nil)
                        })
                        return
                    }
                })
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertView = UIAlertController(title: "Error", message: "error in forward geocode", preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
                return
            }
            
            if let firstPlaceMark = placeMark?.first,
                let location = firstPlaceMark.location{
                    self.lat = location.coordinate.latitude
                    self.long = location.coordinate.longitude
                    let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
                    let span = MKCoordinateSpanMake(0.1, 0.1)
                    let region = MKCoordinateRegionMake(center, span)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.mapView.addAnnotation(annotation)
                        self.mapView.setRegion(region, animated: true)
                    })
            }else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertView = UIAlertController(title: "Error", message: "unrecognized location", preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
                return
            }
        }
    }
}
