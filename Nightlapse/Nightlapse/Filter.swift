//
//  Filter.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 28.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

protocol Filter {
    
    var temp: Float {get set}
    
    func doFilter(origimg: GPUImagePicture, view: GPUImageView!, liner: Bool, x: CGFloat, y: CGFloat, z: CGFloat) -> UIImage!

}