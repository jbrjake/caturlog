//
//  ContentIDToNSImageTransformer.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/20/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Cocoa

class ItemToNSImageTransformer: NSValueTransformer {
    override class func transformedValueClass() -> (AnyClass!) {
        return NSImage.self
    }
    
    override class func allowsReverseTransformation() -> (Bool) {
        return false
    }
    
    override func transformedValue(value: AnyObject!) -> AnyObject! {
        let appDel = NSApplication.sharedApplication().delegate as AppDelegate
        let loader = appDel.caturlogServices.resourceLoader
        if let item = value as? Item {
            if let imageData = loader.getResourceSynchronously(item.contentID){
                return NSImage(data:imageData)
            }
            else {
                return NSImage()
            }
        }
        else {
            return NSImage()
        }
    }
}
