//
//  ContentIDToCGImageSourceRefTransformer.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 1/18/15.
//  Copyright (c) 2015 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit

class ItemToFilePathTransformer: NSValueTransformer {
    override class func transformedValueClass() -> (AnyClass) {
        return NSURL.self
    }
    
    override class func allowsReverseTransformation() -> (Bool) {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        let appDel = NSApplication.sharedApplication().delegate as AppDelegate
        let filer = appDel.caturlogServices.filer
        if let item = value as? Item {            
            return filer.getFilePath(item.contentID)
        }
        else {
            return NSBundle.mainBundle().pathForResource("help", ofType: "gif")
        }
    }
}
