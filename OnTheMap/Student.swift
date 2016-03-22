//
//  Student.swift
//  OnTheMap
//
//  Created by ying yang on 3/14/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

class Student {
    var objectid: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var createAt: String? = nil
    var updatedAt: String? = nil
    
    init(user: [String: AnyObject]) {
        if let objectid: String = user["objectId"] as? String,
        let uniqueKey: String = user["uniqueKey"] as? String,
        let firstName: String = user["firstName"] as? String,
        let lastName: String = user["lastName"] as? String,
        let mapString: String = user["mapString"] as? String,
        let mediaURL: String = user["mediaURL"] as? String,
        let latitude: Double = user["latitude"] as? Double,
        let longitude: Double = user["longitude"] as? Double,
        let updatedAt: String = user["updatedAt"] as? String,
        let createAt: String = user["createdAt"] as? String {
            self.objectid = objectid
            self.uniqueKey = uniqueKey
            self.firstName = firstName
            self.lastName = lastName
            self.mapString = mapString
            self.mediaURL = mediaURL
            self.latitude = latitude
            self.longitude = longitude
            self.createAt = createAt
            self.updatedAt = updatedAt
        }
    }
}