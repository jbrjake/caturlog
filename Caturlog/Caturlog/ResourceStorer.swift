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
import Cocoa

class ResourceStorer: ResourceStoringServiceProtocol {

    
    /*Add the item if it isn't present, add the URL as a characteristic if it isn't present,
      and associate the two of them together. */
    func storeResource(contentID: String, fromURL: NSURL) -> (Bool, NSErrorPointer?) {
        println("storing resource")
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if let moc = appDelegate.managedObjectContext {
            println("moc exists")
            var item :Item? = resourceWithContentID(contentID)
            if (item == nil) {
                println("resourceWithContentID returned nil")
               item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: moc) as? Item
            }
            if (item != nil) {
                item!.contentID = contentID
                
                var maybeChar = characteristicForURL(fromURL)
                if (!maybeChar?) {
                    maybeChar = NSEntityDescription.insertNewObjectForEntityForName("Characteristic", inManagedObjectContext: moc) as? Characteristic
                }
                
                if let char = maybeChar? {
                    char.name = "URL"
                    char.value = fromURL.absoluteString
                    char.items.addObject(item)
                    item!.characteristics.addObject(char)
                    
                }
                
                println("about to save item: \(item!)")
                let err: NSErrorPointer = nil
                let saveWorked = moc.save(err)
                
                if(err) {
                    println("returning \(saveWorked): \(err)")
                    return (saveWorked, err)
                }
                else {
                    println("returning \(saveWorked)")
                    return (saveWorked, nil)
                }
            }
        }
        
        return (false, nil)
    }
    
    func resourceWithContentID(contentID: String) -> Item? {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate

        if let moc = appDelegate.managedObjectContext {
            let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: moc)
            var request = NSFetchRequest()
            request.entity = entity
            let predicate = NSPredicate(format: "contentID = %@", contentID, nil)
             request.predicate = predicate
            var err:NSErrorPointer = nil
            let results = moc.executeFetchRequest(request, error: err)
            println("fetch results: \(results)")
            if (results.count > 0) {
                return results[0] as? Item
            }
        }
        
        return nil
    }

    func characteristicForURL(url: NSURL) -> Characteristic? {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        if let moc = appDelegate.managedObjectContext {
            let entity = NSEntityDescription.entityForName("Characteristic", inManagedObjectContext: moc)
            var request = NSFetchRequest()
            request.entity = entity
            let predicate = NSPredicate(format: "name = %@ && value = %@", "URL", url.absoluteString, nil)
            request.predicate = predicate
            var err:NSErrorPointer = nil
            let results = moc.executeFetchRequest(request, error: err)
            if(results.count > 0) {
                return results[0] as? Characteristic
            }
        }
        
        return nil
    }


}