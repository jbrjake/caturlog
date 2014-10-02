//
//  ItemToTagStringsTransformer.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/31/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Cocoa

class ItemToTagStringsTransformer: NSValueTransformer {
    override class func transformedValueClass() -> (AnyClass) {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> (Bool) {
        return false
    }
    
    override func transformedValue(value: AnyObject!) -> AnyObject {
        let appDel = NSApplication.sharedApplication().delegate as AppDelegate
        let tagger = appDel.caturlogServices.tagger
        if let item = value as? Item {
            if let tags = tagger.tagNamesForItem(item){
                return tags
            }
            else {
                return NSArray()
            }
        }
        else {
            return NSArray()
        }
    }
}