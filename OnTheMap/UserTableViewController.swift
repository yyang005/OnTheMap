//
//  UserTableViewController.swift
//  OnTheMap
//
//  Created by ying yang on 3/16/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {
    var students: [Student] = [Student]()
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
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        service.getUserLocations { (results, error) -> Void in
            guard error == nil else{
                print(error)
                return
            }
            
            self.students = results!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }

    // MARK: TableView delegate and data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserInfo") as UITableViewCell!
        let firstName = students[indexPath.row].firstName!
        let lastName = students[indexPath.row].lastName!
        let url = students[indexPath.row].mediaURL!
        cell?.textLabel?.text = firstName + " " + lastName
        cell?.detailTextLabel?.text = url
        return cell
    }
}
