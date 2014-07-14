//
//  ResourceLoader.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/8/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation

class ResourceLoader: ResourceLoadingServiceProtocol {
    
    let backgroundQueue = NSOperationQueue()
    let cache = NSCache()
    
    init() {
        cache.totalCostLimit = 1024 * 120
    }
    
    func getResource(url: NSURL, completion: (data: NSData?) -> ()) {
        if( urlIsOnDisk(url)) {
            // Read and return it
            makeLocalRequest(url, completion: completion)
        }
        else {
            makeRemoteRequest(url, completion: completion)
        }
    }

    func appSupportURL () -> (NSURL) {
        var err: NSErrorPointer = nil
        var path = NSFileManager.defaultManager().URLForDirectory(
            NSSearchPathDirectory.ApplicationSupportDirectory,
            inDomain: NSSearchPathDomainMask.UserDomainMask,
            appropriateForURL: nil,
            create: true,
            error: err
        ).absoluteString
        path = path + "Caturlog/"
        
        println("App support url: \(path)")
        return NSURL.URLWithString(path)
    }
    

    // Once we can query core data for the image hash associated with a URL,
    // this will return the local path file:///path/to/AppSupportDir/items/imagehash.gif
    func localURLForRemoteURL(remoteURL: NSURL) -> NSURL {
        let localURL = NSURL()
        println("returning local URL: \(localURL)")
        return localURL
    }

    // For an item's data, this will return the local path file:///path/to/AppSupportDir/items/imagehash.gif
    func localURLForItem(item: NSData) -> NSURL {
        let localURL = self.appSupportURL().URLByAppendingPathComponent("items").URLByAppendingPathComponent(item.sha256()).URLByAppendingPathExtension("gif")
        
        println("returning local URL: \(localURL)")
        return localURL
    }
    
    func localDirectoryFromLocalURL(localURL: NSURL) -> String {
        var localDirectoryPath = localURL.absoluteString.stringByRemovingPercentEncoding
        localDirectoryPath = localDirectoryPath.stringByDeletingLastPathComponent;
        localDirectoryPath = localDirectoryPath.stringByReplacingOccurrencesOfString("file:/", withString: "", options: nil, range: nil)
        localDirectoryPath = "/" + localDirectoryPath + "/"
        return localDirectoryPath
    }
    
    // Eventually this will check Core Data
    func urlIsOnDisk(url: NSURL) -> Bool {
        return false
    }
    
    func writeFile( url: NSURL, data: NSData ) {
        var err: NSErrorPointer = nil
        let urlDir = url.URLByDeletingLastPathComponent
        let urlPath = url.absoluteString.stringByRemovingPercentEncoding.stringByReplacingOccurrencesOfString("file://",
            withString: "",
            options: nil,
            range: nil
        )
        
        println("trying to create dir \(urlDir) and file \(urlPath)")
        var writeState = NSFileManager.defaultManager().createDirectoryAtURL( urlDir,
            withIntermediateDirectories: true,
            attributes: nil,
            error: err
        )
        if(err) {
            println("err:\(err)")
        }
        else {
            println("no err, write succeeded with state: \(writeState)")
        }

        NSFileManager.defaultManager().createFileAtPath(urlPath,
            contents: data,
            attributes: nil
        )
    }
    
    func makeRemoteRequest(url: NSURL, completion: (data: NSData?) -> () ) {
        println("returning remote request")
        let request = NSMutableURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: backgroundQueue, completionHandler:{
            response, data, error in
            if error == nil {
                // Write the file to disk
                println("writing file to \(self.localURLForItem(data).absoluteString)")
                self.writeFile(self.localURLForItem(data), data: data)
                
                // Cache in memory
                self.cache.setObject(data, forKey: url, cost: data.length)
                
                // Then return it
                completion(data: data)
            }
            else {
                println("Failure loading item: \(error)")
                completion(data:nil)
            }
            return
            })
    }
    
    func makeLocalRequest(url: NSURL, completion:(data: NSData?) -> () ) {
        println("returning local resource: \(self.localURLForRemoteURL(url).absoluteString)")
        let data = NSData.dataWithContentsOfMappedFile(
            self.localURLForRemoteURL(url).absoluteString.stringByRemovingPercentEncoding.stringByReplacingOccurrencesOfString("file://", withString: "", options: nil, range: nil)) as? NSData
        cache.setObject(data, forKey: url, cost: data!.length)
        completion(
            data: data
        )
    }
}