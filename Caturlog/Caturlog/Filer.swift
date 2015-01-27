//
//  Filer.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/14/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit
import CoreData

class Filer: FileServiceProtocol {

    // Goes right from a URL to an Item saved in the moc
    func storeAsItem(url: NSURL, completion:(Item?) -> ()) {
        var appDel = NSApplication.sharedApplication().delegate as AppDelegate
        var services = appDel.caturlogServices
        var result = false, error: NSErrorPointer? = nil

        getResource(url, completion: {
            data in
            if data != nil {
                var (maybeItem, result, maybeErr) = self.storeResource(data!.sha256(), fromURL:url)
                println("item:\(maybeItem) result:\(result) err:\(maybeErr)")
                completion(maybeItem)
            }
            else {
                completion(nil)
            }
        })        
    }

    /*Add the item if it isn't present, add the URL as a characteristic if it isn't present,
      and associate the two of them together. */
    func storeResource(contentID: String, fromURL: NSURL) -> (Item?, Bool, NSErrorPointer?) {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        if let moc = appDelegate.managedObjectContext {
            if let item = itemForContentID(contentID)? {
                if let char = characteristicForURL(fromURL) {
                    var charItems = char.mutableSetValueForKey("items")
                    var itemChars = item.mutableSetValueForKey("characteristics")
                    charItems.addObject(item)
                    itemChars.addObject(char)
                }

                // Save out in this scope in case the item or char are new inserts
                let err: NSErrorPointer = nil
                let saveWorked = moc.save(err)
                if(err != nil) {
                    return (nil, saveWorked, err)
                }
                else {
                    return (item, saveWorked, nil)
                }
            }
        }
        
        return (nil, false, nil)
    }

    func deleteItem(contentID: String) {
        // Get the local url
        let itemURL = localURLForContentID(contentID)

        // Delete the entity
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDelegate.caturlogServices
        services.entityAccessor.removeItem(contentID)
        
        // Delete the file
        deleteFile(itemURL)
    }

    func itemForContentID(contentID: String) -> Item? {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDelegate.caturlogServices
        if let entity = services.entityAccessor.getItem(contentID)? {
            return entity
        }
        else if let entity = services.entityAccessor.insertItem(contentID)? {
            return entity
        }
        
        return nil

    }

    // Return an existing or new Characteristic? with name "URL" and value url
    func characteristicForURL(url: NSURL) -> Characteristic? {
        
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let services = appDelegate.caturlogServices
        if let entity = services.entityAccessor.getCharacteristic("URL", value: url.absoluteString!)? {
            return entity
        }
        else if let entity = services.entityAccessor.insertCharacteristic("URL", value: url.absoluteString!)? {
            return entity
        }
        
        return nil
    }

    let backgroundQueue = NSOperationQueue()
    let cache = NSCache()
    
    init() {
        cache.totalCostLimit = 1024 * 120
    }
    
    func getResource(url: NSURL, completion: (data: NSData?) -> ()) {
        if( urlIsOnDisk(url)) {
            // Read and return it
            completion(data: makeLocalRequest(url))
        }
        else {
            makeRemoteRequest(url, completion: completion)
        }
    }
    
    func getFile(contentID: String) -> NSData? {
        var returnData: NSData? = nil
        returnData = makeLocalRequestWithLocalURL(localURLForContentID(contentID))
        return returnData
    }
    
    func getFilePath(contentID: String) -> NSURL? {
        return localURLForContentID(contentID)
    }
    
    // Return the first fetch result for the named managed object matching the given predicate
    func fetchEntity(name: String, predicate: NSPredicate) -> NSManagedObject? {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        if let moc = appDelegate.managedObjectContext {
            let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: moc)
            var request = NSFetchRequest()
            request.entity = entity
            request.predicate = predicate
            var err: NSErrorPointer = nil
            let results = moc.executeFetchRequest(request, error: err)
            if(results!.count > 0) {
                return results![0] as? NSManagedObject
            }
        }
        
        return nil
    }
    
    func appSupportURL () -> (NSURL) {
        var err: NSErrorPointer = nil
        var path = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory,
            inDomain: NSSearchPathDomainMask.UserDomainMask,
            appropriateForURL: nil,
            create: true,
            error: err
            )!.absoluteString
        path = path! + "Caturlog/"
        
        return NSURL(string:path!)!
    }
    
    
    // Once we can query core data for the image hash associated with a URL,
    // this will return the local path file:///path/to/AppSupportDir/items/imagehash.gif
    func localURLForRemoteURL(remoteURL: NSURL) -> NSURL {
        let localURL = NSURL()
        return localURL
    }
    
    // For an item's data, this will return the local path file:///path/to/AppSupportDir/items/imagehash.gif
    func localURLForItem(item: NSData) -> NSURL {
        let localURL = localURLForContentID(item.sha256())
        return localURL
    }
    
    func localURLForContentID(contentID:String) -> NSURL {
        let localURL = self.appSupportURL()
            .URLByAppendingPathComponent("items")
            .URLByAppendingPathComponent(contentID)
            .URLByAppendingPathExtension("gif")        
        return localURL        
    }
    
    func localDirectoryFromLocalURL(localURL: NSURL) -> String {
        var localDirectoryPath = localURL.absoluteString!.stringByRemovingPercentEncoding
        localDirectoryPath = localDirectoryPath!.stringByDeletingLastPathComponent;
        localDirectoryPath = localDirectoryPath!
            .stringByReplacingOccurrencesOfString("file:/", withString: "", options: nil, range: nil)
        localDirectoryPath = "/" + localDirectoryPath! + "/"
        return localDirectoryPath!
    }
    
    // Eventually this will check Core Data
    func urlIsOnDisk(url: NSURL) -> Bool {
        return false
    }
    
    func writeFile(url: NSURL, data: NSData) {
        var err: NSErrorPointer = nil
        let urlDir = url.URLByDeletingLastPathComponent
        let urlPath = url.absoluteString!.stringByRemovingPercentEncoding!
            .stringByReplacingOccurrencesOfString("file://",
                withString: "",
                options:    nil,
                range:      nil
        )
        
        var writeState = NSFileManager.defaultManager().createDirectoryAtURL(urlDir!,
            withIntermediateDirectories: true,
            attributes: nil,
            error: err
        )
        if(err != nil) {
            println("err:\(err)")
        }
        
        NSFileManager.defaultManager().createFileAtPath(urlPath,
            contents: data,
            attributes: nil
        )
    }
    
    func deleteFile(url: NSURL) {
        var err: NSErrorPointer = nil
        NSFileManager.defaultManager().removeItemAtURL(url, error: err)
        if(err != nil) {
            println("err:\(err)")
        }
    }
    
    func makeRemoteRequest(url: NSURL, completion: (data: NSData?) -> ()) {
        let request = NSMutableURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request,
            queue: backgroundQueue,
            completionHandler: {
                response, data, error in
                if error == nil {
                    // Write the file to disk
                    self.writeFile(self.localURLForItem(data), data: data)
                    
                    // Cache in memory
                    self.cache.setObject(data, forKey: url, cost: data.length)
                    
                    // Then return it
                    completion(data: data)
                }
                else {
                    println("Failure loading item: \(error)")
                    completion(data: nil)
                }
            }
        )
    }
    
    func makeLocalRequest(url: NSURL) -> (NSData?) {
        let localURL = self.localURLForRemoteURL(url)
        return makeLocalRequestWithLocalURL(localURL)
    }
    
    func makeLocalRequestWithLocalURL(url: NSURL) -> (NSData?) {
        let localPath = url.absoluteString!.stringByRemovingPercentEncoding!
            .stringByReplacingOccurrencesOfString("file://", withString: "", options: nil, range: nil)
        let data = NSData.dataWithContentsOfMappedFile(localPath) as? NSData
        cache.setObject(data!, forKey: url, cost: data!.length)
        return data
    }

}