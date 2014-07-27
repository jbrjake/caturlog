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
    
}