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
    
    // class, 解釋健康檢測資料，正常或不正常
    private var mHealthExplainTestData = HealthExplainTestData()
    
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
        mHealthExplainTestData.CustInit(mVCtrl)
    }
    
    /**
    * 帶入相關參數產生 Cell 對應資料<BR>
    * ex. ["group": "bmi", "field": "bmi", "unit": "", "val": "0.0", "name": "BMI"]<BR>
    * 回傳如: 
    * 'stat', ex. 正常, 腰臀比超標 ....<BR>
    * 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
    * 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
    * 'result', 正常'good', 不正常'bad', 無數值'none', 可以給'圖片使用'
    */
    func getExtCell(mCell: HealthValCell, dictData: [String:String])->UITableViewCell {
        var newCellData = mHealthExplainTestData.GetTestExplain(dictData["field"]!, jobjItem: dictData)
        
        if (newCellData["result"] == "none") {
            return mCell
        }
        
        //mCell.labStatu.text = newCellData["stat"];
        //mCell.labMsg.text = newCellData["stat_ext"]! + newCellData["explain"]!
        
        return mCell
    }

}