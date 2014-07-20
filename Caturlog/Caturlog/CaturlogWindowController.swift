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

class CaturlogWindowController : NSWindowController {

    @IBOutlet var itemTable :NSTableView
    @IBOutlet var imageView :NSImageView
    @IBOutlet var tagField :NSTokenField
    
    override func windowWillLoad() {
        super.windowWillLoad()
    }
}


class ContentIDToNSImageTransformer :NSValueTransformer {
    override class func transformedValueClass() -> (AnyClass!) {
        return NSImage.self
    }
    
    override class func allowsReverseTransformation() -> (Bool) {
        return false
    }
    
    override func transformedValue(value: AnyObject!) -> AnyObject! {
        let appDel = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDel.caturlogServices
        let loader = services.resourceLoader
        return NSImage(data:loader.getResourceSynchronously(value as String))
    }
}
