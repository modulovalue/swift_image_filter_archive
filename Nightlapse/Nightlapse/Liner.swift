//
//  Liner.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 28.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import Foundation
import GPUImage

class Liner {
    
    let transformFilter = GPUImageTransformFilter()
    let zoomFilter = GPUImageTransformFilter()
    
    init() {
        transformFilter.affineTransform = CGAffineTransformMakeRotation(0)
        zoomFilter.affineTransform = CGAffineTransformMakeScale(0,0)
        
        transformFilter.addTarget(zoomFilter)
    }
    
    func makeLiner( x: CGFloat, liner: Bool) {
    
        var orientation = UIApplication.sharedApplication().statusBarOrientation
        
        var xx = (orientation == UIInterfaceOrientation.LandscapeLeft || orientation == UIInterfaceOrientation.LandscapeRight  ) ? 1 - (1 - x) : x
        
        var xfit = x
        xfit += (CGFloat(DegreesToRadians(360)) * xx * 0.25)
        xfit /= 2
        
        if(fabs(x) > 0.7) {
            xfit *= 1 - (x - 0.7)
        }
        
        transformFilter.affineTransform = CGAffineTransformMakeRotation(liner == true ? xfit : 0)
        
        let val = liner == true ? Float.clamp(1.0, max: 10.0, val: fabs(x) + 1.15) : 1
        
        zoomFilter.affineTransform = CGAffineTransformMakeScale(val, val)
        
    }
    
    func getFirstFilter() -> GPUImageTransformFilter {
        return transformFilter
    }
    func getFilter() -> GPUImageTransformFilter {
        return zoomFilter
    }
    
    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    func RadiansToDegrees (value:Double) -> Double {
        return value * 180.0 / M_PI
    }
}