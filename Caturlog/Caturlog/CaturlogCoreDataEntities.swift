//
//  CaturlogCoreDataEntities.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/14/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import CoreData

@objc(UserItemTag)
class UserItemTag: NSManagedObject {
    @NSManaged var timestamp:       NSDate
    
    @NSManaged var item:            Item
    @NSManaged var tag:             Tag
    @NSManaged var user:            User
}

@objc(User)
class User: NSManagedObject {
    @NSManaged var name:            String
    @NSManaged var userID:          String
    
    @NSManaged var items:           NSSet
    @NSManaged var userItemTags:    NSSet
}

@objc(Item)
class Item: NSManagedObject {
    @NSManaged var contentID:       String

    @NSManaged var characteristics: NSSet
    @NSManaged var tags:            NSSet
    @NSManaged var users:           NSSet
    @NSManaged var userItemTags:    NSSet
    
}

@objc(Tag)
class Tag: NSManagedObject {
    @NSManaged var name:            String
    
    @NSManaged var items:           NSSet
    @NSManaged var userItemTags:    NSSet
    
}

@objc(Characteristic)
class Characteristic: NSManagedObject {
    @NSManaged var name:            String
    @NSManaged var value:           String

    @NSManaged var items:           NSSet
}