//
//  CaturlogServices.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/8/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation

protocol EntityAccessingServiceProtocol {
    func getItem(contentID: String) -> (item: Item?)
    func getUser(userID: Int) -> (user: User?)
    func getTag(name: String) -> (tag: Tag?)
    func getCharacteristic(name: String, value:String) -> (characteristic: Characteristic?)
    func insertItem(contentID: String) -> (item: Item?)
    func insertUser(userID: Int) -> (user: User?)
    func insertTag(name: String) -> (tag: Tag?)
    func insertCharacteristic(name: String, value: String) -> (characteristic: Characteristic?)
}

protocol ResourceLoadingServiceProtocol {
    func getResource(url: NSURL, completion: (data: NSData?) -> ())
    func getResourceSynchronously(contentID: String) -> NSData?
}

protocol ResourceStoringServiceProtocol {
    func storeResource(url: NSURL)
}

protocol ResourceTaggingServiceProtocol {
    func addTag(tag: String, contentID: String, user: User) -> (Bool, NSError?)
    func itemsForTag(tag: String, withUser: User) -> (NSSet?)
}

protocol UserServiceProtocol {
    func getCurrentUserID() -> (userID: Int?)
    func getCurrentUser() -> (user: User?)
}

class CaturlogServices {
    
    let entityAccessor: EntityAccessingServiceProtocol
    let resourceLoader: ResourceLoadingServiceProtocol
    let resourceStorer: ResourceStoringServiceProtocol
    let resourceTagger: ResourceTaggingServiceProtocol
    let resourceUser:   UserServiceProtocol
    
    init() {
        self.entityAccessor = EntityAccessor()
        self.resourceLoader = ResourceLoader()
        self.resourceStorer = ResourceStorer()
        self.resourceTagger = ResourceTagger()
        self.resourceUser   = DummyUser()
    }
    
}

