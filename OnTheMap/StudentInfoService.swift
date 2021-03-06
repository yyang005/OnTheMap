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
    var user = Student()
    
    static let sharedInstance = StudentInfoService()
    
    func getUserLocations(completionHandlerForGet: (results: [Student]?, error: String?) -> Void) {
        let parameters: [String:AnyObject] = [StudentInfoService.parametersKey.Limit: StudentInfoService.parametersValue.Limit,
            StudentInfoService.parametersKey.Order: StudentInfoService.parametersValue.Order]
        let url = urlFrom(StudentInfoService.constants.ApiSchem, apiHost: StudentInfoService.constants.ParseApiHost, apiPath: StudentInfoService.constants.ParseApiPath, parameters: parameters, withPathExtension: StudentInfoService.method.StudentLocation)
        let request = NSMutableURLRequest(URL: url)
        request.addValue(StudentInfoService.constants.ApplicationKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfoService.constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        taskForGetMethod(false, request: request) { (results, error) -> Void in
            guard error == nil else{
                completionHandlerForGet(results: nil, error: error)
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

    func getUserData(userId: String, completionHandlerForGet: (error: String?) -> Void) {
        let method = StudentInfoService.method.UserID
        if method.rangeOfString("{id}") != nil {
            let methodString = method.stringByReplacingOccurrencesOfString("{id}", withString: userId)
            
            let url = urlFrom(StudentInfoService.constants.ApiSchem, apiHost: StudentInfoService.constants.UdacityApiHost, apiPath: StudentInfoService.constants.UdacityApiPath, parameters: nil, withPathExtension: methodString)
            let request = NSURLRequest(URL: url)
            taskForGetMethod(true, request: request) { (results, error) -> Void in
                guard error == nil else {
                    completionHandlerForGet(error: error)
                    return
                }
                if let results = results as? [String: AnyObject]{
                    if let userDictionary = results[StudentInfoService.JSONResponseKey.User] as? [String: AnyObject],
                    let firstName = userDictionary[StudentInfoService.JSONResponseKey.FirstName] as? String,
                    let lastName = userDictionary[StudentInfoService.JSONResponseKey.LastName] as? String {
                        self.user.firstName = firstName
                        self.user.lastName = lastName
                        completionHandlerForGet(error: nil)
                    }
                }else{
                    completionHandlerForGet(error: "Cannot get user info")
                }
            }
        }
    }
    
    func getUserID(userName: String, password: String, completionHandlerForPost: (userID: String?, sessionID: String?, error: String?) -> Void) {
        let url = urlFrom(StudentInfoService.constants.ApiSchem, apiHost: StudentInfoService.constants.UdacityApiHost, apiPath: StudentInfoService.constants.UdacityApiPath, parameters: nil, withPathExtension: StudentInfoService.method.Session)
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue(StudentInfoService.constants.Json, forHTTPHeaderField: "Accept")
        request.addValue(StudentInfoService.constants.Json, forHTTPHeaderField: "Content-Type")
        let jsonString = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        taskForPostMethod(true, request: request, jsonBody: jsonString) { (results, error) -> Void in
            guard error == nil else {
                completionHandlerForPost(userID: nil, sessionID: nil, error: "network connection error")
                return
            }
            
            if let results = results {
                if let error = results[StudentInfoService.JSONResponseKey.Error] as? String {
                    completionHandlerForPost(userID: nil, sessionID: nil, error: error)
                    return
                }
                if let sessionDictionary = results[StudentInfoService.JSONResponseKey.Session] as? [String:AnyObject],
                    let sessionID = sessionDictionary[StudentInfoService.JSONResponseKey.SessionID] as? String {
                        self.sessionID = sessionID
                }else {
                    completionHandlerForPost(userID: nil, sessionID: nil, error: "Cannot find the key: session")
                    return
                }
                if let sessionDictionary = results[StudentInfoService.JSONResponseKey.Account] as? [String:AnyObject],
                    let userID = sessionDictionary[StudentInfoService.JSONResponseKey.UserID] as? String {
                        self.userID = userID
                }else {
                    completionHandlerForPost(userID: nil, sessionID: nil, error: "Cannot find the key: account")
                    return
                }
                completionHandlerForPost(userID: self.userID, sessionID: self.sessionID, error: nil)
            }
        }
    }
    
    func postUserLocations(user: Student, completionHandlerForPost: (results: [String: AnyObject]?, error: String?) -> Void) {
        let url = urlFrom(StudentInfoService.constants.ApiSchem, apiHost: StudentInfoService.constants.ParseApiHost, apiPath: StudentInfoService.constants.ParseApiPath, parameters: nil, withPathExtension: StudentInfoService.method.StudentLocation)
        let request = NSMutableURLRequest(URL: url)
        request.addValue(StudentInfoService.constants.ApplicationKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(StudentInfoService.constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue(StudentInfoService.constants.Json, forHTTPHeaderField: "Content-Type")
        let jsonString = "{\"uniqueKey\": \"\(user.uniqueKey!)\", \"firstName\": \"\(user.firstName!)\", \"lastName\": \"\(user.lastName!)\",\"mapString\": \"\(user.mapString!)\", \"mediaURL\": \"\(user.mediaURL!)\",\"latitude\": \(user.latitude!), \"longitude\": \(user.longitude!)}"
        taskForPostMethod(false, request: request, jsonBody: jsonString) { (results, error) -> Void in
            guard error == nil else {
                completionHandlerForPost(results: nil, error: error)
                return
            }
            if let results = results as? [String: AnyObject]{
                completionHandlerForPost(results: results, error: nil)
            }else{
                completionHandlerForPost(results: nil, error: "posting user location fails")
            }
        }
    }
    
    func logoutUser(completionHandlerForLogout: (error: String?)->Void) {
        let url = urlFrom(StudentInfoService.constants.ApiSchem, apiHost: StudentInfoService.constants.UdacityApiHost, apiPath: StudentInfoService.constants.UdacityApiPath, parameters: nil, withPathExtension: StudentInfoService.method.Session)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandlerForLogout(error: "error in logout")
                return
            }
            completionHandlerForLogout(error: nil)
        }
        task.resume()
    }
    
    private func taskForGetMethod(strip: Bool, request: NSURLRequest, completionHandlerForGet: (results: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                completionHandlerForGet(results: nil, error: error!.description)
                return
            }
            guard let data = data else {
                print("No data returned with your request")
                completionHandlerForGet(results: nil, error: "No data returned with your request")
                return
            }
            if strip {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length))
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGet)
            }else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGet)
            }
        }
        task.resume()
        return task
    }
    
    private func taskForPostMethod(strip: Bool, request: NSMutableURLRequest, jsonBody: String, completionHandlerForGet: (results: AnyObject?, error: String?) -> Void) -> NSURLSessionDataTask {
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                completionHandlerForGet(results: nil, error: error!.description)
                return
            }
            guard let data = data else {
                completionHandlerForGet(results: nil, error: "No data returned with your request")
                return
            }
            if strip {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length))
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGet)
            }else {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGet)
            }
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
    
    private func urlFrom(apiScheme: String, apiHost: String, apiPath: String, parameters: [String: AnyObject]?, withPathExtension: String) -> NSURL {
        let components = NSURLComponents()
        components.scheme = apiScheme
        components.host = apiHost
        components.path = apiPath + withPathExtension ?? ""
        
        if parameters != nil {
            components.queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters! {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.URL!
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
        //MARK: Udacity URLs
        static let ApiSchem = "https"
        static let UdacityApiHost = "www.udacity.com"
        static let UdacityApiPath = "/api"
    
        //MARK: Parse URLs
        static let ParseApiHost = "api.parse.com"
        static let ParseApiPath = "/1/classes"
        
        //MARK: API Key
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //MARK: Application Key
        static let ApplicationKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        static let Json = "application/json"
    }
    
    struct method {
        static let UserID = "/users/{id}"
        static let Session = "/session"
        static let StudentLocation = "/StudentLocation"
    }
    
    struct parametersKey {
        static let Limit = "limit"
        static let Order = "order"
    }
    
    struct parametersValue {
        static let Limit = "100"
        static let Order = "-updatedAt"
    }
    
    struct JSONResponseKey {
        static let User = "user"
        static let UserID = "key"
        static let Session = "session"
        static let SessionID = "id"
        static let Account = "account"
        static let Results = "results"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let Error = "error"
        static let StatusCode = "status"
    }
}