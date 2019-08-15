//
//  Filters.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 21.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import Foundation
import GPUImage

class Filters {

    
//    static func BlendFilter( pre: GPUImagePicture, filterimg: GPUImagePicture, mix: CGFloat) -> UIImage {
//    
//        let blend = GPUImageAlphaBlendFilter()
//        blend.mix = mix
//        blend.useNextFrameForImageCapture()
//
//        pre.addTarget(blend, atTextureLocation: 0)
//        pre.processImage()
//        
//        filterimg.addTarget(blend, atTextureLocation: 1)
//        filterimg.processImage()
//        
//        return blend.imageFromCurrentFramebufferWithOrientation(UIImageOrientation.Right)
//        
//    }
    
    static func FocusPeakFilter( pre: GPUImagePicture) -> UIImage {
        
        
        let laplace = GPUImageLaplacianFilter()
        laplace.useNextFrameForImageCapture()
        
   
        
        pre.addTarget(laplace)
        
        let color = GPUImageLuminanceThresholdFilter()
        color.useNextFrameForImageCapture()
        color.threshold = 0.7
        //let invert = GPUImageColorInvertFilter()
        laplace.addTarget(color)
        //color.addTarget(invert)
        
        pre.processImage()
        
        //return self.BlendFilter(pre, filterimg: GPUImagePicture(image: ), mix: mix)
        return color.imageFromCurrentFramebuffer()
    }

    
    static func LookupFilter(img: GPUImagePicture, filterimg: GPUImagePicture) -> GPUImagePicture {
    
        
        let filter = GPUImageLookupFilter()
        filter.useNextFrameForImageCapture()

        //var lookup = GPUImagePicture(image: UIImage(named: "mignon"))
        
        img.addTarget(filter)
        img.processImage()
        
        
        filterimg.addTarget(filter)
        filterimg.processImage()
        
        return GPUImagePicture(image: filter.imageFromCurrentFramebuffer())
    }
}