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
    @IBOutlet var itemList:     NSTableView
    
    var moc: NSManagedObjectContext? {
        return (NSApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    }
    
    var viewModel: CaturlogWindowViewModel? = nil
    
    override func windowWillLoad() {
        super.windowWillLoad()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        viewModel = CaturlogWindowViewModel()

        if let column: NSTableColumn = itemList.tableColumns[itemList.columnWithIdentifier("ItemImageColumnID")]
            as? NSTableColumn
        {
            column.bind(NSValueBinding,
                toObject: viewModel?.itemEntityController,
                withKeyPath: "arrangedObjects",
                options: [
                    NSValueTransformerNameBindingOption: "Caturlog.ItemToNSImageTransformer",
                    NSConditionallySetsEnabledBindingOption: false
                ]
            )
        }
        
        imageView.bind(NSValueBinding,
            toObject: viewModel?.itemEntityController,
            withKeyPath: "selection.self",
            options: [
                NSValueTransformerNameBindingOption: "Caturlog.ItemToNSImageTransformer",
                NSConditionallySetsEnabledBindingOption: false
            ]
        )
        
    }    
}