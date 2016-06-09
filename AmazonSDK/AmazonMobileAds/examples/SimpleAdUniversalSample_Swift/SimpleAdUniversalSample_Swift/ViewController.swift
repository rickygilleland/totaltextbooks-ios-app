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
    @IBOutlet var amazonAdView: AmazonAdView!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let adFrame: CGRect = CGRectMake(0, 20, UIScreen.mainScreen().bounds.size.width, 200);
        amazonAdView = AmazonAdView.init(frame: adFrame)
        amazonAdView.autoresizingMask = [.FlexibleWidth, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        amazonAdView.setHorizontalAlignment(.Center)
        amazonAdView.setVerticalAlignment(.Top)
        
        // Register the ViewController with the delegate to receive callbacks.
        amazonAdView.delegate = self
        
        // Load an ad
        loadAmazonAd(loadAdButton)
        view.addSubview(amazonAdView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: { (context) -> Void in
            // Reload Amazon Ad upon rotation.
            // Important: Amazon expandable rich media ads target landscape and portrait mode separately.
            // If your app supports device rotation events, your app must reload the ad when rotating between portrait and landscape mode.
            self.loadAmazonAd(self.loadAdButton);
        });
    }
    
    @IBAction func loadAmazonAd(sender: UIButton){
        let options = AmazonAdOptions()
        options.isTestRequest = true
        amazonAdView.loadAd(options)
        
    }
    
    // MARK: AmazonAdViewDelegate
    func viewControllerForPresentingModalView() -> UIViewController {
        return self
    }
    
    func adViewDidLoad(view: AmazonAdView!) -> Void {
        self.view.addSubview(amazonAdView)
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

