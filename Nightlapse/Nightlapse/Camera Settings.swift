//
//  Camera Settings.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 12.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import Foundation
import AVFoundation

class CameraSettings {

    //CameraSettings.focusTo(sender.value, captureDevice: captureDevice)
    static func focusTo(value: Float, captureDevice: AVCaptureDevice?) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.setFocusModeLockedWithLensPosition(value, completionHandler: nil)
                device.unlockForConfiguration()
            }
        }
    }

    //CameraSettings.shutterTo(self.interpHigherPowers(8000, max: 2, value: sender.value), captureDevice: captureDevice)
    static func shutterTo(value: Float, captureDevice: AVCaptureDevice?) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.setExposureModeCustomWithDuration(CMTimeMake(1, Int32(value)), ISO: device.ISO, completionHandler: nil)
                device.unlockForConfiguration()
            }
        }
    }
    
    //CameraSettings.ISOTo(sender.value, captureDevice: captureDevice)
    
    static func ISOTo(value: Float, captureDevice: AVCaptureDevice?) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                println(device.activeFormat.maxISO)
                println((value * (device.activeFormat.maxISO - device.activeFormat.minISO)) + device.activeFormat.minISO)
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: (value * (device.activeFormat.maxISO - device.activeFormat.minISO)) + device.activeFormat.minISO, completionHandler: nil)
                device.unlockForConfiguration()
            }
        }
    }
    
    
    static var valueTorch: Float = 0.0
    
    static func TorchTo(captureDevice: AVCaptureDevice?) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                if (device.hasTorch) {
                    if(valueTorch == 0.0) {
                        valueTorch = 0.3
                        device.setTorchModeOnWithLevel(self.valueTorch, error: nil)
                    } else if(valueTorch == 0.3) {
                        valueTorch = 0.6
                        device.setTorchModeOnWithLevel(self.valueTorch, error: nil)
                    } else if(valueTorch == 0.6) {
                        valueTorch = 0.9
                        device.setTorchModeOnWithLevel(self.valueTorch, error: nil)
                    } else if(valueTorch == 0.9) {
                        valueTorch = 1
                        device.setTorchModeOnWithLevel(self.valueTorch, error: nil)
                    } else if(valueTorch == 1) {
                        valueTorch = 0.0
                        device.torchMode = AVCaptureTorchMode.Off
                    }
                    device.unlockForConfiguration()
                }
                
            }
        }
    }
    
    static func TorchOff(captureDevice: AVCaptureDevice?) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                if (device.hasTorch) {
                    if (device.torchMode == AVCaptureTorchMode.On) {
                        device.torchMode = AVCaptureTorchMode.Off
                    }
                    valueTorch = 0.0
                    device.unlockForConfiguration()
                }
            }
        }
    }
    
    func interpHigherPowers(min: Float, max: Float, value: Float)-> Float{
        var v = value
        v *= v
        v *= v
        v *= v
        //UMKEHREN
        //v = 1- (1- v) * (1-v)
        var x = (min * v) + (max * (1 - v))
        return x
    }
    
    func interpSin(min: Float, max: Float, value: Float)-> Float{
        var v = sin((1-value) * (Float(M_PI) / 2))
        var x = (max * v) + (min * (1 - v))
        return x - min
    }

    
}
