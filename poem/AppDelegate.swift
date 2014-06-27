//
//  AppDelegate.swift
//  poem
//
//  Created by Sun Xi on 6/12/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import UIKit

let kAppKey_WeiXin = "wxf04441074e0bff9c"
let kAppKey_WeiBo = "979020811"

let kFontSong:String = "FZQingKeBenYueSongS-R-GB"//"A-OTF Akashi Std"//
let kFontKai:String = "FZKai-Z03S"//"FZKai-Z03T"//
let kFontIcon:String = "icomoon"
let kDBPath:String? = NSBundle.mainBundle().pathForResource("poem", ofType: "db")
let PoemDB:EGODatabase? = EGODatabase(path:kDBPath)
let docPath:AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
let favItemPath = docPath.stringByAppendingString("/favdoc")
let favManagedDoc:UIManagedDocument = UIManagedDocument(fileURL: NSURL(fileURLWithPath: favItemPath))
let favColorDic = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("color", ofType: "plist"))
var favFolders:Array<FavFolder> = []

func UIColorFromRGB(rgbValue:Int)->UIColor {
    return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0 , green: CGFloat((rgbValue & 0xFF00) >> 8)/255.0, blue: CGFloat((rgbValue & 0xFF))/255.0, alpha: 1.0)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        //|.Sound|.Alert
        UIApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert)
        WXApi.registerApp(kAppKey_WeiXin)
        WeiboSDK.registerApp(kAppKey_WeiBo)
        WeiboSDK.enableDebugMode(true)
        FavManager.sharedFavManager
        for font:AnyObject in UIFont.familyNames() {
            println("\(font)")
        }
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
    
    func application(application: UIApplication!,
        openURL url: NSURL!,
        sourceApplication: String!,
        annotation: AnyObject!) -> Bool {
        return true
    }
    
    func application(application: UIApplication!,
        url: NSURL!) -> Bool {
        return true
    }
    
    func application(application: UIApplication!,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
           NSLog("My token is: %@", deviceToken);
    }
    
    func application(application: UIApplication!,
        didFailToRegisterForRemoteNotificationsWithError error: NSError!) {
            NSLog("My token is: %@", error);
    }

}

