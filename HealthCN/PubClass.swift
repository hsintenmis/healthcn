//
// 網路存取設定
// info.plist 設定 NSAppTransportSecurity => dict: NSAllowsArbitraryLoads = YES
//

import Foundation
import UIKit

/**
* 本專案所有的設定檔與公用 method
*/
class PubClass {
    // public
    let D_WEBURL = "http://pub.mysoqi.com/store_cn/001/"
    var AppDelg: AppDelegate
    var aryLangCode = ["default", "zh-Hans"]  // 本專案語系
    
    // private property
    private let mVCtrl: UIViewController!;
    
    /**
    * init
    */
    init(viewControl: UIViewController) {
        mVCtrl = viewControl;
        AppDelg = AppDelegate()
    }
    
    /**
    * 取得 prefer data, NSUserDefaults<br>
    * 目前 key: 'prefAcc', 'prefPsd', 'prefLang', 'prefIssave'
    */
    func getPrefData(strKey: String)->AnyObject? {
        return NSUserDefaults(suiteName: "standardUserDefaults")?.objectForKey(strKey);
    }
    
    /**
     * 回傳 pref data, Dictionary 格式<BR>
     * key : acc, psd, save(登入頁面儲存 switch), lang
     */
    func getPrefData()->Dictionary<String, AnyObject> {
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        var dictPref = Dictionary<String, AnyObject>()
        
        dictPref["acc"] = ""
        dictPref["psd"] = ""
        dictPref["issave"] = true
        dictPref["lang"] = AppDelg.V_LANGCODE
        
        // 取得 pref data
        if let strAcc: String = mPref.objectForKey("acc") as? String {
            dictPref["acc"] = strAcc
        }
        
        if let strPsd: String = mPref.objectForKey("psd") as? String {
            dictPref["psd"] = strPsd
        }
        
        if let bolSave: Bool = mPref.objectForKey("issave") as? Bool {
            dictPref["issave"] = bolSave
        }
        
        return dictPref
    }
    
    /**
    * 輸入字串轉換為指定語系文字<BR>
    * 繁體: Base.lproj     => default.strings<BR>
    * 簡體: zh-Hans.lproj  => zh-Hans.strings<BR>
    * 英文: en.lproj       => en.strings<BR>
    */
    func getLang(strCode: String!)->String{
        return NSLocalizedString(strCode, tableName: AppDelg.V_LANGCODE, bundle:NSBundle.mainBundle(), value: "", comment: "")
    }
    
    /**
    * 取得 prefer 的 user data, ex. acc, psd ...
    */
    func getUserData()->[String : String] {
        var aryUser = Dictionary<String, String>()
        aryUser["acc"] = "kevin"
        aryUser["psd"] = "12345"
        
        return aryUser
    }
    
    /**
     * [我知道了] 彈出視窗
     */
    func popIsee(var Title strTitle: String? = nil, Msg strMsg: String!) {
        if strTitle == nil {
            strTitle = getLang("sysprompt")
        }
        
        let mAlert = UIAlertController(title: strTitle, message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:getLang("i_see"), style: .Default, handler:{
            (action: UIAlertAction!) in
            // print("Handle Ok logic here")
        }))
        
        mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
    }
    
    /**
     * 資料傳送中/讀取中 progress pop window
     */
    func getPopLoading()->UIAlertController {
        let mAlert = UIAlertController(title: "", message: getLang("datatranplzwait"), preferredStyle: UIAlertControllerStyle.Alert)
        mAlert.restorationIdentifier = "popLoading"
        
        return mAlert
        //mViewControl.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    /**
     * HTTP 連線, 使用 post 方式, 'callBack' 需要實作
     */
    func startHTTPConn(strConnParm: String!, callBack: (NSData?)->Void ) {
        // 產生 http Request
        let mRequest = NSMutableURLRequest(URL: NSURL(string: self.D_WEBURL)!)
        mRequest.HTTPBody = strConnParm.dataUsingEncoding(NSUTF8StringEncoding)
        mRequest.HTTPMethod = "POST"
        mRequest.timeoutInterval = 10
        mRequest.HTTPShouldHandleCookies = false
        
        // 產生 'task' 使用閉包
        let task = NSURLSession.sharedSession().dataTaskWithRequest(mRequest) {
            data, response, error in
            
            if error != nil {
                callBack(nil)
            } else {
                callBack(data!)
            }
        }
        
        task.resume()
    }
    
    /**
     * Keyboard 相關<BR>
     * 宣告 NSNotificationCenter, Keyboard show/hide 使用
     * <BR>
     * 需要實作: <BR>
     *   keyboardWillShow(note: NSNotification)<BR>
     *   keyboardWillHide(note: NSNotification)<BR>
     *
     */
    func setKeyboardNotify() {
        NSNotificationCenter.defaultCenter().addObserver(
            mVCtrl,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            mVCtrl,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        // 設定點取 view 空白處，執行鍵盤關閉程序
        let mTap = UITapGestureRecognizer(target: mVCtrl, action: "keyboardHide:")
        mTap.cancelsTouchesInView = false
        mVCtrl.view.addGestureRecognizer(mTap)
    }
    
    /**
     * Keyboard 相關<BR>
     * 虛擬鍵盤將要 [開啟] 時執行相關程序，view 往上提升
     */
    func KBShowProc(note: NSNotification) {
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = NSTimeInterval(keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        
        // 偵測虛擬鍵盤高度
        //let keyboardFrameValue = keyboardAnimationDetail[UIKeyboardFrameBeginUserInfoKey]! as! NSValue
        //let keyboardFrame = keyboardFrameValue.CGRectValue()
        //let hight_keyboard = -keyboardFrame.size.height
        
        // 使用固定高度
        let hight_fix: CGFloat = -40.0
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.mVCtrl.view.frame = CGRectOffset(self.mVCtrl.view.frame, 0, hight_fix)
        })
    }
    
    /**
     * Keyboard 相關<BR>
     * 虛擬鍵盤將要 [關閉] 時執行相關程序, ，view 往下
     */
    func KBHideProc(note: NSNotification) {
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = NSTimeInterval(keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber)
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.mVCtrl.view.frame = CGRectOffset(self.mVCtrl.view.frame, 0, -(self.mVCtrl.view.frame.origin.y))
        })
    }
    
    /**
     * 設定 UIViewControler 的背景
     */
    func setVCBackgroundImg(strFilename: String) {
        UIGraphicsBeginImageContext(mVCtrl.view.frame.size);
        (UIImage(named: strFilename))?.drawInRect(mVCtrl.view.bounds)
        let mImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        mVCtrl.view.backgroundColor = UIColor(patternImage: mImage)
    }
    
}