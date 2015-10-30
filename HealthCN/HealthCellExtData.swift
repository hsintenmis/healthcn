//
// 健康檢測 TableView Cell 延伸相關資料
// Cell 的外觀樣式, cell 特殊欄位的文字產生
//

import UIKit
import Foundation

class HealthCellExtData {

    // Common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 健康檢查項目的對應 '代碼', ex. bmi, ...
    private var aryTestField: [String] = []
    
    // field 相關 圖片與文字顏色值設定, ex. 'good' => 'color', 'img' ...
    private var mapItemView: [String: [String:Int]] = [:]
    
    // 資料分析 class
    //private HealthExplainTestData classDataExplain;
    
    /**
    * init
    */
    init() {
    }
    
    /**
     * Cust init
     */
    func CustInit(mVC: UIViewController) {
        mVCtrl = mVC
        pubClass = PubClass(viewControl: mVCtrl)
        aryTestField = HealthDataInit().D_HEALTHITEMKEY
    }
    
    /**
    * 帶入相關參數產生 Cell 對應資料
    */
    func getExtCell(mCell: UITableViewCell)->UITableViewCell {
        return mCell
    }

}