//
// 主選單
//

import UIKit
import Foundation

/**
* 主選單 class
*/
class MainCategory: UIViewController {
    
    @IBOutlet weak var viewScrolle: UIScrollView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 前一個頁面傳入的資料
    var parentData: Dictionary<String, AnyObject>!
    
    // 其他 class
    var mMainScrollData: MainScrollData!  // ScrollView 的 VC calss
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(parentData)
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定相關 UI text 欄位 delegate to textfile
        self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // HTTP 連線取得本頁面需要的資料
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
    * HTTP 連線取得本頁面需要的資料
    */
    private func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_homepage"
        
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
            return
        }
        
        // 解析正確的 http 回傳結果，傳遞 JSONdata, 設定 'MainScrollData' view 資料
        let dictRespon = dictRS["data"] as! Dictionary<String, AnyObject>
        //print("JSONDictionary! \(dictRespon)")
        
        self.mMainScrollData.setParam(dictRespon)
        
        //self.mMainScrollData.initViewField()
        self.mMainScrollData.resetViewField()
    }

    /**
    * Segue 判別跳轉哪個頁面, 給 scrollview 的 childView 使用
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 跳轉 'MainScrollData' class
        if segue.identifier == "MainScrollData"{
            self.mMainScrollData = segue.destinationViewController as! MainScrollData
        }
        
        return
    }
    
    /**
    * HTTP重新連線讀取資料
    */
    @IBAction func actReload(sender: UIBarButtonItem) {
        // HTTP 開始連線
        self.StartHTTPConn()
    }

    /**
    * 登出
    */
    @IBAction func actLogout(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}