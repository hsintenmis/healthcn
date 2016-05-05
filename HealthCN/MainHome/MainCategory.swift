//
// TableView with ScrollView
// ScrollView 的 Container 顯示時執行 HTTP 連線取得資料集
//
// 本 class 設定與接收 APNS 推播 相關資料
// 取得本裝置 APNS 的 TOKEN dev id 儲存至 DB
//

import UIKit
import Foundation

/**
* 主選單 class
*/
class MainCategory: UIViewController {
    @IBOutlet weak var viewContainer: UIView!
    
    // common property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    //let localNotification = UILocalNotification()

    // 前一個頁面傳入的資料
    var parentData: Dictionary<String, AnyObject>!
    
    // 子頁面 'MainScrollData'
    private var mMainScrollData: MainScrollData!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 訊息列通知設定，註冊通知使用聲音、訊息文字，通知無分類
        /*
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(
                forTypes: [ .Sound, .Alert, .Badge], categories: nil)
        )
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        //localNotification.applicationIconBadgeNumber = 0;
    
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // Container 子頁面 'MainScrollData'
        if (strIdent == "MainScrollData") {
            mMainScrollData = segue.destinationViewController as? MainScrollData
            mMainScrollData.dictAllData = parentData
            
            return
        }
        
        return
    }
    
    /**
    * act, 點取 '刷新' btn, HTTP重新連線讀取資料
    */
    @IBAction func actReload(sender: UIBarButtonItem) {
        // 執行 child 'MainScrollData' http 連線重新取得資料
        mMainScrollData?.StartHTTPConn()
    }

    /**
    * act, 點取 '登出' btn
    */
    @IBAction func actLogout(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //立刻發送通知訊息
    /*
    private func showNotificationNow(){
    // 建立通知物件
    let myNotification: UILocalNotification = UILocalNotification()
    
    // 通知訊息內容
    myNotification.alertBody = "通知訊息測試使用 Now"
    
    // 時區Timezone設定
    myNotification.timeZone = NSTimeZone.defaultTimeZone()
    
    // 10秒後發送訊息
    myNotification.fireDate = NSDate(timeIntervalSinceNow: 15)
    
    // 將通知物件入通知排程
    UIApplication.sharedApplication().scheduleLocalNotification(myNotification)
    }
    */
}