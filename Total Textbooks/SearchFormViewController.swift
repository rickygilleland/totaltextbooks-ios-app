//
//  SearchFormViewController.swift
//  
//
//  Created by Ricky Gilleland on 5/10/16.
//
//

import Foundation
import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire
import Material
import JSSAlertView

class SearchFormViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var scanBarcodeButton: MaterialButton!
    
    var background:UIImageView?
    
    var barcodeScanner:ROBarcodeScannerViewController?
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func viewWillAppear() {
        
        let name = "Search Form View"
    
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
    
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.toolbarHidden = true
        
        barcodeScanner = self.storyboard!.instantiateViewControllerWithIdentifier("ROBarcodeScannerViewControllerScene") as? ROBarcodeScannerViewController
        
        let nav = self.navigationController?.navigationBar
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "logo")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchFormViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //load the background
        self.loadBackground()
        
        
        //set the search box delegate as self
        self.searchTextField.delegate = self
        
        //style the search and scan barcode buttons
        searchButton.layer.borderWidth = 1 // Set border width
        searchButton.layer.cornerRadius = 5 // Set border radius (Make it curved, increase this for a more rounded button
        
        scanBarcodeButton.layer.borderWidth = 1 // Set border width
        scanBarcodeButton.layer.cornerRadius = 5 // Set border radius (Make it curved, increase this for a more rounded button
        
    }
    
    //load the background based on the current orientation
    func loadBackground() {
        if self.background == nil {
            self.background = UIImageView()
            self.view.addSubview(self.background!)
            self.view.sendSubviewToBack(self.background!)
        }
    
        //set the full screen background based on the current rotation
        if(UIApplication.sharedApplication().statusBarOrientation.isPortrait) {
            let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
            backgroundImage.image = UIImage(named: "blurred-bg")
            self.view.insertSubview(backgroundImage, atIndex: 0)
        } else {
            let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
            backgroundImage.image = UIImage(named: "blurred-bg-landscape")
            self.view.insertSubview(backgroundImage, atIndex: 0)
        }
    }
    
    //change the background image when the device rotates
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.loadBackground()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //textField code
        searchButtonTapped(nil)
        return true
    }

    @IBAction func searchButtonTapped(sender: AnyObject?) {
        let searchQuery:NSString = searchTextField.text!
        if (searchQuery == "" || searchTextField.text!.isEmpty) {
            
            JSSAlertView().danger(
                self,
                title: "No Book Entered",
                text: "Please enter a book to continue."
            )

        } else {
            SwiftSpinner.show("Loading").addTapHandler({
                SwiftSpinner.hide()
            })
        
            let query = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            //get the version number
            let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
            //get the build number
            let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
            
            let parameters = [
                "query": query!,
                "key": "nc8ur498rhn39gkjkjgjkdfhg1=fdgdf3r=r43r3290rierjg",
                "clientId": UIDevice.currentDevice().identifierForVendor!.UUIDString,
                "timestamp": "\(NSDate().timeIntervalSince1970 * 1000)",
                "version": version!,
                "build": build!
            ]
        
            //Get the basic book info and decide which view we are sending them to
            Alamofire.request(.POST, "https://api.textbookpricefinder.com/search/bookInfo/\(String(query!))", parameters: parameters).responseJSON { (responseData) -> Void in
                print(responseData.result.value)
                //successfull until proven otherwise
                var statusCode = 200
                if (responseData.response?.statusCode) != nil {
                    statusCode = responseData.response!.statusCode
                } else {
                    //something went really wrong
                    statusCode = 500
                }
                
                if ((statusCode) == 500) {
                    SwiftSpinner.hide()
                    JSSAlertView().danger(
                        self,
                        title: "Error Searching for Book",
                        text: "There was an issue completing your request. Please check your network connection or try again in a few minutes. If this issue persists, please use the Help page to contact us."
                    )
                }
                else if ((statusCode) != 200) {
                    SwiftSpinner.hide()
                    JSSAlertView().danger(
                        self,
                        title: "Error Searching for Book",
                        text: "There was an issue completing your request. Please check your network connection or try again in a few minutes. If this issue persists, please use the Help page to contact us."
                    )
                } else {
                    if((responseData.result.value) != nil) {
                        //looks like we received a successful response -- time to pick which view to shoot the user to
                        let swiftyJsonVar = JSON(responseData.result.value!)
                        if (swiftyJsonVar["isIsbn"] == "false") {
                            //was a book title entered
                            self.performSegueWithIdentifier("searchTitleSegue", sender: sender)
                        } else if (swiftyJsonVar["isIsbn"] == "true" && swiftyJsonVar["code"] == "200") {
                            //an ISBN was entered and a book was found, send them to the main result view
                            self.performSegueWithIdentifier("searchSegue", sender: sender)
                        } else if (swiftyJsonVar["code"] == "500") {
                            //no book was found
                            JSSAlertView().danger(
                                self,
                                title: "Book Not Found",
                                text: "We couldn't find your book. Please enter another book title or ISBN, or try our barcode scanner."
                            )
                        } else if (swiftyJsonVar["code"] == "403") {
                            //the API is blocking them for doing bad stuff
                            if (swiftyJsonVar["errors"] == "No API key") {
                                JSSAlertView().danger(
                                    self,
                                    title: "Error Searching for Book",
                                    text: "There was an issue completing your request. Please try again in a few minutes. If this issue persists, use the Help page to contact us."
                                )
                            } else if (swiftyJsonVar["errors"] == "Too many requests") {
                                JSSAlertView().danger(
                                    self,
                                    title: "Too Many Requests",
                                    text: "There was an issue completing your request. Please try again in a few minutes. If this issue persists, use the Help page to contact us."
                                )
                            } else {
                                JSSAlertView().danger(
                                    self,
                                    title: "Error Searching for Book",
                                    text: "There was an issue completing your request. Please try again in a few minutes. If this issue persists, use the Help page to contact us."
                                )
                            }
                        }

                
                        SwiftSpinner.hide()
                    } else {
                        JSSAlertView().danger(
                            self,
                            title: "Error Searching for Book",
                            text: "There was an issue completing your request. Please check your network connection or try again in a few minutes. If this issue persists, please use the Help page to contact us."
                        )
                    }
                }
            }
        }

    }
    
    @IBAction func barcodeButtonTapped(sender: UIButton?) {
        // Define the callback which handles the returned result
        barcodeScanner?.barcodeScanned = { (barcode:String) in
            // The scanned result can be fetched here
            //print("Barcode scanned: \(barcode)")
            self.searchTextField.text = barcode
        }
        
        // Push the view
        if let barcodeScanner = self.barcodeScanner {
            self.navigationController?.pushViewController(barcodeScanner, animated: true)
        }  
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "searchSegue" {
            
            let searchQuery:NSString = searchTextField.text!
            if (searchQuery == "" || searchTextField.text!.isEmpty) {
                
                JSSAlertView().danger(
                    self,
                    title: "No Book Entered",
                    text: "Please enter a book to continue."
                )
                return false
            }
                
            else {
                return true
            }
        }
        return true
        
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "searchSegue") {
            let searchQuery:NSString = searchTextField.text!
            let svc = segue.destinationViewController as! SearchViewController
            svc.searchPassed = searchQuery as String
        } else if (segue.identifier == "searchTitleSegue") {
            let searchQuery:NSString = searchTextField.text!
            let svc = segue.destinationViewController as! SearchTitleViewController
            svc.searchPassed = searchQuery as String
        }
    }
    
    
}