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

    // 前一個頁面傳入的資料
    var parentData: Dictionary<String, AnyObject>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(parentData)
        
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
        
        if (mAppDelegate.V_APNSTOKENID.characters.count > 0) {
            self.startSaveData(mAppDelegate.V_APNSTOKENID)
        }
        //print(mAppDelegate.V_SPANTOKENID)
    }
    
    override func viewDidAppear(animated: Bool) {
        // 檢查裝置推播用, 接收到 APNS 訊息
        if (mAppDelegate.V_APNSALERTMSG.characters.count > 0) {
            self.pubClass.popIsee(Msg: mAppDelegate.V_APNSALERTMSG)
            mAppDelegate.V_APNSALERTMSG = ""
        }
    }
      
    /**
    * HTTP重新連線讀取資料
    */
    @IBAction func actReload(sender: UIBarButtonItem) {
        //showNotificationNow()
        
        // 由 class 'MainScrollData' declare
        NSNotificationCenter.defaultCenter().postNotificationName("ReloadMainScrollData", object: nil)
    }

    /**
    * 登出
    */
    @IBAction func actLogout(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * 執行資料上傳程序, DEV Token ID 上傳
     */
    private func startSaveData(strToken: String!) {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_savetoken"
        dictParm["arg0"] = "ios"
        dictParm["arg1"] = strToken
        
        // HTTP 開始連線
        //pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        //pubClass.closePopLoading()
        
        /*
        // 錯誤
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 上傳與儲存完成，顯示完成訊息
        pubClass.popIsee(Msg: pubClass.getLang("datasavecompleted"))
        */
        
        return
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