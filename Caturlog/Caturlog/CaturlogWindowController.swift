//
//  CaturlogWindowController.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/18/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit
import CoreData

class CaturlogWindowController: NSWindowController {

    @IBOutlet var imageView:    NSImageView
    @IBOutlet var tagField:     NSTokenField

    var moc: NSManagedObjectContext? {
        return (NSApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    }
    
    override func windowWillLoad() {
        super.windowWillLoad()
    }
}