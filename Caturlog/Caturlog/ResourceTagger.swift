//
//  ResourceTagger.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/27/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit
import CoreData

class ResourceTagger: ResourceTaggingServiceProtocol {
 
    func addTag(tag: String, contentID: String, user: User) -> (Bool, NSError?) {
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices

        if let tagEntity = getTag(tag) {
            if let item = services.resourceLoader.resourceWithContentID(contentID) {
                addUserItemTag(user, item: item, tag: tagEntity)
                return (true, nil)
            }
        }
        
        return (false, nil)
    }
    
    func itemsForTag(tag: String, withUser: User) -> (NSSet?) {
        
        return nil
    }
    
    func getTag(name: String) -> (Tag?) {
        let predicate = NSPredicate(format: "name is %@", name)
        if let tag = fetchEntity("Tag", predicate: predicate) as? Tag {
            return tag
        }
        else if let tag = addTag(name) {
            return tag
        }
        return nil
        
    }

    func addTag(name: String) -> (Tag?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDelegate.managedObjectContext {
            if let tag = NSEntityDescription
                .insertNewObjectForEntityForName("Tag", inManagedObjectContext: moc) 
                as? Tag 
            {
                tag.name = name
                moc.save(nil) // Fixme: do error checking
                return tag
            }
        }
        return nil
    }
    
    func addUserItemTag(user: User, item: Item, tag: Tag) {
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices

        if let moc = appDel.managedObjectContext {
            if let userItemTag = NSEntityDescription 
                .insertNewObjectForEntityForName("UserItemTag", inManagedObjectContext: moc)
                as? UserItemTag
            {
                userItemTag.timestamp = NSDate()
                userItemTag.user = user
                userItemTag.item = item
                userItemTag.tag = tag
                moc.save(nil) // Fixme: do error checking
            }
        }
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