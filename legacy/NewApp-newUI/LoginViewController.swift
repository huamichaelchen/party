//
//  LoginViewController.swift
//  NewApp-newUI
//
//  Created by Hua Chen on 2015-03-26.
//  Copyright (c) 2015 Hua Chen. All rights reserved.
//

import UIKit
//import TwitterKit
import AVFoundation


class LoginViewController: UIViewController {
    
    var overlayView: UIView!
    var alertView: UIView!
    var animator: UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var snapBehavior : UISnapBehavior!
    
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    
    // MARK: Demo only code(1)...
    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: ViewController Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Demo only code(2)...
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        let blurLayer = CALayer()
        blurLayer.rasterizationScale = 0.25
        blurLayer.shouldRasterize = true
        
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == AVCaptureDevicePosition.Back {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        let err: NSError? = nil
                        do {
                            
                            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
                        }
                        catch {
                            print(error)
                        }
                        
                        if (err != nil) {
                            print(err?.localizedDescription)
                        }
                        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                        self.view.layer.addSublayer(previewLayer)
                        previewLayer.frame = self.view.layer.frame
                        previewLayer.shouldRasterize = true
                        previewLayer.rasterizationScale = 0.9
                        captureSession.startRunning()
                    }
                }
            }
        }
        
        // MARK: FB Login button ------- BUG !!! NOT working after SDK 2.4...
//        let fbLoginButton = FBSDKLoginButton(frame: CGRectMake(0, 0, 280, 40))
//        fbLoginButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 5 / 6)
//        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]

        
        // MARK: Twitter Login button
//        let twitterLogInButton = TWTRLogInButton { (session: TWTRSession!, error: NSError!) -> Void in
//            if session != nil {
//                print("Signed in as \(session.userName)")
//                let destinationViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("NavigationController") as UIViewController
//                self.presentViewController(destinationViewController, animated: true, completion: nil)
//            } else {
//                print("Sign in error: \(error.localizedDescription)")
//                self.twitterLoginErrorAlert()
//            }
//        }
//        twitterLogInButton.center = self.view.center
//        self.view.addSubview(twitterLogInButton)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            //view.insertSubview(blurEffectView, belowSubview: twitterLogInButton)
        }
    }
    
    func twitterLoginErrorAlert() {
        let alert = UIAlertController(title: "No Twitter Account...",
            message: "Go to settings", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))

        
        
        alert.addAction(UIAlertAction(title: "Skip Login", style: .Default) {
            alertAction in
            let destinationViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("NavigationController") as UIViewController
            self.presentViewController(destinationViewController, animated: true, completion: nil)
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
