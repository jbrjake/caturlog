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

    func getCurrentUserID() -> (userID: Int?) {
        return 1
    }
    
    func getCurrentUser() -> (user: User?) {
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
        let predicate = NSPredicate(format: "userID = %@", userID)
        return fetchEntity("User", predicate: predicate) as User?
    }
    
    func addUser(name: String) -> (User?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDelegate.managedObjectContext {
            if let user = NSEntityDescription
                .insertNewObjectForEntityForName("User", inManagedObjectContext: moc) 
                as? User 
            {
                user.name = name
                user.userID = 1 // <-- SEE THIS? REMEMBER TO CHANGE THIS POST-DUMMY, DUMMY
                moc.save(nil)
                return user
            }
        }
        return nil
    }

    // Copying this over like this is horrible. Need to find a centralized location for CD helpers.
    // Return the first fetch result for the named managed object matching the given predicate
    func fetchEntity(name: String, predicate: NSPredicate) -> NSManagedObject? {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        if let moc = appDelegate.managedObjectContext {
            let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: moc)
            var request = NSFetchRequest()
            request.entity = entity
            request.predicate = predicate
            var err: NSErrorPointer = nil
            let results = moc.executeFetchRequest(request, error: err)
            if(results.count > 0) {
                return results[0] as? NSManagedObject
            }
        }
        
        return nil
    }

}