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
    
    func omnibarTokensChanged(newTokens: Array<String>) {
        let (urls,tags) = urlsAndTagsFromTokens(newTokens)
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices
        
        for url in urls {
            services.resourceStorer.storeResource(url)
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
    
}