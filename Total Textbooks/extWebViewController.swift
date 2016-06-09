//
//  extWebViewController.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 5/16/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit
import WebKit
import SwiftSpinner

class extWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    var url:NSURL!
    
    @IBOutlet var containerView: UIView!
    var webView: WKWebView?
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadbutton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        
        
        self.webView = WKWebView()
        self.view = self.webView!
        SwiftSpinner.hide()
        
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: self, action: #selector(extWebViewController.backNavButton(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        webView!.navigationDelegate = self
        webView!.UIDelegate = self
        
        //self.navigationController!.toolbarHidden = false;
        
        let URLRequest = NSURLRequest(URL: self.url)
        //print(URLRequest)
        self.webView!.loadRequest(URLRequest)
        
        //self.webView!.loadRequest(NSURLRequest(URL: NSURL(string: "https://google.com")!))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        SwiftSpinner.show("Loading").addTapHandler({
            SwiftSpinner.hide()
        })
        SwiftSpinner.showWithDelay(15.0, title: "Just a little longer...")
        
        delay(seconds: 60.0, completion: {
            SwiftSpinner.hide()
        })
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SwiftSpinner.hide()
    }
    
    
    @IBAction func back(sender: AnyObject) {
        webView!.goBack()
    }
    
    @IBAction func forward(sender: AnyObject) {
        webView!.goForward()
    }
    
    @IBAction func reload(sender: AnyObject) {
        let request = NSURLRequest(URL:webView!.URL!)
        webView!.loadRequest(request)
    }
    
    func backNavButton(sender: UIBarButtonItem) {
        self.navigationController!.toolbarHidden = true
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
