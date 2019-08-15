//
//  wanderlust.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 22.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

class Wanderlust: Filter {
    
    var temp: Float = 45.0
    let displayname = "Wanderlust"
    let startmix: CGFloat = 1
    
    var lookupFilterImage: GPUImagePicture
    let lookupFilter: GPUImageLookupFilter
    
    let blend: GPUImageAlphaBlendFilter
    
    let contrastFilter: GPUImageContrastFilter
    
    init() {
        
        blend = GPUImageAlphaBlendFilter()
        blend.mix = startmix
        
        contrastFilter = GPUImageContrastFilter()
        contrastFilter.contrast = startmix * 4
        
        lookupFilter = GPUImageLookupFilter()
        lookupFilterImage = GPUImagePicture(image: UIImage(named: "wanderlust"))
        
    }
    
    var linerFilter = Liner()
    
    func doFilter(origimg: GPUImagePicture, view: GPUImageView!, liner: Bool, x: CGFloat, y: CGFloat, z: CGFloat) -> UIImage! {
        
        if view == nil {
            linerFilter.getFilter().removeAllTargets()
        }

        
        contrastFilter.contrast = Float.clamp(0.6, max: 4.0, val: fabs(y * 4)-0.5)
        blend.mix = Float.clamp(0.1, max: 0.4, val: fabs(y)-0.5)
             
         contrastFilter.addTarget(blend)
        
          origimg.addTarget(contrastFilter)
          origimg.processImage()
        
         lookupFilter.addTarget(blend)
           origimg.addTarget(lookupFilter)
           origimg.processImage()
        
           lookupFilterImage.addTarget(lookupFilter)
           lookupFilterImage.processImage()
        

        
        linerFilter.makeLiner(x, liner: liner)
        
        blend.addTarget(linerFilter.getFirstFilter())
        
        linerFilter.getFilter().useNextFrameForImageCapture()
        
        if view != nil {
            linerFilter.getFilter().addTarget(view)
            return nil
        } else {
            return linerFilter.getFilter().imageFromCurrentFramebufferWithOrientation(UIImageOrientation.Right)
        }
        
    }
    
    
    
    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    func RadiansToDegrees (value:Double) -> Double {
        return value * 180.0 / M_PI
    }
    
}