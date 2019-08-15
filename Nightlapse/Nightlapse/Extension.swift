//
//  Extension.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 27.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import Foundation
import UIKit

extension Float {
    static func clamp(min: Double, max: Double, val: CGFloat ) -> CGFloat {
        return CGFloat(fmin(fmax(Double(val), min), max))
    }
}