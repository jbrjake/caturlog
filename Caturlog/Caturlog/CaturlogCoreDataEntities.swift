//
//  CaturlogCoreDataEntities.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/14/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit
import CoreData

class UserItemTag: NSManagedObject {
    @NSManaged var timestamp:       NSDate
    
    @NSManaged var item:            Item
    @NSManaged var tag:             Tag
    @NSManaged var user:            User
}

class User: NSManagedObject {
    @NSManaged var name:            String
    @NSManaged var userID:          Int
    
    @NSManaged var items:           NSMutableSet
    @NSManaged var userItemTags:    NSMutableSet
}

class Item: NSManagedObject {
    @NSManaged var contentID:       String

    @NSManaged var characteristics: NSMutableSet
    @NSManaged var tags:            NSMutableSet
    @NSManaged var users:           NSMutableSet
    @NSManaged var userItemTags:    NSMutableSet
    
}

class Tag: NSManagedObject {
    @NSManaged var name:            String
    
    @NSManaged var items:           NSMutableSet
    @NSManaged var userItemTags:    NSMutableSet
    
}

class Characteristic: NSManagedObject {
    @NSManaged var name:            String
    @NSManaged var value:           String

    @NSManaged var items:           NSMutableSet
}

class EntityAccessor: EntityServiceProtocol {
    
    func getItem(contentID: String) -> (item: Item?) {
        let predicate = NSPredicate(format: "contentID = %@", contentID)
        
        return fetchEntity("Item", predicate: predicate) as? Item
    }

    func getUser(userID: Int) -> (user: User?) {
        let predicate = NSPredicate(format: "userID = %@", userID)
        return fetchEntity("User", predicate: predicate) as User?
    }

    func getTag(name: String) -> (tag: Tag?) {
        let predicate = NSPredicate(format: "name = %@", name)
        return fetchEntity("Tag", predicate: predicate) as Tag?
    }

    func getCharacteristic(name: String, value:String) -> (characteristic: Characteristic?) {
        let predicate = NSPredicate(format: "name = %@ && value = %@", name, value)
        return fetchEntity("Characteristic", predicate: predicate) as Characteristic?
    }

    func getUserItemTagsForTag(name: String, user: User) -> (Array<UserItemTag>?) {
        let predicate = NSPredicate(format: "tag.name = %@ and user = %@", name, user)
        return fetchEntities(name, predicate: predicate) as? Array<UserItemTag>
    }

    func getUserItemTag(tag: String, contentID: String, user: User) -> (UserItemTag?) {
        let predicate = NSPredicate(format: "tag.name = %@ and user = %@ and item.contentID = %@", tag, user, contentID)
        return fetchEntity("UserItemTag", predicate: predicate) as UserItemTag?
    }
    
    func insertItem(contentID: String) -> (item: Item?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDelegate.managedObjectContext {
            if let item = NSEntityDescription
                .insertNewObjectForEntityForName("Item", inManagedObjectContext: moc) 
                as? Item 
            {
                item.contentID = contentID
                moc.save(nil) // Bad, bad!
                return item
            }
        }
        return nil
    }
    
    func removeItem(contentID: String) -> () {        
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDel.managedObjectContext {
            if let item = getItem(contentID)? {
                moc.deleteObject(item)
            }
            moc.save(nil) // Fixme: do error checking
        }
    }
    
    func insertUser(userID: Int) -> (user: User?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDelegate.managedObjectContext {
            if let user = NSEntityDescription
                .insertNewObjectForEntityForName("User", inManagedObjectContext: moc) 
                as? User 
            {
                user.userID = userID
                moc.save(nil) // Bad, bad!
                return user
            }
        }
        return nil
    }

    func insertTag(name: String) -> (tag: Tag?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDelegate.managedObjectContext {
            if let tag = NSEntityDescription
                .insertNewObjectForEntityForName("Tag", inManagedObjectContext: moc) 
                as? Tag 
            {
                tag.name = name
                moc.save(nil) // Bad, bad!
                return tag
            }
        }
        return nil
    }

    func insertCharacteristic(name: String, value: String) -> (characteristic: Characteristic?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDelegate.managedObjectContext {
            if let characteristic = NSEntityDescription
                .insertNewObjectForEntityForName("Characteristic", inManagedObjectContext: moc) 
                as? Characteristic 
            {
                characteristic.name = name
                characteristic.value = value
                moc.save(nil) // Bad, bad!
                return characteristic
            }
        }
        return nil
    }

    // Return the first fetch result for the named managed object matching the given predicate
    func fetchEntity(name: String, predicate: NSPredicate) -> NSManagedObject? {
        
        if let results = fetchEntities(name, predicate: predicate) {
            return results[0] as NSManagedObject?            
        }
        
        return nil
    }

    // Return all the results for the named managed object matching the given predicate
    func fetchEntities(name: String, predicate: NSPredicate) -> Array<NSManagedObject>? {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        if let moc = appDelegate.managedObjectContext {
            let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: moc)
            var request = NSFetchRequest()
            request.entity = entity
            request.predicate = predicate
            var err: NSErrorPointer = nil
            let results = moc.executeFetchRequest(request, error: err)
            if(results.count > 0) {
                return results as? Array<NSManagedObject>
            }
        }
        
        return nil
    }

    
}