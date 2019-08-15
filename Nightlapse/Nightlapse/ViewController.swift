//
//  ViewController.swift
//  Nightlapse
//
//  Created by Modestas Valauskas on 03.06.15.
//  Copyright (c) 2015 ModestasV Studios. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import Foundation
import GPUImage

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var videoCaptureOutput = AVCaptureVideoDataOutput()
    
    var liner = false
    
    @IBOutlet var mainView: GPUImageView!
    
    var timerPhotos = false
    
    @IBOutlet weak var shootButton: UIButton!
    
    var captureDevice : AVCaptureDevice?
    
    var motionKit = MotionKit()
    
    var blendlvl: CGFloat = 1
    var blendlvl2: CGFloat = 1
    var blendlvl3: CGFloat = 1
    
    var filter: Filter!
    
    override func viewDidLoad() {
        
        filter = Wanderlust()
        
        previewLayer?.delegate = self
        shootButton.layer.cornerRadius = 15
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    
                    captureDevice = device as? AVCaptureDevice
                    
                    if captureDevice != nil {
                        beginSession()
                    }
                }
            }
        }
        
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                device.unlockForConfiguration()
            }
        }

        
        motionKit.getGravityAccelerationFromDeviceMotion(interval: 0.02) {
                (x, y, z) -> () in
                var xstr = String(format: "%.2f", x)
                var ystr = String(format: "%.2f", y)
                var zstr = String(format: "%.2f", z)
            
                let rad = CGFloat(M_PI_2) * 57.2957795 * 0.0174532925 * CGFloat(x)
            
                println("\(xstr) \(ystr) \(zstr) ")
                
                self.blendlvl = CGFloat(x)
                self.blendlvl2 = CGFloat(y)
                self.blendlvl3 = CGFloat(z)
            return
        }

    }
    
    
    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    func RadiansToDegrees (value:Double) -> Double {
        return value * 180.0 / M_PI
    }

    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        dispatch_async(dispatch_get_main_queue(), {
            
            var pic = GPUImagePicture(CGImage: self.getCGImageFromBuffer(sampleBuffer))
            
            self.filter.doFilter(pic, view: self.mainView, liner: self.liner, x: self.blendlvl, y: self.blendlvl2, z: self.blendlvl3)

        })
    }
    
    
    func getImageFromBuffer4(sampleBuffer: CMSampleBuffer)->UIImage {
        var imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.NoneSkipFirst.rawValue )
        
        var context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
        
        var quartzImage = CGBitmapContextCreateImage(context);
        

        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        var image = UIImage(CGImage: quartzImage, scale: 1, orientation: UIImageOrientation.Right)
        
        //var image = UIImage(CIImage: filterBright(CIImage(CGImage: quartzImage)), scale: 1.0, orientation: UIImageOrientation.Right)

        
       return image!
    }
    
    func getCGImageFromBuffer(sampleBuffer: CMSampleBuffer)->CGImage {
        var imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.NoneSkipFirst.rawValue )
        
        var context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
        
        return CGBitmapContextCreateImage(context)
    }
         
    @IBAction func startBtn(sender: AnyObject) {
        if(timerPhotos == false) {
           // timer.startTimer()
            timerPhotos = true
            shootButton.layer.backgroundColor = UIColor.grayColor().CGColor
        } else {
          //  timer.stopTimer(shootButton)
            timerPhotos = false
            shootButton.layer.backgroundColor = UIColor.blackColor().CGColor
        }
    }
    
    @IBAction func singleShot(sender: AnyObject) {
        takePicture()
    }
    
    func takePicture() {
        dispatch_async(dispatch_get_main_queue(), {
            
            if let videoConnection = self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
                
                videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                    (sampleBuffer, error) in
                    
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)

                    
                    UIImageWriteToSavedPhotosAlbum(self.filter.doFilter(GPUImagePicture(CGImage: cgImageRef)!,view: nil, liner: self.liner, x: self.blendlvl, y: self.blendlvl2, z: self.blendlvl3), nil, nil, nil)
                    // CustomPhotoAlbum.sharedInstance.saveImage()
                    
                })
            }

        })

    }

    @IBAction func liner(sender: AnyObject) {
        liner = !liner
    }
    
    @IBAction func firstSlider(sender: UISlider) {
    }
    
    @IBAction func secondSlider(sender: UISlider) {
    }
    
    @IBAction func thirdSlider(sender: UISlider) {
    }
    
    @IBAction func fourthSlider(sender: UISlider) {
        self.blendlvl = CGFloat(sender.value)
    }
    
    func beginSession() {
        
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        //mainView.layer.insertSublayer(previewLayer, atIndex: 0)
        //previewLayer?.frame = mainView.layer.frame
        
        stillImageOutput = AVCaptureStillImageOutput()
        
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        videoCaptureOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        videoCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
        
        captureSession.addOutput(videoCaptureOutput)
        captureSession.startRunning()
    }
    
}

