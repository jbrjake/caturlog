//
//  NSData+CommonDigest.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 7/13/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import Foundation

extension NSData {
    
    func sha256() -> String! {
        
        let result = UnsafePointer<CUnsignedChar>.alloc(Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256(self.bytes, UInt32(self.length), result)

        var hash = NSMutableString()
        for i in 0...Int(CC_SHA256_DIGEST_LENGTH) {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return String(hash)
    }
    
}
