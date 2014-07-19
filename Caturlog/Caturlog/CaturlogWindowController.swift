//
//  CaturlogWindowController.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/18/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit

class CaturlogWindowController : NSWindowController {

    @IBOutlet var omnibar :NSTokenField
    @IBOutlet var itemTable :NSTableView
    @IBOutlet var imageView :NSImageView
    @IBOutlet var tagField :NSTokenField
    
    override func windowWillLoad() {
        super.windowWillLoad()
    }
    
    override func controlTextDidEndEditing(obj: NSNotification!) {
        var textField :NSTextField = obj.object as NSTextField
        if( textField.isEqualTo(omnibar)) {
            if let url = NSURL.URLWithString(omnibar.stringValue) {
                addResource(url)                
            }
        }
    }

    func addResource(url: NSURL) {
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices
        services.resourceLoader.getResource(url, completion: {
            data in
            if data != nil {
                services.resourceStorer.storeResource(data!.sha256(), fromURL:url)
            }
        })
    }
    
}


extension CaturlogWindowController : NSTokenFieldDelegate {
    
}
