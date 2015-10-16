//
// 主選單
//

import UIKit
import Foundation

/**
* 主選單 class
*/
class MainCategory: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var viewScrolle: UIScrollView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    var popLoading: UIAlertController! // 彈出視窗 popLoading
    let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
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
        popLoading = pubClass.getPopLoading()

        // 設定相關 UI text 欄位 delegate to textfile
        self.initViewField()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // HTTP 連線取得本頁面需要的資料
        self.StartHTTPConn()
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            self.viewScrolle.contentSize.height = 700.0
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
        
        var strConnParm: String = "";
        for (strParm, strVal) in dictParm {
            strConnParm += "\(strParm)=\(strVal)&"
        }
        
        // HTTP 開始連線
        self.mVCtrl.presentViewController(self.popLoading, animated: true, completion: nil)
        pubClass.startHTTPConn(strConnParm, callBack: HttpResponChk)
    }
    
    /**
    * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
    */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        popLoading.dismissViewControllerAnimated(true, completion: {})
        
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

}