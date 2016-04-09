//
//  UserTableViewController.swift
//  OnTheMap
//
//  Created by ying yang on 3/16/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    var studentsInfo = StudentsInfo.sharedInstance
    let service = StudentInfoService.sharedInstance
    
    @IBAction func logout(sender: AnyObject) {
        service.logoutUser { (error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    @IBAction func reLoadStudent(sender: AnyObject) {
        service.getUserLocations { (results, error) -> Void in
            guard error == nil else{
                print(error)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertView = UIAlertController(title: "Error", message: error!, preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
                return
            }
            
            self.studentsInfo.students = results!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        service.getUserLocations { (results, error) -> Void in
            guard error == nil else{
                print(error)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertView = UIAlertController(title: "Error", message: error!, preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                })
                return
            }
            
            self.studentsInfo.students = results!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }

    // MARK: TableView delegate and data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsInfo.students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserInfo") as UITableViewCell!
        let firstName = studentsInfo.students[indexPath.row].firstName!
        let lastName = studentsInfo.students[indexPath.row].lastName!
        let url = studentsInfo.students[indexPath.row].mediaURL!
        cell?.textLabel?.text = firstName + " " + lastName
        cell?.detailTextLabel?.text = url
        return cell
    }
}
