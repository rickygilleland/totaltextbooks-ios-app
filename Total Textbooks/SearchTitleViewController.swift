//
//  SearchTitleViewController.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 6/3/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Haneke
import JSSAlertView

class customTitleTableViewCell: UITableViewCell {
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookEdition: UILabel!
}

class SearchTitleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AmazonAdViewDelegate {
    
    var searchPassed:String!
    
    var titleArray = [String]()
    var coverArray = [String]()
    var authorArray = [String]()
    var isbnArray = [String]()
    var editionArray = [String]()
    
    var bookIsbn:String!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultsFound: UILabel!
    
    @IBOutlet var amazonAdView: AmazonAdView!
    
    func viewWillAppear() {
        
        let name = "Search Results View - Title Search"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //start with nothing so no one sees the placeholder content
        self.resultsFound.text = ""

        self.navigationController!.toolbarHidden = true
        
        let nav = self.navigationController?.navigationBar
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "logo")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        //load the Amazon Ad
        //let adFrame: CGRect = CGRectMake(0, self.view.bounds.size.height-50, UIScreen.mainScreen().bounds.size.width, 50);
        amazonAdView = AmazonAdView.init(adSize: AmazonAdSize_320x50)
        loadAmazonAd()
        amazonAdView.delegate = self
        
        let query = searchPassed.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        SwiftSpinner.show("Loading").addTapHandler({
            SwiftSpinner.hide()
        })
        
        //get the version number
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        //get the build number
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
        
        let parameters = [
            "query": query!,
            "key": "nc8ur498rhn39gkjkjgjkdfhg1=fdgdf3r=r43r3290rierjg",
            "clientId": UIDevice.currentDevice().identifierForVendor!.UUIDString,
            "timestamp": "\(NSDate().timeIntervalSince1970 * 1000)",
            "version": version!,
            "build": build!
        ]
            
        Alamofire.request(.POST, "https://api.textbookpricefinder.com/search/all/\(String(query!))", parameters: parameters).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                if (swiftyJsonVar["parsedTitleResponse"] == "false") {
                    //something isn't right -- throw an error
                    JSSAlertView().danger(
                        self,
                        title: "Oops! Something went wrong",
                        text: "Please try your search again. If this message persists, use the Help page to contact us."
                    )
                } else if let titleData = swiftyJsonVar["parsedTitleResponse"].arrayObject {
                    for (key, subJson) in swiftyJsonVar["parsedTitleResponse"] {
                        if let title = subJson["title"].string {
                            self.titleArray.append(title)
                        }
                        if let cover = subJson["cover"].string {
                            self.coverArray.append(cover)
                        }
                        if let author = subJson["author"].string {
                            self.authorArray.append(author)
                        }
                        if let isbn = subJson["isbn"].string {
                            self.isbnArray.append(isbn)
                        }
                        if let edition = subJson["edition"].string {
                            self.editionArray.append(edition)
                        }
                    }
                    self.tableView.reloadData()
                    
                    self.resultsFound.text = "\(self.titleArray.count)" + " Results Found"
                }
                
            } else {
                //Something either went wrong, or we couldn't find their book.
                JSSAlertView().danger(
                    self,
                    title: "Book Not Found",
                    text: "We couldn't find your book. Please enter another book title or ISBN, or try our barcode scanner."
                )
                self.performSegueWithIdentifier("searchTitleToSearchForm", sender: self)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("titleCell")! as! customTitleTableViewCell
        
        cell.bookTitle.text = self.titleArray[indexPath.row]
        
        let coverUrl = NSURL(string: (self.coverArray[indexPath.row]))
        cell.bookCover.hnk_setImageFromURL(coverUrl!)
        
        cell.bookAuthor.text = self.authorArray[indexPath.row]
        
        cell.bookEdition.text = self.editionArray[indexPath.row]
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.bookIsbn = self.isbnArray[indexPath.row]
        
        self.performSegueWithIdentifier("searchTitleToIsbnSegue", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "searchTitleToIsbnSegue") {
            let searchQuery:NSString = self.bookIsbn
            let svc = segue.destinationViewController as! SearchViewController
            svc.searchPassed = searchQuery as String
        }
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
    
    func loadAmazonAd(){
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
