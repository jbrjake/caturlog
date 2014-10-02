//
//  OmnibarViewController.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/18/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Cocoa

class OmnibarViewController :NSViewController, NSTextFieldDelegate {

    @IBOutlet var omnibar: NSTokenField!
    @IBOutlet var caturlogWindowControler :CaturlogWindowController!
        
    override func controlTextDidChange(obj: NSNotification) {
        var textField = obj.object as NSTextField
        
        if(textField.isEqualTo(omnibar)) {
            let tokenField = textField as NSTokenField
            let tokens = tokenField.objectValue as Array<String>
            
            caturlogWindowControler.viewModel?.omnibarTokensChanged(tokens,
                begin: {
                    self.caturlogWindowControler.downloadBegan()
                },
                completion:{
                    urls, tags in
                    for url: NSURL in urls {
                        textField.stringValue = textField.stringValue.stringByReplacingOccurrencesOfString(url.absoluteString!, withString:"", options: NSStringCompareOptions.CaseInsensitiveSearch, range:nil)
                    }
                    self.caturlogWindowControler.downloadCompleted()
                }
            )            
        }
    }
        
}
