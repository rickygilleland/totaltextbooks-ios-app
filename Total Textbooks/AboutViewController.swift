//
//  AboutViewController.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 5/5/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit
import WebKit
import SwiftSpinner

class AboutViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    let baseUrl = NSURL(string: "https://ios.totaltextbooks.com")!
    
    @IBOutlet var containerView: UIView! = nil
    var moreView: WKWebView?
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        
        self.moreView = WKWebView()
        self.view = self.moreView!
        
        
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
        
        moreView!.navigationDelegate = self
        moreView!.UIDelegate = self
        
        guard let url =  NSURL(string: "https://ios.totaltextbooks.com/about") else { return }
        moreView!.navigationDelegate = self
        //homeView!.loadRequest(NSURLRequest(URL: url))
        //view.addSubview(homeView!)
        
        //var url = NSURL(string:"https://ios.dev.totaltextbooks.com")
        var req = NSURLRequest(URL:url)
        self.moreView!.loadRequest(req)
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SwiftSpinner.show("Loading...")
        SwiftSpinner.showWithDelay(15.0, title: "Just a little longer...")
        SwiftSpinner.showWithDelay(60.0, title: "Request failed. Please try again.", animated: false)
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SwiftSpinner.hide()
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        if (navigationAction.navigationType == WKNavigationType.LinkActivated && !navigationAction.request.URL!.host!.lowercaseString.hasPrefix("ios.totaltextbooks.com")) {
            UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
            decisionHandler(WKNavigationActionPolicy.Cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.Allow)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
