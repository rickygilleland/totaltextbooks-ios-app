// Copyright 2012-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at http://aws.amazon.com/apache2.0/
// or in the "license" file accompanying this file.
// This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import UIKit

class ViewController: UIViewController, AmazonAdViewDelegate {

    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var amazonAdView: AmazonAdView!

    override func viewDidLoad() {
        super.viewDidLoad()
        amazonAdView = AmazonAdView(adSize: AmazonAdSize_320x50)
        loadAmazonAd(loadAdButton)
        amazonAdView.delegate = self
    
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.amazon.com")!))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        loadAmazonAd(loadAdButton)
    }
    
    func loadAmazonAdWithUserInterfaceIdiom(userInterfaceIdiom: UIUserInterfaceIdiom, interfaceOrientation: UIInterfaceOrientation) -> Void {
        
        var options = AmazonAdOptions()
        options.isTestRequest = true
        
        var amazonAdCenterYOffsetFromBottom: Float = 0.0
        
        if (userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            amazonAdCenterYOffsetFromBottom = 25.0
            
            amazonAdView.autoresizingMask = (UIViewAutoresizing)(rawValue: UIViewAutoresizing.FlexibleLeftMargin.rawValue | UIViewAutoresizing.FlexibleRightMargin.rawValue | UIViewAutoresizing.FlexibleBottomMargin.rawValue | UIViewAutoresizing.FlexibleTopMargin.rawValue);
        } else {
            amazonAdView.removeFromSuperview()
            
            if (interfaceOrientation == UIInterfaceOrientation.Portrait) {
                amazonAdCenterYOffsetFromBottom = 45.0
                
                amazonAdView = AmazonAdView(adSize: AmazonAdSize_728x90)
                amazonAdView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height - 45.0)
            } else {
                amazonAdCenterYOffsetFromBottom = 45.0
                
                amazonAdView = AmazonAdView(adSize: AmazonAdSize_1024x50)
                amazonAdView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height - 45.0)
            }
            self.view.addSubview(amazonAdView)
            amazonAdView.delegate = self
        }
        
        UIView.animateWithDuration(NSTimeInterval(0.6), animations: {
            self.amazonAdView.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height - CGFloat(amazonAdCenterYOffsetFromBottom))
            })
        
        amazonAdView.loadAd(options)
    }
    
    @IBAction func loadAmazonAd(sender: UIButton){
        loadAmazonAdWithUserInterfaceIdiom(UIDevice.currentDevice().userInterfaceIdiom, interfaceOrientation: UIApplication.sharedApplication().statusBarOrientation)
    }
    
    // Mark: - AmazonAdViewDelegate
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    
    func adViewDidLoad(view: AmazonAdView!) -> Void {
        self.view.addSubview(amazonAdView)
        // Amazon Ad center Y offset from bottom.
        // The value is based on the device and orientation, and it will be used for sliding in the floating ad.
        var amazonAdCenterYOffsetFromBottom: Float = 0.0;
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            amazonAdCenterYOffsetFromBottom = 25.0
        } else {
            if (UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait) {
                amazonAdCenterYOffsetFromBottom = 45.0
            } else {
                amazonAdCenterYOffsetFromBottom = 25.0
            }
        }
        
        UIView.animateWithDuration(NSTimeInterval(0.6), animations: {
            self.amazonAdView.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height - CGFloat(amazonAdCenterYOffsetFromBottom))
        })
        
        Swift.print("Ad Loaded")
    }
    
    func adViewDidFailToLoad(view: AmazonAdView!, withError: AmazonAdError!) -> Void {
        Swift.print("Ad Failed to load. Error code \(withError.errorCode): \(withError.errorDescription)")
    }
    
    func adViewWillExpand(view: AmazonAdView!) -> Void {
        Swift.print("Ad will expand")
    }
    
    func adViewDidCollapse(view: AmazonAdView!) -> Void {
        Swift.print("Ad has collapsed")
    }
}

