//
// 主選單
//

import UIKit
import Foundation

/**
* 主選單 class
*/
class MainCategory: UIViewController {
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // 前一個頁面傳入的資料
    var parentData: Dictionary<String, AnyObject>!

    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(parentData)
        
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定相關 UI text 欄位 delegate to textfile
        //self.initViewField()
        
        //let mMainMemberInfo = MainMemberInfo(dictMember: parentData)

    }
    
    
    /**
    * 初始與設定 VCview 內的 field
    */
    func initViewField() {
    }
}