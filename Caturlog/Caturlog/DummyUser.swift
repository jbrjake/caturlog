//
//  DummyUser.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/27/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import CoreData
import AppKit

class DummyUser: UserServiceProtocol {

    func getCurrentUserID() -> (Int?) {
        return 1
    }
    
    func getCurrentUser() -> (User?) {
        if let userID = getCurrentUserID()? {
            if let user = getUserWithID(userID)? {
                return user
            }
            else if let user = addUser("jbrjake") {
                return user
            }
        }

        return nil
    }
    
    // Return user if it exists
    func getUserWithID(userID: Int) -> (User?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDelegate.caturlogServices
        return services.entityAccessor.getUser(userID)
    }
    
    func addUser(name: String) -> (User?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDelegate.caturlogServices
        if let user = services.entityAccessor.insertUser(1)?  { // CHANGE THIS '1' LATER
            user.name = name                            // Need another accessor method to pass this instead
            appDelegate.managedObjectContext?.save(nil) // Oh my god I can't believe I'm doing this to save time :(
            return user
        }
        return nil
    }

}