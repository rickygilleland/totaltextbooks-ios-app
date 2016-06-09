//
//  AppDelegate.swift
//  Total Textbooks
//
//  Created by Ricky Gilleland on 5/5/16.
//  Copyright © 2016 Ricky Gilleland. All rights reserved.
//

import UIKit
import ZendeskSDK

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = uicolorFromHex(0xffffff)
        navigationBarAppearace.barTintColor = uicolorFromHex(0x288feb)
        
        ZDKConfig.instance()
            .initializeWithAppId(
                "f557b3096dd0d0fab0a39010a1ba3298226c62dbbfc00e46",
                zendeskUrl: "https://totaltextbooks.zendesk.com",
                andClientId: "mobile_sdk_client_ea9996b190d35138c331")
        
        let identity = ZDKAnonymousIdentity()
        ZDKConfig.instance().userIdentity = identity
        
        //set the Amazon Ads API Key
        AmazonAdRegistration.sharedRegistration().setAppKey("5f153858377a4bea96b9bb45da30ce3a")
        
        return true
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        // Handle quick actions
        completionHandler(handleQuickAction(shortcutItem))
        
    }
    
    @available(iOS 9.0, *)
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {

        var quickActionHandled = false
        let searchForm = SearchFormViewController()
        var barcodeScannerView:ROBarcodeScannerViewController?
        let navigationController = UINavigationController()
        
        let barcodeScanner = ROBarcodeScannerViewController()
        // Define the callback which handles the returned result
        barcodeScanner.barcodeScanned = { (barcode:String) in
            // The scanned result can be fetched here
            //print("Barcode scanned: \(barcode)")
            searchForm.searchTextField.text = barcode
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        self.window!.rootViewController = navigationController
        
        self.window!.backgroundColor = UIColor.whiteColor()
        
        self.window!.makeKeyAndVisible()
        
        // Push the view
        if let barcodeScanner = barcodeScannerView {
            navigationController.pushViewController(barcodeScanner, animated: true)
        }
        
        

        quickActionHandled = true

        print(quickActionHandled)
        return quickActionHandled

    }

}

