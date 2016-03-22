//
//  StudentInfoService.swift
//  OnTheMap
//
//  Created by ying yang on 3/19/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

class StudentInfoService: NSObject {
    var session: NSURLSession = NSURLSession.sharedSession()
    var userID: String? = nil
    var sessionID: String? = nil
    
    func getUserLocations(completionHandlerForGet: (results: [Student]?, error: String?) -> Void) {
        let url = urlFromString(StudentInfoService.constants.StudentInfoURL)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        taskForGetMethod(request) { (results, error) -> Void in
            guard error == nil else{
                return
            }
            if let results = results[StudentInfoService.JSONResponseKey.Results] as? [[String:AnyObject]] {
                let students = self.getUserInfoFrom(results)
                completionHandlerForGet(results: students, error: nil)
            }else {
                 completionHandlerForGet(results: nil, error: "Could not parse getUserLocations")
            }
        }
    }

    func getUserData(method: String, userId: String, completionHandlerForGet: (results: [String: AnyObject]?, error: String?) -> Void) {
        if method.rangeOfString("{id}") != nil {
            let methodString = method.stringByReplacingOccurrencesOfString("{id}", withString: userId)
            let urlString = StudentInfoService.constants.ApiSchem + "://" + StudentInfoService.constants.ApiHost + StudentInfoService.constants.ApiPath + methodString
            if let url = urlFromString(urlString){
                let request = NSURLRequest(URL: url)
                taskForGetMethod(request) { (results, error) -> Void in
                    if let results = results as? [String: AnyObject]{
                        completionHandlerForGet(results: results, error: nil)
                    }else{
                        completionHandlerForGet(results: nil, error: error)
                    }
                }
            }
        }
    }
    
    func getUserID(userName: String, password: String, completionHandlerForPost: (userID: String?, sessionID: String?, error: String?) -> Void) {
        let urlString = StudentInfoService.constants.ApiSchem + "://" + StudentInfoService.constants.ApiHost + StudentInfoService.constants.ApiPath + StudentInfoService.method.Session

        if let url = urlFromString(urlString){
            let request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonString = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
            taskForPostMethod(request, jsonBody: jsonString) { (results, error) -> Void in
                let sessionId: String?
                let userId: String?
                if let results = results {
                    if let sessionDictionary = results["session"] as? [String:AnyObject],
                        let sessionID = sessionDictionary["id"] as? String {
                            sessionId = sessionID
                    }else {
                        completionHandlerForPost(userID: nil, sessionID: nil, error: "Cannot find the key session")
                        return
                    }
                    if let sessionDictionary = results["account"] as? [String:AnyObject],
                        let userID = sessionDictionary["key"] as? String {
                            userId = userID
                    }else {
                        completionHandlerForPost(userID: nil, sessionID: nil, error: "Cannot find the key account")
                        return
                    }
                    completionHandlerForPost(userID: userId, sessionID: sessionId, error: nil)
                }
            }
        }
    }
    
    func postUserLocations(user: Student, completionHandlerForPost: (results: [String: AnyObject]?, error: String?) -> Void) {
        if let url = NSURL(string: StudentInfoService.constants.StudentInfoURL){
            let request = NSMutableURLRequest(URL: url)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonString = "{\"uniqueKey\": \"\(user.uniqueKey)\", \"firstName\": \"\(user.firstName)\", \"lastName\": \"\(user.lastName)\",\"mapString\": \"\(user.mapString)\", \"mediaURL\": \"\(user.mediaURL)\",\"latitude\": \(user.latitude), \"longitude\": \(user.longitude)}"
            taskForPostMethod(request, jsonBody: jsonString) { (results, error) -> Void in
                if let results = results as? [String: AnyObject]{
                    completionHandlerForPost(results: results, error: nil)
                }else{
                    completionHandlerForPost(results: nil, error: error)
                }
            }
        }
    }
    
    private func taskForGetMethod(request: NSURLRequest, completionHandlerForGet: (results: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                return
            }
            guard let data = data else {
                print("No data returned with your request")
                return
            }
            //let newData = data.subdataWithRange(NSMakeRange(5, data.length))
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGet)
        }
        task.resume()
        return task
    }
    
    private func taskForPostMethod(request: NSMutableURLRequest, jsonBody: String, completionHandlerForGet: (results: AnyObject?, error: String?) -> Void) -> NSURLSessionDataTask {
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            guard let data = data else {
                completionHandlerForGet(results: nil, error: "No data returned with your request")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length))
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGet)
        }
        task.resume()
        return task
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: String?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerForConvertData(result: nil, error: "Could not parse the data as JSON: '\(data)'")
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    private func urlFromString(urlString: String) -> NSURL? {
        if let escapedString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
            let url = NSURL(string: escapedString){
                print(escapedString)
                return url
        }
        return nil
    }
    
    private func getUserInfoFrom(userList: [[String: AnyObject]]) -> [Student]{
        var students = [Student]()
        for user in userList {
            let student = Student(user: user)
            students.append(student)
        }
        return students
    }
}

extension StudentInfoService {
    struct constants {
        //MARK: URLs
        static let ApiSchem = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let StudentInfoURL = "https://api.parse.com/1/classes/StudentLocation"
        
        //MARK: API Key
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //MARK: Application Key
        static let ApplicationKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
    
    struct method {
        static let User = "/user/{id}"
        static let Session = "/session"
    }
    
    struct parametersKey {
        static let ApplicationID = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
    }
    
    struct JSONResponseKey {
        static let User = "user"
        static let UserID = "key"
        static let Session = "session"
        static let SessionID = "id"
        static let Account = "account"
        static let Results = "results"
    }
}