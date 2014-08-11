//
//  TagViewController.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 8/7/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Cocoa

class TagViewController :NSViewController, NSTextFieldDelegate {
    
    @IBOutlet var tagField: NSTokenField!
    @IBOutlet var caturlogWindowController: CaturlogWindowController!
    
    func bindTagField() {
        caturlogWindowController.viewModel?.itemEntityController.addObserver(self,
            forKeyPath: "selection.self", 
            options: nil, 
            context: nil
        )
    }
    
    override func observeValueForKeyPath(keyPath: String!,
        ofObject object: AnyObject!,
        change: [NSObject : AnyObject]!,
        context: UnsafePointer<()>
    ) {
        switch keyPath! {
        case "selection.self":
            updateTagsFromModel()
            break
        default:
            break
        }
    }
    
    func updateTagsFromModel() {
        tagField.objectValue = ItemToTagStringsTransformer().transformedValue(
            caturlogWindowController.viewModel?.itemEntityController.valueForKeyPath("selection.self")
        )
    }
    
    override func controlTextDidEndEditing(obj: NSNotification!) {
        var textField = obj.object as NSTextField
        if(textField.isEqualTo(tagField)) {
            let tokenField = textField as NSTokenField
            let tokens = tokenField.objectValue as Array<String>            
            caturlogWindowController.viewModel?.tagTokensChanged(tokens)            
        }
    }
    
}

