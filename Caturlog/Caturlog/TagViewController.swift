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
    
    var oldTokens :Array<String> = []
    
    func bindTagField() {
        caturlogWindowController.viewModel?.itemEntityController.addObserver(self,
            forKeyPath: "selection.self", 
            options: nil, 
            context: nil
        )
    }
    
   override func observeValueForKeyPath(keyPath: String,
    ofObject object: AnyObject,
    change: [NSObject: AnyObject],
    context: UnsafeMutablePointer<Void>)
   {
        switch keyPath {
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
        caturlogWindowController.window?.makeFirstResponder(nil)
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        var textField = obj.object as NSTextField
        if(textField.isEqualTo(tagField)) {
            let tokenField = textField as NSTokenField
            let newTokens = tokenField.objectValue as Array<String>
            caturlogWindowController.viewModel?.tagTokensChanged(oldTokens, newTokens: newTokens)
            oldTokens = newTokens
        }
    }
    
}

