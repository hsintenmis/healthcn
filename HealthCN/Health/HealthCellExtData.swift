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
    
    // field 相關 圖片與文字顏色值設定
    private let dictColor = ["normal":"303030", "none":"909090", "good":"3366CC", "bad":"FF6666"]
    
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
    * 'result', 'good'正常, 'bad'不正常, 'none'無數值, 可以給'圖片使用'
    */
    func getExtCell(mCell: HealthValCell, dictData: [String:String])->UITableViewCell {
        let newCellData = mHealthExplainTestData.GetTestExplain(dictData["field"]!, jobjItem: dictData)
        let strResult = newCellData["result"]!
        let dbVal = Double(dictData["val"]!)!
        
        // 顏色預設值
        mCell.labName.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        mCell.labStatu.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        mCell.labVal.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        mCell.labUnit.textColor = pubClass.ColorHEX(dictColor["normal"]!)
        
        // 沒有數值（數值 = 0）
        if ( dbVal == 0.0 ) {
            mCell.labName.textColor = pubClass.ColorHEX(dictColor["none"]!)
            mCell.labStatu.textColor = pubClass.ColorHEX(dictColor["none"]!)
            mCell.labVal.textColor = pubClass.ColorHEX(dictColor["none"]!)
            mCell.labUnit.textColor = pubClass.ColorHEX(dictColor["none"]!)
            
            mCell.labStatu.text = pubClass.getLang("health_nodata")
            mCell.labMsg.text = ""
            
            return mCell
        }
        
        // 有數值 沒有說明
        if ( dbVal > 0.0 && strResult == "none") {
            mCell.labStatu.text = pubClass.getLang("health_noexplain")
            mCell.labMsg.text = ""
            
            return mCell
        }
        
        // 有說明
        mCell.labStatu.text = newCellData["stat"]
        mCell.labMsg.text = pubClass.getLang("healthstandvalexplain") + "\n" + newCellData["explain"]!
        
        if (strResult == "good" || strResult == "bad") {
            mCell.labName.textColor = pubClass.ColorHEX(dictColor[strResult]!)
            mCell.labStatu.textColor = pubClass.ColorHEX(dictColor[strResult]!)
            mCell.labVal.textColor = pubClass.ColorHEX(dictColor[strResult]!)
            mCell.labUnit.textColor = pubClass.ColorHEX(dictColor[strResult]!)
        }
        
        // 特殊項目腰臀比，顯示腰圍臀圍數值
        if (dictData["field"] == "whr" && newCellData["stat_ext"] != nil) {
            mCell.labStatu.text = newCellData["stat"]! + "\n" + newCellData["stat_ext"]!
        }
        
        return mCell
    }

}