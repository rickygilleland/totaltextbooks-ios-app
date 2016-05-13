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
import Material

class SearchFormViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var barcodeScanner:ROBarcodeScannerViewController?
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeScanner = self.storyboard!.instantiateViewControllerWithIdentifier("ROBarcodeScannerViewControllerScene") as? ROBarcodeScannerViewController
        
        let nav = self.navigationController?.navigationBar
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "logo")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func searchButtonTapped(sender: UIButton) {
        
    }
    
    @IBAction func barcodeButtonTapped(sender: UIButton) {
        
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
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
        }
    }
    
    
}