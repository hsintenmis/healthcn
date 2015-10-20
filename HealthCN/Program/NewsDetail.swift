//
// 最新消息詳細內容
//

import UIKit
import Foundation

/**
* 最新消息詳細內容 class,
*/
class NewsDetail: UIViewController {
    //@IBOutlet weak var tableDetail: UITableView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    // 前一個頁面傳入的資料
    var parentData: Dictionary<String, String>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        //print(parentData)
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
        })
    }
    
    /**
    * btn '返回' 點取
    */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}