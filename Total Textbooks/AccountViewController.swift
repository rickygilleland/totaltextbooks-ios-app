//
//  FirstViewController.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 5/5/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit
import WebKit
import SwiftSpinner

class AccountViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    let baseUrl = NSURL(string: "https://ios.totaltextbooks.com")!
    
    @IBOutlet var containerView: UIView! = nil
    
    var accountView: WKWebView?
    
    override func loadView() {
        super.loadView()
        
        self.accountView = WKWebView()
        self.view = self.accountView!
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountView!.navigationDelegate = self
        accountView!.UIDelegate = self
        
        guard let url =  NSURL(string: "https://ios.totaltextbooks.com/account/login") else { return }
        accountView!.navigationDelegate = self
        //homeView!.loadRequest(NSURLRequest(URL: url))
        //view.addSubview(homeView!)
        
        //var url = NSURL(string:"https://ios.dev.totaltextbooks.com")
        var req = NSURLRequest(URL:url)
        self.accountView!.loadRequest(req)
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SwiftSpinner.show("Loading...")
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

