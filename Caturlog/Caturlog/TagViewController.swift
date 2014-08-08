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
        tagField.bind(NSValueBinding,
            toObject: caturlogWindowController.viewModel?.itemEntityController,
            withKeyPath: "selection.self",
            options: [
                NSValueTransformerNameBindingOption: "Caturlog.ItemToTagStringsTransformer",
                NSConditionallySetsEnabledBindingOption: false
            ]
        )        
    }
    
    override func controlTextDidChange(obj: NSNotification!) {
        var textField = obj.object as NSTextField
        
        if(textField.isEqualTo(tagField)) {
            let tokenField = textField as NSTokenField
            let tokens = tokenField.objectValue as Array<String>
            
            caturlogWindowController.viewModel?.tagTokensChanged(tokens)            
        }
    }
    
}

