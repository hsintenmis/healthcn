//
// 直接連線 web url 開啟網頁
//

import UIKit
import Foundation

/**
 * 健康數值資料圖表，webView 顯示
 */
class HealthWebChart: UIViewController {
    // 固定參數
    //let D_WEBURL = "http://public.hsinten.com.tw/storecn/"
    private var D_WEBURL: String = ""

    // @IBOutlet
    @IBOutlet weak var webChart: UIWebView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // parent VC
    var mVCtrlParent: ReservationAdd!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        D_WEBURL = pubClass.D_HTEURL
    }
    
    override func viewDidAppear(animated: Bool) {
        // load Web view
        let strURL = D_WEBURL + "?acc=" + mAppDelegate.V_USRACC! + "&psd=" + mAppDelegate.V_USRPSD! + "&po=stats"
        
        dispatch_async(dispatch_get_main_queue(), {
            self.webChart.loadRequest(NSURLRequest(URL: NSURL(string: strURL)!))
        })
        
        return
    }
    
    /**
     * [我知道了] 彈出視窗, 新增資料完成後跳轉其他 class
     */
    func popResponResult(Msg strMsg: String!) {
        let mAlert = UIAlertController(title: pubClass.getLang("sysprompt"), message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        // '確定' btn
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("i_see"), style: UIAlertActionStyle.Default, handler:{ (action: UIAlertAction!) in
            
            // 本 class 結束
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // '取消' btn
        mAlert.addAction(UIAlertAction(title: pubClass.getLang("cancel"), style: UIAlertActionStyle.Default, handler:nil))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        popResponResult(Msg: pubClass.getLang("health_chartview_returnmsg"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}