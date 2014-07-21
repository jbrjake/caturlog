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
    
    func getResourceSynchronously(contentID: String) -> NSData? {
        var returnData: NSData? = nil
        makeLocalRequestWithLocalURL(
            localURLForContentID(contentID), completion: {
                returnData = $0
            }
        )
        return returnData
    }

    func appSupportURL () -> (NSURL) {
        var err: NSErrorPointer = nil
        var path = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory,
            inDomain: NSSearchPathDomainMask.UserDomainMask,
            appropriateForURL: nil,
            create: true,
            error: err
        ).absoluteString
        path = path + "Caturlog/"
        
        return NSURL.URLWithString(path)
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
        var localDirectoryPath = localURL.absoluteString.stringByRemovingPercentEncoding
        localDirectoryPath = localDirectoryPath.stringByDeletingLastPathComponent;
        localDirectoryPath = localDirectoryPath
            .stringByReplacingOccurrencesOfString("file:/", withString: "", options: nil, range: nil)
        localDirectoryPath = "/" + localDirectoryPath + "/"
        return localDirectoryPath
    }
    
    // Eventually this will check Core Data
    func urlIsOnDisk(url: NSURL) -> Bool {
        return false
    }
    
    func writeFile(url: NSURL, data: NSData) {
        var err: NSErrorPointer = nil
        let urlDir = url.URLByDeletingLastPathComponent
        let urlPath = url.absoluteString.stringByRemovingPercentEncoding
            .stringByReplacingOccurrencesOfString("file://",
                withString: "",
                options:    nil,
                range:      nil
            )
        
        var writeState = NSFileManager.defaultManager().createDirectoryAtURL(urlDir,
            withIntermediateDirectories: true,
            attributes: nil,
            error: err
        )
        if(err) {
            println("err:\(err)")
        }

        NSFileManager.defaultManager().createFileAtPath(urlPath,
            contents: data,
            attributes: nil
        )
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
    
    func makeLocalRequest(url: NSURL, completion:(data: NSData?) -> ()) {
        let localURL = self.localURLForRemoteURL(url)
        makeLocalRequestWithLocalURL(localURL, completion: completion)
    }
    
    func makeLocalRequestWithLocalURL(url: NSURL, completion:(data: NSData?) -> ()) {
        let localPath = url.absoluteString.stringByRemovingPercentEncoding
            .stringByReplacingOccurrencesOfString("file://", withString: "", options: nil, range: nil)
        let data = NSData.dataWithContentsOfMappedFile(localPath) as? NSData
        cache.setObject(data, forKey: url, cost: data!.length)
        completion(
            data: data
        )
    }

}