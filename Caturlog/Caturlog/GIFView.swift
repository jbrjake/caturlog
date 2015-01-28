//
//  GIFView.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 1/15/15.
//  Copyright (c) 2015 Jonathon Rubin. All rights reserved.
//

import Foundation
import AppKit

@objc(GIFView)
class GIFView : NSImageView {
    var gifPath: NSURL = NSURL() {
        didSet {
            displayGIF()
        }
    } 
    
    var gifData: CGImageSourceRef? = nil
    var frames: Array<CGImageRef>? = nil
    var gifSize :CGSize? = nil
    
    // protect against gifData/gifPath changing out from under us
    var displaySemaphore : dispatch_semaphore_t = dispatch_semaphore_create(1)
    
    func displayGIF() {
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 5.0
        self.layer?.contentsGravity = kCAGravityResizeAspect
        self.layer?.backgroundColor = NSColor.redColor().CGColor
        if let imageData: NSData = NSData(contentsOfURL: gifPath) {
            dispatch_semaphore_wait(displaySemaphore, DISPATCH_TIME_FOREVER)
            let options = [kCGImageSourceShouldCacheImmediately as String: true]
            gifData = CGImageSourceCreateWithData(imageData, options)
            if let props = CGImageSourceCopyPropertiesAtIndex(gifData?, 0, [:]) as NSDictionary? {
                let width = props[kCGImagePropertyPixelWidth as String] as NSNumber
                let height = props[kCGImagePropertyPixelHeight as String] as NSNumber
                let cgWidth = CGFloat(width)
                let cgHeight = CGFloat(height)
                gifSize = CGSize(width: cgWidth, height: cgHeight)
            }
            
            let frameCount = CGImageSourceGetCount(gifData)
            println("frame count is \(frameCount)")
            frames = Array<CGImageRef>()
            var totalDuration: CFTimeInterval = 0
            for i in 0...frameCount-1 {
                let frameDuration = durationOfFrame(i)
                totalDuration += frameDuration
                let frame = CGImageSourceCreateImageAtIndex(gifData, i, [:])
                frames?.append(frame)
            }
            
            let animation = CAKeyframeAnimation(keyPath: "contents")
            animation.calculationMode = kCAAnimationDiscrete
            animation.values = self.frames?
            self.frames = nil
            animation.duration = totalDuration
            animation.repeatCount = Float.infinity

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.layer?.addAnimation(animation, forKey: "contents")
                return
            })
            
            dispatch_semaphore_signal(self.displaySemaphore)
        }

    }
    
    // Adapted from http://stackoverflow.com/a/17824564
    // and from YFGIFImageView.m in Yang Fei's UIImageView-PlayGIF project: 
    // https://github.com/yfme/UIImageView-PlayGIF
    func durationOfFrame(atIndex: UInt) -> CFTimeInterval {
        if let gif = gifData {
            let dictRef = CGImageSourceCopyPropertiesAtIndex(gif, atIndex, [:]) as NSDictionary
            
            if let gifDict = dictRef[kCGImagePropertyGIFDictionary as String] as? NSDictionary {
                var unclampedDelayTime :CFTimeInterval? = nil
                var clampedDelayTime :CFTimeInterval? = nil
                if(gifDict[kCGImagePropertyGIFUnclampedDelayTime as String] != nil) {                
                    unclampedDelayTime = gifDict[kCGImagePropertyGIFUnclampedDelayTime as String] as CFTimeInterval?
                }
                if(gifDict[kCGImagePropertyGIFDelayTime as String] != nil) {
                    clampedDelayTime = gifDict[kCGImagePropertyGIFDelayTime as String] as CFTimeInterval?
                }
                
                var delay: CFTimeInterval = 1/24.0 as CFTimeInterval
                if (unclampedDelayTime != nil) {
                    delay = unclampedDelayTime!
                }
                else if (clampedDelayTime != nil) {
                    delay = clampedDelayTime!
                }
                
                if (delay < 0.011) {
                    delay = 0.100
                }
                return delay
            }
            else {
                return 1 as CFTimeInterval
            }
        }
        else {
            return 1 as CFTimeInterval
        }
    }
}