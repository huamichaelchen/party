//
//  ImageRecogViewController.swift
//  NewApp-newUI
//
//  Created by Hua Chen on 2015-03-12.
//  Copyright (c) 2015 Hua Chen. All rights reserved.
//

import UIKit
import PKHUD

class ImageRecogViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, ENSideMenuDelegate {
    
    // MARK: - CloudSight API setups
    let apikey = "CloudSight KME-C3uduzc4mqprS8MIKA"
    var token: String? // image recognition response token
    var statusOfRequest: String? // check image recognition response status
    var recognizedTextReturn: String? // AI returned texts
    
    // MARK: Image taken setups
    var filepath: NSString!
    var imageTaken: UIImage?
    var imagePicker = UIImagePickerController()
    
    // MARK: Outlet setups
    @IBOutlet weak var returnedText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Gestures
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    // MAKR: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "slideout:")
        screenEdgeRecognizer.edges = .Left
        view.addGestureRecognizer(screenEdgeRecognizer)
        
    }
    
    // MARK: Animation Helper methods using community supported library
    func showTextHUD() {
        PKHUD.sharedHUD.contentView = PKHUDProgressTitleView(title: "Recognizing...")
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.show()
    }
    
    func hideTextHUD() {
        PKHUD.sharedHUD.hide(animated: true)
    }
    
    func slideout(sender: UIScreenEdgePanGestureRecognizer) {
        
        if sender.state == .Ended {
            toggleSideMenuView()
        }
    }
    
    // MARK: Check, Launch Camera and save Image
    
    func noCamera() {
        let alertVC = UIAlertController(title: "No Camera",
            message: "Sorry, ths device has no camera on it...",
            preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.showsCameraControls = true
            imagePicker.cameraCaptureMode = .Photo
            presentViewController(imagePicker, animated: true, completion: nil)
            
        } else {
            noCamera()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            let fileManager = NSFileManager.defaultManager()
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            let filePathToWrite = "\(paths)/SaveFile.png"
            //var imageData: NSData = UIImagePNGRepresentation(image)
            let imageData: NSData = UIImageJPEGRepresentation(image, 0.0)!
            print(imageData.length)
            fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
            filepath = paths.stringByAppendingPathComponent("SaveFile.png")
            
            if (fileManager.fileExistsAtPath(filepath as String)) {
                print("FILE AVAILABLE")
                //Pick Image and Use accordingly
                let images: UIImage = UIImage(contentsOfFile: filepath as String)!
                let data: NSData = UIImagePNGRepresentation(images)!
                
                imageRecognition()
                self.statusOfRequest = ""
            } else {
                print("FILE NOT AVAILABLE")
            }
        }
        self.dismissViewControllerAnimated(true, completion: {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showTextHUD()
            })
        })

    }
    
    // MARK: Image Recognition
    
    func imageRecognition() {
        // MARK: Image Recognition API Call (upload portion)
        // ----- Create HTTP request ----
        
        let param = ["image_request[image]": "\(filepath)", "image_request[locale]": "en-US"]
        
        let boundary = generateBoundaryString()
        
        let imageRequestUrl = NSURL(string: "https://api.cloudsightapi.com/image_requests")
        let imageRequest = NSMutableURLRequest(
            URL: imageRequestUrl!,
            cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy,
            timeoutInterval: 15.0) // the interval has to be long enough to get the request back!!!!!
        imageRequest.HTTPMethod = "POST"
        imageRequest.setValue(apikey, forHTTPHeaderField: "Authorization")
        imageRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // --- Create HTTP body ---
        let body = NSMutableData()
        
        for (key, value) in param {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        if let filename = filepath?.lastPathComponent {
            if let data = NSData(contentsOfFile: filepath! as String) {
                let mimetype = "application/octet-stream"
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"image_request[image]\"; filename=\"@\(filepath)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.appendData(data)
                body.appendString("\r\n")
                body.appendString("--\(boundary)--\r\n")
            } else {
                print("data is nil...")
            }
        } else {
            print("File does not exists...")
        }
        imageRequest.HTTPBody = body
        
        // --- Create the HTTP task ---
        let requestTask = NSURLSession.sharedSession().dataTaskWithRequest(imageRequest, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("HTTP Task Error: \(error?.localizedDescription)")
            } else {
                // the token within this JSON object is what we want !!!
                print("Here is the response data after uploading image: \(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                // standard HTTP request response
                print("Here is the http response: \(response!)")
                print(response!.expectedContentLength)
                
                
                let responseJSON = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                let dictionary = self.JSONParseDictionary(responseJSON as String)
                let url = dictionary["url"] as? String
                self.token = dictionary["token"] as? String
                print("The dictionary \(dictionary)")

                
                // MARK: Image Recognition API call (text return portion)
                let imageResponseUrl = NSURL(string: "https://api.cloudsightapi.com/image_responses/" + self.token!)
                let getResponse = NSMutableURLRequest(URL: imageResponseUrl!)
                getResponse.setValue(self.apikey, forHTTPHeaderField: "Authorization")
                
                // Session setup
                let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
                sessionConfiguration.timeoutIntervalForRequest = 15
                sessionConfiguration.timeoutIntervalForResource = 15
                let responseSession = NSURLSession(configuration: sessionConfiguration)
                
                /*
                After a request has been submitted, it usually takes between 6-12 seconds to
                receive a completed response. We recommend polling for a response every 1 second
                after a 4 second delay from the initial request, while the status is not completed.
                Hence the sleep()
                */
                while self.statusOfRequest != "completed" {
                    let responseTask = responseSession.dataTaskWithRequest(getResponse, completionHandler: {
                        data, response, error in
                        if error != nil {
                            print("Image Response error: \(error)")
                            
                        } else {
                            self.statusOfRequest = self.JSONParseDictionary(NSString(data: data!, encoding: NSUTF8StringEncoding)! as String)["status"] as? String
                            print(self.statusOfRequest)
                            
                            self.recognizedTextReturn = self.JSONParseDictionary(NSString(data: data!, encoding: NSUTF8StringEncoding)! as String)["name"] as? String
                            print(self.recognizedTextReturn)
                        }
                    })
                    sleep(1)
                    responseTask.resume()
                    
                }
                // All UI are run on the main queue
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.hideTextHUD()
                    self.returnedText.text = self.recognizedTextReturn
                })
            }
        })
        requestTask.resume()
    }
    
    
    // MARK: Helper funcitons
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }

    
    func JSONParseDictionary(jsonString: String) -> [String: AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]
                return dictionary!
            } catch {
                print(error)
            }
        }
        return [String: AnyObject]()
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}