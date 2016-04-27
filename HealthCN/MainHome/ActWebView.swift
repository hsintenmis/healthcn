//
// WebView
//

import UIKit
import Foundation

/**
 * 活動專區，直接連線 WebView 處理
 */
class ActWebView: UIViewController {
    // 固定參數設定 TODO
    private var strURL = "?data[acc]=%@&data[psd]=%@"

    // @IBOutlet
    @IBOutlet weak var navyBar: UINavigationBar!
    @IBOutlet weak var webviewData: UIWebView!
    @IBOutlet weak var labLoading: UILabel!
    @IBOutlet weak var viewLoading: UIActivityIndicatorView!
    
    // public property
    var dictData: Dictionary<String, String>!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        labLoading.alpha = 1.0
        viewLoading.startAnimating()
        
        // Navy Title, URL
        navyBar.topItem!.title = dictData["title"]
        
        strURL = (dictData["url"]! as String) + strURL
        strURL = String(format: strURL, arguments: [mAppDelegate.V_USRACC!, mAppDelegate.V_USRPSD!])

    }
    
    /**
     * viewDidAppear
     */
    override func viewDidAppear(animated: Bool) {
        // WebView 設定
        let request = NSURLRequest(URL: NSURL(string: strURL)!)
        self.webviewData.loadRequest(request)
    }
    
    /** WebView delegate Start */
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        return
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType)->Bool {
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        return
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        labLoading.alpha = 0.0
        viewLoading.stopAnimating()
    }
    /** WebView delegate End */
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}