//
//  CaturlogImageView.swift
//  Caturlog
//
//  Created by Jonathon Rubin on 9/25/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

import AppKit

class CaturlogImageView: NSImageView {
    override func drawRect(dirtyRect: NSRect) {
        if let imageSize = image?.size {
            let aspectSize = aspectFit(imageSize, boundingSize: dirtyRect.size)
            let aspectFrame = center(aspectSize, inFrame: dirtyRect)
            NSGraphicsContext.saveGraphicsState()
            let path = NSBezierPath(roundedRect: aspectFrame, xRadius: 5, yRadius: 5)
            path.addClip()
            image.drawInRect(aspectFrame, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
        }
    }
    
    func aspectFit(aspectRatio: CGSize, boundingSize: CGSize) -> (fitSize: CGSize) {
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
    
    func center(size: CGSize, inFrame: CGRect) -> (centeredFrame: CGRect){
        var centeredFrame = CGRectMake(0, 0, size.width, size.height)
        let widthDelta = inFrame.size.width - size.width
        let heightDelta = inFrame.size.height - size.height
        centeredFrame.origin.x = widthDelta/2
        centeredFrame.origin.y = heightDelta/2
        return centeredFrame
    }
}
