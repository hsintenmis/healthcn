//
// 官網新訊詳細內容
// URL 網址如：
// publicsh.hsinten.com.tw/storecn/
// ?acc=XXX&psd=XXX&po=news&op=company&fm_data[id]=jobj["id"]
//

import UIKit
import Foundation

/**
 * 官網新訊詳細內容 class,
 */
class NewsOfficeDetail: UIViewController {
    @IBOutlet weak var webviewOffice: UIWebView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate

    /**
     * 前一個頁面傳入的資料, 參數如下<BR>
     * title, content, pict:'img_店家編號_流水號.png'
     */
    var parentData: Dictionary<String, String>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        //print(parentData)
        self.initViewField()

        // WebView 設定
        let strURL = "\(pubClass.D_HTEURL)?acc=\(mAppDelegate.V_USRACC!)&psd=\(mAppDelegate.V_USRPSD!)&po=news&op=company_content&fm_data[id]=\(parentData["id"]!)"
        
        let request = NSURLRequest(URL: NSURL(string: strURL)!)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.webviewOffice.loadRequest(request)
        })
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}