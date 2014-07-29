//
//  CaturlogCoreDataEntities.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/14/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import CoreData

class UserItemTag: NSManagedObject {
    @NSManaged var timestamp:       NSDate
    
    @NSManaged var item:            Item
    @NSManaged var tag:             Tag
    @NSManaged var user:            User
}

class User: NSManagedObject {
    @NSManaged var name:            String
    @NSManaged var userID:          Int
    
    @NSManaged var items:           NSMutableSet
    @NSManaged var userItemTags:    NSMutableSet
}

class Item: NSManagedObject {
    @NSManaged var contentID:       String

    @NSManaged var characteristics: NSMutableSet
    @NSManaged var tags:            NSMutableSet
    @NSManaged var users:           NSMutableSet
    @NSManaged var userItemTags:    NSMutableSet
    
}

class Tag: NSManagedObject {
    @NSManaged var name:            String
    
    @NSManaged var items:           NSMutableSet
    @NSManaged var userItemTags:    NSMutableSet
    
}

class Characteristic: NSManagedObject {
    @NSManaged var name:            String
    @NSManaged var value:           String

    @NSManaged var items:           NSMutableSet
}