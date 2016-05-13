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

class HelpViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {

    @IBOutlet weak var containerView: UIWebView! = nil
    var webView: WKWebView?
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    override func loadView() {
        super.loadView()
        
        self.webView = WKWebView()
        self.view = self.webView!
        SwiftSpinner.hide()
        
        
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
        
        webView!.navigationDelegate = self
        webView!.UIDelegate = self
        
        webView!.scrollView.showsHorizontalScrollIndicator = false
        
        guard let url =  NSURL(string: "https://ios.totaltextbooks.com/support") else { return }
        
        let req = NSURLRequest(URL:url)
        self.webView!.loadRequest(req)
        webView!.allowsBackForwardNavigationGestures = true
        
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SwiftSpinner.show("Loading").addTapHandler({
            SwiftSpinner.hide()
        })
        SwiftSpinner.showWithDelay(15.0, title: "Just a little longer...")
        SwiftSpinner.showWithDelay(60.0, title: "Request failed. Please try again.", animated: false)

    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SwiftSpinner.hide()
    }
    
    func webview(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        
        SwiftSpinner.hide()
        
        if error.code == -1001 { // TIMED OUT:
            
            let alertController = UIAlertController(title: "Total Textbooks", message:
                "Connect timed out. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
            // CODE to handle TIMEOUT
            
        } else if error.code == -1003 { // SERVER CANNOT BE FOUND
            
            let alertController = UIAlertController(title: "Total Textbooks", message:
                "Server could not be found. Please try again in a few minutes.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else { //Something else happened
        
            let alertController = UIAlertController(title: "Total Textbooks", message:
                "There was a server error. Please try again in a few minutes.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        if (navigationAction.navigationType == WKNavigationType.LinkActivated && !navigationAction.request.URL!.host!.lowercaseString.hasPrefix("ios.totaltextbooks.com")) {
            UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
            decisionHandler(WKNavigationActionPolicy.Cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.Allow)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x > 0){
            scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y)
        }
    }    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

