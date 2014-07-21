//
//  OmnibarViewController.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/18/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Cocoa

class OmnibarViewController :NSViewController, NSTextFieldDelegate {

    @IBOutlet var omnibar :NSTokenField

    override func controlTextDidEndEditing(obj: NSNotification!) {
        var textField :NSTextField = obj.object as NSTextField
        if( textField.isEqualTo(omnibar) ) {
            let tokenField = textField as NSTokenField
            let tokens = tokenField.objectValue as Array<String>
            let (urls,tags) = urlsAndTagsFromTokens(tokens)
            for url in urls {
                addResource(url)
            }
        }
    }
    
    func urlsAndTagsFromTokens(tokens :Array<String>) -> (Array<NSURL>,Array<String>) {
        var urls = Array<NSURL>()
        var tags = Array<String>()
        for tokenString in tokens {
            if let url = NSURL.URLWithString(tokenString) {
                urls.append(url)
            }
            else {
                tags.append(tokenString)
            }
        }
        return(urls, tags)
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
