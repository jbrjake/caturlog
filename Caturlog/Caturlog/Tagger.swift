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

class Tagger: TagServiceProtocol {
 
    func addTag(tag: String, contentID: String, user: User) -> (Bool, NSError?) {
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices

        if let tagEntity = getTag(tag) {
            if let item = services.entityAccessor.getItem(contentID)? {
                addUserItemTag(user, item: item, tag: tagEntity) // UH no only do this if we can't find it already
                return (true, nil)
            }
        }
        
        return (false, nil)
    }
    
    func itemsForTag(tag: String, withUser: User) -> (NSSet?) {
        
        return nil
    }
    
    func getTag(name: String) -> (Tag?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDelegate.caturlogServices
        
        if let tag = services.entityAccessor.getTag(name)? {
            return tag
        }
        else if let tag = services.entityAccessor.insertTag(name)? {
            return tag
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
    
}