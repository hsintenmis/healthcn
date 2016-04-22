//
// WebView
//

import UIKit
import Foundation

/**
 * 促銷活動一次性
 * 2016/03/01 ~ 2016/05/31 美利瘦身比賽
 *
 * url: http://cnwww.mysoqi.com/merit_game/index.php
 * 參數如下：
 * data[acc]=MT000001[psd]=00000&data[func]=shopboard#MT000083
 *
 */
class Act20160301: UIViewController {
    // 固定參數設定 TODO
    private var strFixURL = "merit_game/index.php"
    private let aryURLAct = ["shopboard", "areaboard"]  // 區域/本店 排名
    
    @IBOutlet weak var webviewData: UIWebView!
    @IBOutlet weak var labLoading: UILabel!
    @IBOutlet weak var viewLoading: UIActivityIndicatorView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        strFixURL = pubClass.D_HTEURL + strFixURL
        
        self.initViewField()
    }
    
    override func viewWillAppear(animated: Bool){
        // WebView 設定與顯示
        self.showWEBView(0)
    }
    
    /**
    * 選擇 區域/店家, 顯示  webview
    *
    * @param intPosition: 0=店家, 1=區域
    */
    private func showWEBView(intPosition: Int) {
        let strURL = "\(self.strFixURL)?data[func]=\(aryURLAct[intPosition])&data[acc]=\(mAppDelegate.V_USRACC!)&data[psd]=\(mAppDelegate.V_USRPSD!)#\(mAppDelegate.V_USRACC!)"

        let request = NSURLRequest(URL: NSURL(string: strURL)!)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.webviewData.loadRequest(request)
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
    }
    
    /** WebView delegate Start */
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        //print("Webview fail with error \(error)");
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType)->Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        labLoading.alpha = 1.0
        viewLoading.alpha = 1.0
        //print("Webview started Loading")
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        labLoading.alpha = 0.0
        viewLoading.alpha = 0.0
        //print("Webview did finish load")
    }
    /** WebView delegate End */
     
    /**
    * Swicth action, 選擇 區域/店家 排行
    */
    @IBAction func swchRankType(sender: UISegmentedControl) {
        self.showWEBView(sender.selectedSegmentIndex)
    }
     
     /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}