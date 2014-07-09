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
    func getResource(url: NSURL, completion: (data: NSData?) -> ()) {
        let request = NSMutableURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: backgroundQueue, completionHandler:{
            response, data, error in
            if error == nil {
                completion(data: data)
            }
            else {
                println("Failure loading image: \(error)")
                completion(data:nil)
            }
            return
        })
    }
}