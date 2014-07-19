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

    @IBOutlet var itemTable :NSTableView
    @IBOutlet var imageView :NSImageView
    @IBOutlet var tagField :NSTokenField
    
    override func windowWillLoad() {
        super.windowWillLoad()
    }
    
}