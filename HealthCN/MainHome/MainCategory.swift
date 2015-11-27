//
// TableView with ScrollView
// ScrollView 的 Container 顯示時執行 HTTP 連線取得資料集
//

import UIKit
import Foundation

/**
* 主選單 class
*/
class MainCategory: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!

    // 前一個頁面傳入的資料
    var parentData: Dictionary<String, AnyObject>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(parentData)
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    /**
    * HTTP重新連線讀取資料
    */
    @IBAction func actReload(sender: UIBarButtonItem) {
        // 由 class 'MainScrollData' declare
        NSNotificationCenter.defaultCenter().postNotificationName("ReloadPage", object: nil)
    }

    /**
    * 登出
    */
    @IBAction func actLogout(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}