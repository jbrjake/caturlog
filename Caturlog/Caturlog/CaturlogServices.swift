//
//  CaturlogServices.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/8/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation

protocol ResourceLoadingServiceProtocol {
    func getResource(url: NSURL, completion: (data: NSData?) -> ())
    func getResourceSynchronously(contentID: String) -> NSData?
}

protocol ResourceStoringServiceProtocol {
    func storeResource(url: NSURL)
}

protocol ResourceTaggingServiceProtocol {
    func addTag(tag: String, forContentID: String, andUser: User) -> (Bool, NSError?)
    func itemsForTag(tag: String, withUser: User) -> (NSSet?)
}

protocol UserServiceProtocol {
    func getCurrentUserID() -> (userID: String?)
    func getCurrentUser() -> (user: User?)
}

class CaturlogServices {
    
    let resourceLoader: ResourceLoadingServiceProtocol
    let resourceStorer: ResourceStoringServiceProtocol
    let resourceUser: UserServiceProtocol
    init() {
        self.resourceLoader = ResourceLoader()
        self.resourceStorer = ResourceStorer()
        self.resourceUser = DummyUser()
    }
    
}

