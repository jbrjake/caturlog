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
    
    let itemArrayController: NSArrayController
    
    init() {
        let moc = (NSApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
        itemArrayController = NSArrayController(content: nil)
        itemArrayController.managedObjectContext = moc
        itemArrayController.bind("managedObjectContext", toObject: moc, withKeyPath: "self", options: nil)
        itemArrayController.entityName = "Item"
        itemArrayController.automaticallyPreparesContent = true
        itemArrayController.avoidsEmptySelection = true
        itemArrayController.preservesSelection = true
        itemArrayController.selectsInsertedObjects = true
        itemArrayController.clearsFilterPredicateOnInsertion = true
        itemArrayController.usesLazyFetching = false
        itemArrayController.fetch(nil)
    }
    
}