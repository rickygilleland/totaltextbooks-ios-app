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
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "No Book Entered"
            alertView.message = "Please enter a book to continue."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            SwiftSpinner.show("Loading").addTapHandler({
                SwiftSpinner.hide()
            })
        
            let query = searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
            //Get the basic book info and decide which view we are sending them to
            Alamofire.request(.GET, "https://api.textbookpricefinder.com/search/bookInfo/\(String(query!))/nc8ur498rhn3983").responseJSON { (responseData) -> Void in
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
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Error Searching for Book"
                    alertView.message = "There was an issue completing your request. Please check your network connection or try again in a few minutes. If this issue persists, please use the Help page to contact us."
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
                else if ((statusCode) != 200) {
                    SwiftSpinner.hide()
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Error Searching for Book"
                    alertView.message = "There was an issue completing your request. Please check your network connection or try again in a few minutes. If this issue persists, please use the Help page to contact us."
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
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
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Book Not Found"
                            alertView.message = "We couldn't find your book. Please enter another book title or ISBN, or try our barcode scanner."
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                
                        SwiftSpinner.hide()
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Error Searching for Book"
                        alertView.message = "There was an issue completing your request. Please check your network connection or try again in a few minutes. If this issue persists, please use the Help page to contact us."
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
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
                
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "No Book Entered"
                alertView.message = "Please enter a book to continue."
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
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