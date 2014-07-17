//
//  CaturlogServices.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/8/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation

protocol ResourceLoadingServiceProtocol {
    func getResource(url: NSURL, completion: (data: NSData?) -> () )
}

protocol ResourceStoringServiceProtocol {
    func storeResource(contentID: String, fromURL: NSURL) -> (Bool, NSErrorPointer?)
}

protocol ResourceTaggingServiceProtocol {
    func addTag(tag: String, forContentID: String, andUser: User) -> (Bool, NSError?)
    func itemsForTag(tag: String, withUser: User) -> (NSSet?)
}

class CaturlogServices {
    
    let resourceLoader : ResourceLoadingServiceProtocol
    let resourceStorer : ResourceStoringServiceProtocol
    
    init() {
        self.resourceLoader = ResourceLoader()
        self.resourceStorer = ResourceStorer()
    }
    
}

