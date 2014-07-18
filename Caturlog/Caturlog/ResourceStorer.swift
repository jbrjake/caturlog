//
//  ResourceStorer.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/14/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit
import CoreData

class ResourceStorer: ResourceStoringServiceProtocol {

    /*Add the item if it isn't present, add the URL as a characteristic if it isn't present,
      and associate the two of them together. */
    func storeResource(contentID: String, fromURL: NSURL) -> (Bool, NSErrorPointer?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        if let moc = appDelegate.managedObjectContext {
            if let item = resourceWithContentID(contentID) {
                if let char = characteristicForURL(fromURL) {
                    char.items.addObject(item)
                    item.characteristics.addObject(char)
                }

                // Save out in this scope in case the item or char are new inserts
                let err: NSErrorPointer = nil
                let saveWorked = moc.save(err)
                if(err) {
                    return (saveWorked, err)
                }
                else {
                    return (saveWorked, nil)
                }
            }
        }
        
        return (false, nil)
    }
    
    // Return an existing or new Item? with the contentID
    func resourceWithContentID(contentID: String) -> Item? {
        let predicate = NSPredicate(format: "contentID = %@", contentID, nil)
        
        if let item = fetchEntity("Item", predicate: predicate) as? Item {
            return item
        }
        else {
            let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            if let moc = appDelegate.managedObjectContext {
                if let item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: moc) as? Item {
                    item.contentID = contentID
                    return item
                }
            }
        }
        
        return nil
    }

    // Return an existing or new Characteristic? with name "URL" and value url
    func characteristicForURL(url: NSURL) -> Characteristic? {
        let predicate = NSPredicate(format: "name = %@ && value = %@", "URL", url.absoluteString, nil)
        
        if let entity = fetchEntity("Characteristic", predicate: predicate) as? Characteristic {
            return entity
        }
        else {
            let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            if let moc = appDelegate.managedObjectContext {
                if let char = NSEntityDescription.insertNewObjectForEntityForName("Characteristic", inManagedObjectContext: moc) as? Characteristic {
                    char.name = "URL"
                    char.value = url.absoluteString
                    return char
                }
            }
        }
        
        return nil
    }
    
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