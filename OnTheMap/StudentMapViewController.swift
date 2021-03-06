//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by ying yang on 3/20/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController {

    var annotations :[MKPointAnnotation] = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func logout(sender: UIBarButtonItem) {
        service.logoutUser { (error) -> Void in
            guard error == nil else {
                print(error)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alert(error!)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    @IBAction func reLoadStudent(sender: UIBarButtonItem) {
        for annotation in annotations {
            mapView.removeAnnotation(annotation)
        }
        
        service.getUserLocations { (results, error) -> Void in
            guard error == nil else {
                print(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alert(error!)
                })
                return
            }
            self.annotations = self.getAnnotationsFrom(results!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotations(self.annotations)
            })
        }
    }
    
    let service = StudentInfoService.sharedInstance
    var studentsInfo = StudentsInfo.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        service.getUserLocations { (results, error) -> Void in
            guard error == nil else {
                print(error!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alert(error!)
                })
                return
            }
            self.annotations = self.getAnnotationsFrom(results!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotations(self.annotations)
            })
        }
    }
    
    func getAnnotationsFrom(results: [Student]) -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for student in results {
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(student.latitude! as Double)
            let long = CLLocationDegrees(student.longitude! as Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = student.firstName! + " " + student.lastName!
            annotation.subtitle = student.mediaURL!
            annotations.append(annotation)
        }
        return annotations
    }
    
    // MARK: MapView delegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKPointAnnotation) -> MKAnnotationView? {
        let reuseId = "Pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                let url = NSURL(string: toOpen)!
                if app.canOpenURL(url){
                    app.openURL(url)
                }else{
                    alert("Invalid url")
                    return
                }
            }
        }
    } 
}
