//
//  CaturlogImageView.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 9/25/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import AppKit

@objc(CaturlogImageView)
class CaturlogImageView: GIFView {

    override func drawRect(dirtyRect: NSRect) {
        if let size = gifSize {
            let aspectSize = aspectFit(size, boundingSize: dirtyRect.size)
            let aspectFrame = center(aspectSize, inFrame: dirtyRect)
            if let convertedFrame = self.superview?.convertRect(aspectFrame, fromView: self) {
                self.frame = convertedFrame
                self.layer?.frame = convertedFrame
                self.layer?.bounds = convertedFrame
            }
        }
        super.drawRect(dirtyRect)
    }
    
    func aspectFit(aspectRatio: CGSize, boundingSize: CGSize) -> (CGSize) {
        var fitSize = boundingSize
        let mW = boundingSize.width / aspectRatio.width
        let mH = boundingSize.height / aspectRatio.height
        if (mH < mW) {
            fitSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
        }
        else {
            fitSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
        }
        return fitSize
    }
    
    func center(size: CGSize, inFrame: CGRect) -> (CGRect){
        var centeredFrame = CGRectMake(0, 0, size.width, size.height)
        let widthDelta = inFrame.size.width - size.width
        let heightDelta = inFrame.size.height - size.height
        centeredFrame.origin.x = widthDelta/2.0
        centeredFrame.origin.y = heightDelta/2.0
        return centeredFrame
    }
    
}