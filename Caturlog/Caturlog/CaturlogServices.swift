//
//  CaturlogServices.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/8/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation

// Get/insert for entities, eventually delete too
protocol EntityServiceProtocol {
    func getItem(contentID: String) -> (item: Item?)
    func getUser(userID: Int) -> (user: User?)
    func getTag(name: String) -> (tag: Tag?)
    func getCharacteristic(name: String, value:String) -> (characteristic: Characteristic?)
    func insertItem(contentID: String) -> (item: Item?)
    func insertUser(userID: Int) -> (user: User?)
    func insertTag(name: String) -> (tag: Tag?)
    func insertCharacteristic(name: String, value: String) -> (characteristic: Characteristic?)
}

protocol FileServiceProtocol {
    
    // Take a URL, download the data, and, if it's new: save to disk, create a     
    // corresponding Item based on the content hash, tie it to a URL characteristic, 
    // and return the Item. Otherwise, return the existing item. Or nil for failure.
    func storeAsItem(url: NSURL) -> Item?
    
    // Take a content hash and return a stored file's data if it exists
    func getFile(contentID: String) -> NSData?
}

protocol TagServiceProtocol {
    func addTag(tag: String, contentID: String, user: User) -> (Bool, NSError?)
    func itemsForTag(tag: String, withUser: User) -> (NSSet?)
}

protocol UserServiceProtocol {
    func getCurrentUserID() -> (userID: Int?)
    func getCurrentUser() -> (user: User?)
}
class CaturlogServices {
    
    let entityAccessor: EntityServiceProtocol
    let filer:          FileServiceProtocol
    let tagger:         TagServiceProtocol
    let user:           UserServiceProtocol
    
    init() {
        self.entityAccessor = EntityAccessor()
        self.filer = Filer()
        self.tagger = Tagger()
        self.user   = DummyUser()
    }
    
}

