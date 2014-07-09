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
        
        println("Sending async request for \(url)")
        NSURLConnection.sendAsynchronousRequest(request, queue: backgroundQueue, completionHandler:{
            response, data, error in
            println("got response for request: \(response), \(data), \(error)")
            if error == nil {
                println("calling completion")
                completion(data: data)
                println("completion called")
            }
            return
        })
    }
}