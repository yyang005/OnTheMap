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
            alert("location field is empty")
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
            alert("Please provide link")
            return
        }
        let service = StudentInfoService.sharedInstance
        service.getUserData(service.userID!) { (error) -> Void in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alert(error!)
                })
                return
            }
                
            service.user.uniqueKey = service.userID
            service.user.mediaURL = self.mediaTextField.text
            service.user.mapString = self.locationTextField.text
            service.user.latitude = self.lat
            service.user.longitude = self.long
            service.postUserLocations(service.user, completionHandlerForPost: { (results, error) -> Void in
                guard error == nil else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.alert(error!)
                    })
                    return
                }
                guard results != nil else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.alert("Posting info fails")
                    })
                    return
                }
            })
            self.dismissViewControllerAnimated(true, completion: nil)
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
        activityIndicator.startAnimating()
        geoCoder.geocodeAddressString(locationTextField.text!) { (placeMark, error) -> Void in
            self.activityIndicator.stopAnimating()
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alert(error!.description)
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
                    self.alert("unrecognized location")
                })
                return
            }
        }
    }
}
