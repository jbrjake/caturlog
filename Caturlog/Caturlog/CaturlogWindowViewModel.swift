//
//  CaturlogWindowViewModel.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/22/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import Cocoa
import CoreData

class CaturlogWindowViewModel {
    
    let itemEntityController: NSArrayController
    
    init() {
        let moc = (NSApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
        itemEntityController = NSArrayController(content: nil)
        itemEntityController.managedObjectContext = moc
        itemEntityController.bind("managedObjectContext", toObject: moc, withKeyPath: "self", options: nil)
        itemEntityController.entityName = "Item"
        itemEntityController.automaticallyPreparesContent = true
        itemEntityController.avoidsEmptySelection = true
        itemEntityController.preservesSelection = true
        itemEntityController.selectsInsertedObjects = true
        itemEntityController.clearsFilterPredicateOnInsertion = true
        itemEntityController.usesLazyFetching = false
        itemEntityController.fetch(nil)        
    }
        
    func omnibarTokensChanged(newTokens: Array<String>, begin:()->(), completion:(urls: Array<NSURL>, tags:Array<String>)->()) {
        let (urls,tags) = urlsAndTagsFromTokens(newTokens)

        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices
        
        if(urls.count > 0) {
            // Add URLs and bind them to tags; use an empty predicate
            if let user = appDel.caturlogServices.user.getCurrentUser()? {
                for url in urls {
                    dispatch_async(dispatch_get_main_queue(), {begin()})
                    services.filer.storeAsItem(url, completion: { (item: Item?) -> () in
                        if let actualItem = item? {
                            for tag in tags {
                                // Apply the tag for the URL
                                services.tagger.addTag(tag, contentID: actualItem.contentID, user:user)
                            }                    
                        }
                        dispatch_async(dispatch_get_main_queue(), {completion(urls: urls, tags: tags)})
                    })
                }
            }
        }
        else if (tags.count > 0){
            // Create and search with a predicate
            var i = 0
            var predicateString = ""
            for tag in tags {
                if(i > 0) {
                    predicateString += " AND "
                }
                predicateString += "ANY userItemTags.tag.name BEGINSWITH '\(tag)'"
                i++
            }
            itemEntityController.fetchPredicate = NSPredicate(format: predicateString)
            itemEntityController.fetch(nil)
            dispatch_async(dispatch_get_main_queue(), {
                // If there are no matching entities, revert to showing all
                if(self.itemEntityController.arrangedObjects.count == 0) {
                    self.itemEntityController.fetchPredicate = nil
                    self.itemEntityController.fetch(nil)                
                }
            })
        }
        else {
            // Empty field, fetch all items
            itemEntityController.fetchPredicate = nil;
            itemEntityController.fetch(nil)
        }
    }
    
    func tagTokensChanged(oldTokens: Array<String>, newTokens: Array<String>) {
        
        let tokensToInsert = newTokens.filter { value in
            !contains(oldTokens, value)
        }
        let tokensToRemove = oldTokens.filter { value in
            !contains(newTokens, value)
        }
        
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices
        if let user = appDel.caturlogServices.user.getCurrentUser()? {
            if let item = itemEntityController.valueForKeyPath("selection.self") as? Item {
                for tag in tokensToInsert {
                    services.tagger.addTag(tag, contentID: item.contentID, user: user)
                }
                for tag in tokensToRemove {
                    services.tagger.removeTag(tag, contentID: item.contentID, user: user)
                }
            }
        }
    }
    
    func urlsAndTagsFromTokens(tokens :Array<String>) -> (Array<NSURL>,Array<String>) {
        var urls = Array<NSURL>()
        var tags = Array<String>()
        
        for tokenString in tokens {
            if let url = validURLWithString(tokenString) {
                urls.append(url)
            }
            else {
                tags.append(tokenString)
            }
        }
        
        return(urls, tags)
    }
    
    func validURLWithString(string: String) -> NSURL? {
        var validURL: NSURL?  = nil
        if let url = NSURL.URLWithString(string) {
            if let host = url.host {
                validURL = url
            }
        } 
        return validURL
    }
    
    func deleteSelectedItem() {
        if let item = itemEntityController.valueForKeyPath("selection.self") as? Item {            
            var appDel = NSApplication.sharedApplication().delegate as AppDelegate
            var services = appDel.caturlogServices
            services.filer.deleteItem(item.contentID)
        }
    }

    func urlsForSelectedItem() -> (Array<String>) {
        var urls = Array<String>()
        if let item = itemEntityController.valueForKeyPath("selection.self") as? Item {            
            let characteristics = item.characteristics.allObjects
            for characteristic in characteristics {
                let charEntity = characteristic as Characteristic
                if (charEntity.name == "URL") {
                    urls.append(charEntity.value)
                }
            }
        }
        return urls
    }
    
}