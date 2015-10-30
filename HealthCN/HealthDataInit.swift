//
//  健康檢測資料初始 Class
//

import UIKit
import Foundation

class HealthDataInit {
    // 固定參數, 健康項目的 Item key
    let D_HEALTHITEMKEY = ["weight", "height", "bmi", "fat", "water","calory", "bone", "muscle", "vfat","whr", "waistline", "hipline", "sugar_before", "sugar_after", "sbp", "dbp", "heartbeat","temperature"]

    // Common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 指定日期的全部健康項目資料 dict array
    private var mapAllData: [String: [String:String]] = [:]
    
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
        
        self.initEmptyData()
    }
    
    /**
    * 回傳指定日期的全部健康項目資料 dict array<BR>
    * 回傳如: 'bmi' => ['name'=>"BMI", 'val'=>"20.1", ...], ...
    */
    func GetAllTestData()->[String: [String:String]] {
        return mapAllData
    }
    
    /**
    * 取得指定健康檢測項目的資料<BR>
    * @param strKey : ex. weight<BR>
    * @return Map data, ex. 'name', 'unit', 'val', 'group'
    */
    func GetSingleTestData(strKey: String)->[String:String]! {
        return mapAllData[strKey];
    }
    
    /**
    * 帶入指定日期的資料，重新產生該日期的健康項目資料
    */
    func setAllTestData(dictData: [String:String]?) {
        var val: Double  = 0.0
        
        if (dictData == nil) {
            for strKey: String in D_HEALTHITEMKEY {
                self.setUnitNameVal(strKey, doubleVal: val)
            }
            
            return
        }
        
        for strKey: String in D_HEALTHITEMKEY {
            val = 0.0
            
            if (dictData![strKey] != nil)   {
               val = Double(dictData![strKey]!)!
            }
            
            self.setUnitNameVal(strKey, doubleVal: val)
        }
    }
    
    /**
    * 初始代入的資料, 重新產生全部健康項目 List data, 無資料傳入
    * @param jobjData
    */
    func setAllTestDataEmpty() {
        for strKey in D_HEALTHITEMKEY {
            self.setUnitNameVal(strKey, doubleVal: 0.0);
        }
    }
    
    /**
     * 初始與產生空值的 list data
     * <P>
     * ary0 => 'bmi' : 'name', 'unit', 'val', 'group'(群組名稱，編輯頁面使用)
     * <P>
     * whr腰臀比, waistline 腰圍 hipline 臀圍 sbp 收縮壓 dbp 舒張壓
     */
    private func initEmptyData() {
        // lopp 全部 [固定] 健康檢測項目
        for strKey: String in D_HEALTHITEMKEY {
            var mapItem: [String:String] = [:]
            mapItem["name"] = pubClass.getLang("healthname_\(strKey)")
            mapItem["field"] = strKey
            mapAllData[strKey] = mapItem
            self.setUnitNameVal(strKey, doubleVal: 0.0);
        }
    }
    
    /**
     * 細部設定，群組, 度量衡單，數值顯示方式(0 or 0.0 or 0.00)
     * <P>
     * 特殊 Group : weight, whr, sugar, bp<BR>
     */
    private func setUnitNameVal(strKey: String, doubleVal: Double) {
        var mapItem = mapAllData[strKey]!
        mapItem["val"] = String(format:"%.1f", doubleVal)
        mapItem["unit"] = "%"
        mapItem["group"] = strKey
        
        // 身高 height
        if (strKey == "height") {
            mapItem["unit"] = pubClass.getLang("name_height")
            mapItem["group"] = "bmi"
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // 體重 weight
        if (strKey == "weight") {
            mapItem["unit"] = pubClass.getLang("name_weight")
            mapItem["group"] = "bmi"
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // BMI
        if (strKey == "bmi") {
            mapItem["unit"] = ""
            mapAllData[strKey] = mapItem

            return;
        }
        
        // 體脂率 fat, 水分 water, 骨骼bone, 肌肉muscle, 體脂肪vfat
        if (strKey == "fat" || strKey == "water" || strKey == "bone" || strKey == "muscle" || strKey == "vfat") {
            mapAllData[strKey] = mapItem
                
            return;
        }
        
        // 基礎代謝 calory
        if (strKey == "calory") {
            mapItem["val"] = String(Int(doubleVal))
            mapItem["unit"] = "Kcal"
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // whr 腰臀比
        if (strKey == "whr") {
            mapItem["val"] = String(format:"%.2f", doubleVal)
            mapItem["unit"] = ""
            mapItem["group"] = "whr"
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // waistline 腰圍, hipline 臀圍
        if (strKey == "waistline" || strKey == "hipline") {
            mapItem["unit"] = pubClass.getLang("name_height")
            mapItem["group"] = "whr"
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // sugar_before 血糖餐前, sugar_after 血糖飯後
        if (strKey == "sugar_before" || strKey == "sugar_after") {
            mapItem["unit"] = "mmo/L"
            mapItem["group"] = "sugar"
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // sbp 收縮壓, dbp舒張壓
        if (strKey == "sbp" || strKey == "dbp") {
            mapItem["unit"] = "mmHg"
            mapItem["group"] = "bp"
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // heartbeat 心跳
        if (strKey == "heartbeat") {
            mapItem["val"] = String(Int(doubleVal))
            mapItem["unit"] = pubClass.getLang("heartbeatsunitname")
            mapAllData[strKey] = mapItem
            
            return;
        }
        
        // temperature 體溫
        if (strKey == "temperature") {
            mapItem["unit"] = pubClass.getLang("temperature_unitname_P")
            mapAllData[strKey] = mapItem
            
            return;
        }
        
    }
    
}