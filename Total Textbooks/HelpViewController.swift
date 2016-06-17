//
//  HelpViewController.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 5/5/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit
import WebKit
import SwiftSpinner
import ZendeskSDK

class HelpViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var kbButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    
    func viewWillAppear() {
        
        let name = "Help View"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
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
        
        //style the buttons
        kbButton.layer.borderWidth = 1 // Set border width
        kbButton.layer.cornerRadius = 5 // Set border radius (Make it curved, increase this for a more rounded button
        
        contactButton.layer.borderWidth = 1 // Set border width
        contactButton.layer.cornerRadius = 5 // Set border radius (Make it curved, increase this for a more rounded button
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func kbButtonTapped(sender: AnyObject) {

        ZDKHelpCenter.pushHelpCenterWithNavigationController(self.navigationController)
    }
    
    @IBAction func contactButtonTapped(sender: UIButton) {
        
        ZDKRequests.presentRequestCreationWithViewController(self.navigationController)
        
    }
}

