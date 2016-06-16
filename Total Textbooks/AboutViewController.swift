//
//  AboutViewController.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 5/5/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var getHelpBtn: UIButton!
    
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var build: UILabel!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        let nav = self.navigationController?.navigationBar
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "logo")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        //style the search and scan barcode buttons
        getHelpBtn.layer.borderWidth = 1 // Set border width
        getHelpBtn.layer.cornerRadius = 5 // Set border radius (Make it curved, increase this for a more rounded button
        
        //set the version number label
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            self.version.text = version
        }
        //set the build number label
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            self.build.text = "(" + build + ")"
        }
    }
    
    @IBAction func getHelpBtn(sender: AnyObject) {
        
        self.performSegueWithIdentifier("showHelpView", sender: sender)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

