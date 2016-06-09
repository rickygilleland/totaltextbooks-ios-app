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
import Alamofire
import SwiftyJSON
import Haneke
import SafariServices

class customBuyTableViewCell: UITableViewCell {
    @IBOutlet weak var merchantLogo: UIImageView!
    @IBOutlet weak var bookPrice: UILabel!
    @IBOutlet weak var shipPrice: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var getBookBtn: UIButton!
    
    var getBookBtnTapped: ((customBuyTableViewCell) -> Void)?
    
    @IBAction func getBookBtn(sender: AnyObject) {
        getBookBtnTapped?(self)
    }

}

class customSellTableViewCell: UITableViewCell {
    @IBOutlet weak var merchantLogo: UIImageView!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var paymentMethod: UILabel!
    @IBOutlet weak var sellBookBtn: UIButton!
    
    var sellBookBtnTapped: ((customSellTableViewCell) -> Void)?
    
    @IBAction func sellBookBtn(sender: AnyObject) {
        sellBookBtnTapped?(self)
    }
    
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var isbn10: UILabel!
    @IBOutlet weak var isbn13: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var edition: UILabel!
    @IBOutlet weak var msrp: UILabel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var searchPassed:String!
    
    var condition:String!
    
    var buyArrRes = [[String:AnyObject]]()
    var sellArrRes = [[String:AnyObject]]()
    
    var conditionArray = [String]()
    var paymentMethodArray = [String]()
    var merchantArray = [String]()
    
    var curTable:String!
    
    override func loadView() {
        super.loadView()

        //SwiftSpinner.hide()
        
        //set the initial value to buy
        self.curTable = "buy"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make the labels empty when the view first loads so no one sees the placeholder content
        self.bookTitle.text = ""
        self.isbn10.text = ""
        self.isbn13.text = ""
        self.author.text = ""
        self.edition.text = ""
        self.msrp.text = ""
        
        self.navigationController!.toolbarHidden = true
        
        let nav = self.navigationController?.navigationBar
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "logo")
        imageView.image = image
        
        navigationItem.titleView = imageView


        let query = searchPassed.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        SwiftSpinner.show("Loading").addTapHandler({
            SwiftSpinner.hide()
        })
        
        //Get the basic book info and decide which view we are sending them to
        Alamofire.request(.GET, "https://api.textbookpricefinder.com/search/bookInfo/\(String(query!))/nc8ur498rhn3983").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)["vitalInfo"]
                
                if swiftyJsonVar["vitalInfo"] != nil {
                    self.bookTitle.text = swiftyJsonVar["vitalInfo"]["title"].stringValue
                    let coverUrl = NSURL(string: swiftyJsonVar["vitalInfo"]["cover"].stringValue)
                    self.bookCover.hnk_setImageFromURL(coverUrl!)
                    self.isbn10.text = swiftyJsonVar["vitalInfo"]["isbn10"].stringValue
                    self.isbn13.text = swiftyJsonVar["vitalInfo"]["isbn13"].stringValue
                    self.author.text = swiftyJsonVar["vitalInfo"]["author"].stringValue
                    self.edition.text = swiftyJsonVar["vitalInfo"]["edition"].stringValue
                    self.msrp.text = swiftyJsonVar["vitalInfo"]["msrp"].stringValue
                }
                
                SwiftSpinner.hide()
            }
        }
        
        Alamofire.request(.GET, "https://api.textbookpricefinder.com/search/all/\(String(query!))/nc8ur498rhn3983").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["buyResponse"].arrayObject {
                    self.buyArrRes = resData as! [[String:AnyObject]]
                    
                    for (key, subJson) in swiftyJsonVar["buyResponse"] {
                        if let condition = subJson["condition"].string {
                            self.conditionArray.append(condition)
                        }
                        if let merchant = subJson["merchant"].string {
                            self.merchantArray.append(merchant)
                        }
                    }
                }
                if self.buyArrRes.count > 0 {
                    self.tableView.reloadData()
                    //self.buyTableView.reloadData()
                    //self.performSegueWithIdentifier("buyResultsSegue", sender: self)
                    //NSNotificationCenter.defaultCenter().postNotificationName("buyReload", object: nil)
                }

                if let sellData = swiftyJsonVar["sellResponse"].arrayObject {
                    self.sellArrRes = sellData as! [[String:AnyObject]]
                    
                    for (key, subJson) in swiftyJsonVar["sellResponse"] {
                        if let method = subJson["paymentMethod"].string {
                            self.paymentMethodArray.append(method)
                        }
                    }
                }

                if self.sellArrRes.count > 0 {
                    //self.sellTableView.reloadData()
                    //self.performSegueWithIdentifier("sellResultsSegue", sender: self)
                    //NSNotificationCenter.defaultCenter().postNotificationName("sellReload", object: nil)
                }
                
            }
        }
        
        
    }
    
    @IBAction func showComponent(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.curTable = "buy"
            self.tableView.reloadData()
        } else {
            self.curTable = "sell"
            self.tableView.reloadData()
        }
    }
       
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func schemeAvailable(scheme: String) -> Bool {
        if let url = NSURL.init(string: scheme) {
            return UIApplication.sharedApplication().canOpenURL(url)
        }
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (self.curTable == "buy") {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("buyCell") as! customBuyTableViewCell
            
            var dict = buyArrRes[indexPath.row]
            
            cell.getBookBtnTapped = { [unowned self] (selectedCell) -> Void in
                
                let url = NSURL(string: (dict["URL"] as? String)!)
                
                //open Amazon in Safari because of their rules
                if (self.merchantArray[indexPath.row] == "amazon") {
                    UIApplication.sharedApplication().openURL(url!)
                } else if #available(iOS 9.0, *) {
                    let vc = SFSafariViewController(URL: url!)
                    self.presentViewController(vc, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions
                    let extWebView = self.storyboard!.instantiateViewControllerWithIdentifier("extModalWebView") as! extWebViewController
                    extWebView.url = url
                    self.navigationController!.pushViewController(extWebView, animated: true)
                }
            }
        
            let merchantLogo = dict["merchantImage"] as? String
            var merchantLogoUrl = NSURL(string: (dict["merchantImage"] as? String)!)
        
            if (merchantLogo!.hasPrefix("https")) {
                merchantLogoUrl = NSURL(string: (dict["merchantImage"] as? String)!)
            } else {
                let url = dict["merchantImage"] as? String
                let prefixedUrl = "https://www.totaltextbooks.com" + url!
                merchantLogoUrl = NSURL(string: (prefixedUrl))
            }
        
            cell.merchantLogo.hnk_setImageFromURL(merchantLogoUrl!)
            
            cell.condition?.text = self.conditionArray[indexPath.row]
            
            let formatter = NSNumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            if (dict["bookPrice"]!.doubleValue != nil) {
                let bookPrice = formatter.stringFromNumber(dict["bookPrice"]!.doubleValue)
                cell.bookPrice.text = "$" + bookPrice!
            } else if (dict["bookPrice"]!.stringValue != nil) {
                cell.bookPrice?.text = dict["bookPrice"]!.stringValue
            } else if (dict["bookPrice"]!.intValue != nil) {
                let intPrice = String(dict["bookPrice"]!.intValue)
                cell.bookPrice?.text = "\(intPrice)"
            } else {
                cell.bookPrice?.text = " "
            }
            
            if (dict["shipPrice"]!.doubleValue != nil) {
                let shipPrice = formatter.stringFromNumber(dict["shipPrice"]!.doubleValue)
                cell.shipPrice.text = "$" + shipPrice!
            } else if (dict["shipPrice"]!.stringValue != nil) {
                cell.shipPrice?.text = dict["shipPrice"]!.stringValue
            } else if (dict["shipPrice"]!.intValue != nil) {
                let intPrice = String(dict["shipPrice"]!.intValue)
                cell.shipPrice?.text = "\(intPrice)"
            } else {
                cell.shipPrice?.text = " "
            }
        
            if (cell.shipPrice.text != nil && cell.shipPrice.text == "$.00") {
                cell.shipPrice?.text = "Free Shipping"
            }
            
            if (dict["totalPrice"]!.doubleValue != nil) {
                let doublePrice = formatter.stringFromNumber(dict["totalPrice"]!.doubleValue)
                cell.totalPrice.text = "$" + doublePrice!
            } else if (dict["totalPrice"]!.stringValue != nil) {
                cell.totalPrice.text = "$" + dict["totalPrice"]!.stringValue
            } else if (dict["totalPrice"]!.intValue != nil) {
                let intPrice = String(dict["totalPrice"]!.intValue)
                cell.totalPrice?.text = "$" + "\(intPrice)"
            } else {
                cell.totalPrice?.text = " "
            }
            
            //style the button
            cell.getBookBtn.layer.borderWidth = 1 // Set border width
            cell.getBookBtn.layer.cornerRadius = 5 // Set border radius (Make it curved, increase this for a more rounded button
        
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("sellCell") as! customSellTableViewCell
            var dict = sellArrRes[indexPath.row]
            
            let merchantLogo = dict["merchantImage"] as? String
            var merchantLogoUrl = NSURL(string: (dict["merchantImage"] as? String)!)
            
            if (merchantLogo!.hasPrefix("https")) {
                merchantLogoUrl = NSURL(string: (dict["merchantImage"] as? String)!)
            } else {
                let url = dict["merchantImage"] as? String
                let prefixedUrl = "https://www.totaltextbooks.com" + url!
                merchantLogoUrl = NSURL(string: (prefixedUrl))
            }
            
            cell.merchantLogo.hnk_setImageFromURL(merchantLogoUrl!)
            
            let formatter = NSNumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            if (dict["totalPrice"]!.doubleValue != nil) {
                let doublePrice = formatter.stringFromNumber(dict["totalPrice"]!.doubleValue)
                cell.totalPrice.text = "$" + doublePrice!
            } else if (dict["totalPrice"]!.stringValue != nil) {
                cell.totalPrice.text = "$" + dict["totalPrice"]!.stringValue
            } else if (dict["totalPrice"]!.intValue != nil) {
                let intPrice = String(dict["totalPrice"]!.intValue)
                cell.totalPrice?.text = "$" + "\(intPrice)"
            } else {
                cell.totalPrice?.text = " "
            }
            
            cell.paymentMethod.text = self.paymentMethodArray[indexPath.row]
            
            cell.sellBookBtnTapped = { [unowned self] (selectedCell) -> Void in
                
                let url = NSURL(string: (dict["URL"] as? String)!)
                
                //open Amazon in Safari because of their rules
                if (self.merchantArray[indexPath.row] == "amazon") {
                    UIApplication.sharedApplication().openURL(url!)
                } else if #available(iOS 9.0, *) {
                    let vc = SFSafariViewController(URL: url!)
                    self.presentViewController(vc, animated: true, completion: nil)
                } else {
                    // Fallback on earlier versions
                    let extWebView = self.storyboard!.instantiateViewControllerWithIdentifier("extModalWebView") as! extWebViewController
                    extWebView.url = url
                    self.navigationController!.pushViewController(extWebView, animated: true)
                }
            }

            //style the button
            cell.sellBookBtn.layer.borderWidth = 1 // Set border width
            cell.sellBookBtn.layer.cornerRadius = 5 // Set border radius (Make it curved, increase this for a more rounded button
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.curTable == "buy") {
            return buyArrRes.count
        } else {
            return sellArrRes.count
        }
    }

}

