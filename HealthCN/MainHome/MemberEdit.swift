//
// TableView Statuc, ContainerView 的延伸 view
//

import Foundation
import UIKit


/**
 * News主頁面, 帶入二個 view with class, 如下：
 *  店家新訊：NewsStore
 *  官網新訊：NewsOffice
 */
class MemberEdit: UITableViewController {
    @IBOutlet var tableList: UITableView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // TableView datasource
    
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
            //self.initViewField();
            
            //HTTP 連線取得 news JSON data
            //self.StartHTTPConn()
            
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}