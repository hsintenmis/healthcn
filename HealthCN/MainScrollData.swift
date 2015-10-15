//
// MainCategory 內的 ScrollView VC<BR>
// 本 class顯示: 會員資料, 今日健康資料/今日提醒, 各頁面跳轉
//

import UIKit
import Foundation

/**
 * ScrollView 內的 VC, 本 class顯示: 會員資料<BR>
 * 今日健康資料/今日提醒, 各頁面跳轉
 */
class MainScrollData: UIViewController {
    
    @IBOutlet weak var labMemberName: UILabel!
    @IBOutlet weak var labStoreName: UILabel!
    @IBOutlet weak var labStoreTel: UILabel!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    // 本 class 需要使用的 json data
    var parentData: Dictionary<String, AnyObject>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定相關 UI text 欄位
        //self.initViewField()
    }
    
    /**
    * 設定本 class 需要使用的 json data
    */
    internal func setParam(parm: Dictionary<String, AnyObject>) {
        parentData = parm
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    internal func initViewField() {
        let dictMember = (parentData["content"])?.objectForKey("member") as! Dictionary<String, AnyObject>
        
        labMemberName.text = dictMember["usrname"] as? String
        labStoreName.text = dictMember["store_name"] as? String
        labStoreTel.text = dictMember["up_tel"] as? String
    }
    
    

}