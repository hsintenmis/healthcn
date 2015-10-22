//
// 能量檢測 詳細內容
//

import UIKit
import Foundation

/**
 * 能量檢測詳細內容 class,
 */
class MeadDetail: UIViewController {
    @IBOutlet weak var tableDetail: UITableView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    /**
     * 前一個頁面傳入的資料, 參數如下<BR>
     */
    var parentData: Dictionary<String, String>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        print(parentData)
        self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        //tableDetail.reloadData()
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
