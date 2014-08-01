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
                if(!alreadyAssociated(user, item: item, tag: tagEntity)) {
                    addUserItemTag(user, item: item, tag: tagEntity)
                    return (true, nil)
                }
            }
        }
        
        return (false, nil)
    }
    
    func tagNamesForItem(item: Item) -> Array<String>? {
        var tags = Array<String>()
        
        if let associations = item.userItemTags as NSMutableSet? {
            for association in associations {
                if let userItemTag = association as? UserItemTag {
                    tags.append(userItemTag.tag.name)
                }
            }
            return tags
        }
        return nil
    }
    
    func alreadyAssociated(user: User, item: Item, tag: Tag) -> Bool {
        
        let associations :NSMutableSet = item.userItemTags
        for association in associations {
            if let userItemTag = association as? UserItemTag {
                if(userItemTag.tag.name == tag.name && userItemTag.user == user) {
                    return true
                }
            }
        }
        return false
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