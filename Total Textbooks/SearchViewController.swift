//
//  SearchViewController.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 5/5/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit
import WebKit
import SwiftSpinner

class SearchViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    let baseUrl = NSURL(string: "https://ios.dev.totaltextbooks.com")!
    
    @IBOutlet var containerView : UIView! = nil
    var webView: WKWebView?

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    
    override func loadView() {
        super.loadView()
        
        self.webView = WKWebView()
        self.view = self.webView!
        SwiftSpinner.hide()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView!.navigationDelegate = self
        webView!.UIDelegate = self
        
        webView!.scrollView.showsHorizontalScrollIndicator = false
        
        guard let url =  NSURL(string: "https://ios.dev.totaltextbooks.com") else { return }
        let req = NSURLRequest(URL:url)
        self.webView!.loadRequest(req)
        webView!.allowsBackForwardNavigationGestures = true

    }

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SwiftSpinner.show("Loading").addTapHandler({
            SwiftSpinner.hide()
        })
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SwiftSpinner.hide()
    }

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        if (navigationAction.navigationType == WKNavigationType.LinkActivated && !navigationAction.request.URL!.host!.lowercaseString.hasPrefix("ios.dev.totaltextbooks.com")) {
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
    
    @IBAction func reload(sender: UIBarButtonItem) {
        let request = NSURLRequest(URL:webView!.URL!)
        webView!.loadRequest(request)
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        webView!.goForward()
    }
    @IBAction func back(sender: UIBarButtonItem) {
        webView!.goBack()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

