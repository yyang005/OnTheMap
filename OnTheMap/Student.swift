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
        objectid = nil
        uniqueKey = nil
        firstName = nil
        lastName = nil
        mapString = nil
        mediaURL = nil
        latitude = nil
        longitude = nil
        createAt = nil
        updatedAt = nil
    }
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