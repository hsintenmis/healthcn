//
// 使用 containerView, 根據不同 class 帶入對應的 ViewControler
//

import UIKit
import Foundation

/**
 * Soqibed 使用記錄頁面, 帶入二個 view with class, 如下：
 *  私人模式＋標準模式 記錄：SoqibedLog
 *  全部紀錄 : SoqibedLogAll
 */
class SoqibedMain: UIViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var navyTopBar: UINavigationItem!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // Log 的資料集, private + stand, alllog,  jsonArray 型態
    private var aryLog_priv: Array<Dictionary<String, AnyObject>> = [[:]]
    private var aryLog_stand: Array<Dictionary<String, AnyObject>> = [[:]]
    private var aryLog_all: Array<Dictionary<String, AnyObject>> = [[:]]
    
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
        dictParm["act"] = "memberdata_getsoqibed"
        
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
        
        if let tmpData = dictContent["private"] as? Array<Dictionary<String, AnyObject>> {
            self.aryLog_priv = tmpData
        }
        
        if let tmpData = dictContent["stand"] as? Array<Dictionary<String, AnyObject>> {
            self.aryLog_stand = tmpData
        }
        
        if let tmpData = dictContent["alllog"] as? Array<Dictionary<String, AnyObject>> {
            self.aryLog_all = tmpData
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.setContainerView("priv")
        })
    }
    
    
    /**
     * 設定 viewContainer 內容
     * @param flag : ex. 'NewsStore', 'NewsOffice'
     */
    private func setContainerView(flag: String!) {
        navyTopBar.title = pubClass.getLang("soqibed_mod_\(flag)")
        viewContainer.clearsContextBeforeDrawing = true
        
        if (flag == "priv" || flag == "stand") {
            // 檢查有無資料
            let aryData: Array<Dictionary<String, AnyObject>>
            aryData = (flag == "priv") ? self.aryLog_priv : self.aryLog_stand

            if (aryData.count < 1) {
                let mSubVC: NodataView
                mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("NodataView") as! NodataView
                viewContainer.addSubview(mSubVC.view)
                self.addChildViewController(mSubVC)
            }
            
            else {
                var mSubVC: SoqibedLoglist
                mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("SoqibedLoglist") as! SoqibedLoglist
                
                // 根據 'flag', 設定 child class param
                mSubVC.aryAllData = (flag == "priv") ? self.aryLog_priv : self.aryLog_stand
                
                // VC 加到 ContainerView
                mSubVC.strLogType = flag
                viewContainer.addSubview(mSubVC.view)
                self.addChildViewController(mSubVC)
            }
        }
        
        // 全部log list資料
        else if (flag == "all" ) {
            // 檢查有無資料
            if (self.aryLog_all.count < 1) {
                let mSubVC: NodataView
                mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("NodataView") as! NodataView
                viewContainer.addSubview(mSubVC.view)
                self.addChildViewController(mSubVC)
            }
            
            var mSubVC: SoqibedLogAll
            mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("SoqibedLogAll") as! SoqibedLogAll
            
            // 根據 'flag', 設定 child class param
            mSubVC.aryAllData = self.aryLog_all
            
            // VC 加到 ContainerView
            viewContainer.addSubview(mSubVC.view)
            self.addChildViewController(mSubVC)
        }
    }
    
    /**
     * 點取 私人模式紀錄: NewsStore
     */
    @IBAction func actPriv(sender: UIBarButtonItem) {
        self.setContainerView("priv")
    }
    
    /**
     * 點取 標準模式紀錄: NewsOffice
     */
    @IBAction func actStand(sender: UIBarButtonItem) {
        self.setContainerView("stand")
    }
    
    /**
     * 點取  全部紀錄: NewsOffice
     */
    @IBAction func actAll(sender: UIBarButtonItem) {
        self.setContainerView("all")
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