//
// News 頁面，使用 containerView, 根據不同 class 帶入對應的 ViewControler
//

import UIKit
import Foundation

/**
 * News主頁面, 帶入二個 view with class, 如下：
 *  店家新訊：NewsStore
 *  官網新訊：NewsOffice
 */
class NewsMain: UIViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var navyTopBar: UINavigationItem!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // News 的資料集, store and office, jsonArray 型態
    private var aryNewsStore: Array<Dictionary<String, AnyObject>> = []
    private var aryNewsOffice: Array<Dictionary<String, AnyObject>> = []
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // 初始與設定 VCview 內的 field
            self.initViewField();
            
            //HTTP 連線取得 news JSON data
            self.StartHTTPConn()
            
            return
        }
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * HTTP 連線取得 news JSON data
     */
    func StartHTTPConn() {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_getnews"
        
        // HTTP 開始連線
        pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 解析正確的 http 回傳結果，設定本 class News JSON 資料
        let dictRespon = dictRS["data"] as! Dictionary<String, AnyObject>
        let dictContent = dictRespon["content"] as! Dictionary<String, AnyObject>
        
        if let tmpData = dictContent["store"] as? Array<Dictionary<String, AnyObject>> {
            self.aryNewsStore = tmpData
        }
        
        if let tmpData = dictContent["office"] as? Array<Dictionary<String, AnyObject>> {
            self.aryNewsOffice = tmpData
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.setContainerView("NewsStore")
        })
    }

    
    /**
     * 設定 viewContainer 內容
     * @param flag : ex. 'NewsStore', 'NewsOffice'
     */
    private func setContainerView(flag: String!) {
        var strTitle = ""
        viewContainer.clearsContextBeforeDrawing = true
        
        if (flag == "NewsStore") {
            var mSubVC: NewsStore
            mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("NewsStore") as! NewsStore
            mSubVC.aryAllData = self.aryNewsStore
            
            viewContainer.addSubview(mSubVC.view)
            self.addChildViewController(mSubVC)
            
            strTitle = pubClass.getLang("news_store")
        }
        else if (flag == "NewsOffice") {
            var mSubVC: NewsOffice
            mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("NewsOffice") as! NewsOffice
            mSubVC.aryAllData = self.aryNewsOffice
            
            viewContainer.addSubview(mSubVC.view)
            self.addChildViewController(mSubVC)
            
            strTitle = pubClass.getLang("news_office")
        }
        
        navyTopBar.title = strTitle
    }
    
    /**
     * 點取 店家新訊: NewsStore
     */
    @IBAction func actNewsStore(sender: UIBarButtonItem) {
        self.setContainerView("NewsStore")
    }
    
    /**
     * 點取 官網新訊: NewsOffice
     */
    @IBAction func actNewsOffice(sender: UIBarButtonItem) {
        self.setContainerView("NewsOffice")
    }
    
    /**
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}