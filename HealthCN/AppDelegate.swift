//
// AppDelegate.swift
// HealthCN
//
// 本 class 使用推播
// 開發用的 iPad token id: 移除 app 時會隨時改變
// 1fe530ec4c1407b466499cb903f279d08d67f77494a3402cd3496e4fdafb5ab0
// 特徵碼：9c3f0ea08c1078df13ef4ae23bbc2e97fb76e500
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // 全域參數
    var V_USRACC: String?, V_USRPSD: String?
    var V_LANGCODE: String = "default"
    
    /** 裝置推播用的 dev token ID */
    var V_SPANTOKENID: String = ""
    
    /** 裝置推播用, 接收到 APNS 訊息，設定到此變數中 */
    var V_SPANALERTMSG: String = ""

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 推播使用, Push通知
        let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: [ .Sound, .Alert, .Badge], categories: nil )
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
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

    /**
     * 推播相關功能
     * 本機向 apple APNS server 註冊成功後，本機 Device Token 取得
     * 將本機的 APNS token device id 儲存到 'store_cn' DB 以備使用
     */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        //print(characterSet)
        
        let deviceTokenString: String = (deviceToken.description as NSString).stringByTrimmingCharactersInSet( characterSet).stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        //Print出Device Token
        //print( deviceTokenString )
        V_SPANTOKENID = deviceTokenString
    }
    
    /**
     * 推播相關功能
     * 向遠端APNS註冊失敗的事件
     */
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        print( error.localizedDescription )
    }
    
    /**
     * 推播相關功能
     * APP 開啟狀態時，APNS 發送收到訊息
     */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        //print("Recived: \(userInfo)")
        //Parsing userinfo:
        //let temp: Dictionary<NSObject, AnyObject> = userInfo
        
        application.applicationIconBadgeNumber = 0
        
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject> {
            V_SPANALERTMSG = info["alert"] as! String
        }
    }
    
}