//
//  CaturlogServices.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/8/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation

protocol ResourceLoadingServiceProtocol {
    
    func getResource(url: NSURL, completion: (data: NSData?) -> () )
    
}

class CaturlogServices {
    
    let resourceLoader : ResourceLoadingServiceProtocol
    
    init() {
        self.resourceLoader = ResourceLoader()
    }
    
}

