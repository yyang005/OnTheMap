//
//  Student.swift
//  OnTheMap
//
//  Created by ying yang on 3/14/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

class Student {
    var objectid: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var createAt: String?
    var updatedAt: String?
    
    init() {
        /*objectid = nil
        uniqueKey = nil
        firstName = nil
        lastName = nil
        mapString = nil
        mediaURL = nil
        latitude = nil
        longitude = nil
        createAt = nil
        updatedAt = nil*/
    }
    init(user: [String: AnyObject]) {
        if let objectid = user["objectId"] as? String,
        let uniqueKey = user["uniqueKey"] as? String,
        let firstName = user["firstName"] as? String,
        let lastName = user["lastName"] as? String,
        let mapString = user["mapString"] as? String,
        let mediaURL = user["mediaURL"] as? String,
        let latitude = user["latitude"] as? Double,
        let longitude = user["longitude"] as? Double,
        let updatedAt = user["updatedAt"] as? String,
        let createAt  = user["createdAt"] as? String {
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