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

    // Goes right from a URL to an Item saved in the moc
    func storeResource(url: NSURL) {
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices
        var result = false, error: NSErrorPointer? = nil

        services.resourceLoader.getResource(url, completion: {
            data in
            if data != nil {
                // Should be passing errors here, but the closure
                // syntax for tuples is damned confusing.
                self.storeResource(data!.sha256(), fromURL:url)
            }
        })
    }

    
    /*Add the item if it isn't present, add the URL as a characteristic if it isn't present,
      and associate the two of them together. */
    func storeResource(contentID: String, fromURL: NSURL) -> (Bool, NSErrorPointer?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        if let moc = appDelegate.managedObjectContext {
            if let item = appDelegate.caturlogServices.entityAccessor.getItem(contentID)? {
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
    

    // Return an existing or new Characteristic? with name "URL" and value url
    func characteristicForURL(url: NSURL) -> Characteristic? {
        
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDelegate.caturlogServices
        if let entity = services.entityAccessor.getCharacteristic("URL", value: url.absoluteString)? {
            return entity
        }
        else if let entity = services.entityAccessor.insertCharacteristic("URL", value: url.absoluteString)? {
            return entity
        }
        
        return nil
    }

}