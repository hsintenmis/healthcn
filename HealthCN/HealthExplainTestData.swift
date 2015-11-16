/**
* 解釋健康檢測資料，正常或不正常，<BR>
* 顯示說明文字與相關資料
* <P>
*
* 傳入: 健康檢查項目代碼, ex. bmi(參考DB TABLE 'health_member' 欄位)<BR>
* 傳入: 量測數值, 年齡, 性別
* <P>
*
* 回傳: 'stat', ex. 正常, 腰臀比超標 ....<BR>
* 回傳: 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
* 回傳: 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
* 回傳: 'result', 正常'good', 不正常'bad', 無數值'none', 可以給'圖片使用'
*
*/

import UIKit
import Foundation

class HealthExplainTestData {
    // Common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // USER 資料
    private var usrAge: Int = 30
    private var usrGender: String = "M"
    
    // 全部健康項目的資料
    private var mapAllHealthData: [String: [String:String]] = [:]
    
    /**
    * 檢測數值分析後的 map 文字資料
    * <P>
    * 回傳: 'stat', ex. 正常, 腰臀比超標 ....<BR>
    * 回傳: 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
    * 回傳: 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
    * 回傳: 'result', 正常'good', 不正常'bad', 無數值'none', 可以給'圖片使用'
    */
    private var mapResult: [String:String] = [:]
    
    /**
     * Cust init
     */
    func CustInit(mVC: UIViewController) {
        mVCtrl = mVC
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    /**
    * 設定 user 資料
    */
    func SetUserData(age: Int, gender: String) {
        usrAge = age;
        usrGender = gender;
    }
    
    /**
    * 2015/09/01, 設定全部健康項目的資料
    *
    * @param Map <String, Map<String, String>>
    */
    func SetAllHealthData(map: [String: [String:String]]) {
        mapAllHealthData = map
    }

    /**
    * 根據檢測項目, 將檢測數值轉換成正確的數字形式<BR>
    * ex. 'height' => '175', weight => '70.5'
    *
    * @param strField : 檢測項目的代碼, ex. sbp, height
    * @param strVal : 檢測的數值 string
    * @return String
    */
    func GetTestingVal(strField: String, strVal: String)->String {
        // 整數型態的 field
        let aryIntField = ["height", "calory", "sbp", "dbp", "heartbeat"]
        for strItemCode in aryIntField {
            if (strField == strItemCode) {
                if let val: String = strVal {
                    return String(Int(val))
                }
                else {
                    return "0"
                }
            }
        }
        
        // Double 型態
        if let val: String = strVal {
            return String(format: "%.1f", Double(val)!)
        }
        else {
            return "0.0"
        }
    }
    
    
    /**
    * 根據檢測數值，回傳對應結果的 map data
    *
    * @param strTestname
    * @param JSONObject
    *            : 該項目的 key/val 相關資料, ex. 'val', 'name', 'field' ...
    * <P>
    * @return : Map<String, String>, ex.<BR>
    *         回傳: 'stat', ex. 正常, 腰臀比超標 ....<BR>
    *         回傳: 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
    *         回傳: 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
    *         回傳: 'result', 正常'good', 不正常'bad', 無數值'none', 可以給'圖片使用'
    */
    func GetTestExplain(strTestname: String , jobjItem:[String:String] )->[String:String] {
        // 初始 mapData
        mapResult["stat"] = nil
        mapResult["stat_ext"] = nil
        mapResult["explain"] = nil
        mapResult["result"] = "none"
     
        // 檢視數值資料是否 == 0 (表示無數據資料)
        var isDataNull: Bool  = true;
        var doubRs: Double  = 0.0;
        
        if jobjItem["val"] != nil {
            doubRs = Double(jobjItem["val"]!)!
            if (doubRs > 0.0) {
                isDataNull = false
            }
        }
        
        if (isDataNull) {
            return mapResult
        }
        
        /* 根據 field name, 執行相關數值判斷程序 */
        switch (strTestname) {
        case "bmi":
            self._setBMI(doubRs)
        case "fat":
            self._setFat(doubRs)
        case "water":
            self._setWater(doubRs)
        case "calory":
            self._setCalory(doubRs)
        
        // 特殊項目, 腰臀比 whr, 需要其他欄位資料 , waistline, hipline
        case "whr":
            self._setWhr(jobjItem)
        default:
            break
        }

        return mapResult;
    }
    
    /**
    * BMI 分析文字, 正常代碼 '002'
    * <P>
    * 說明為字代碼如. bmirs_001, bmival_002
    */
    private func _setBMI(doubRs: Double) {
        var strCode = "001"
        var strRsCode = "bad"
        
        if (doubRs <= 18.5) {
            strCode = "001";
        } else if (doubRs > 18.5 && doubRs <= 24) {
            strCode = "002";
            strRsCode = "good";
        } else if (doubRs > 24 && doubRs <= 27) {
            strCode = "003";
        } else if (doubRs > 27 && doubRs <= 30) {
            strCode = "004";
        } else if (doubRs > 30 && doubRs <= 35) {
            strCode = "005";
        } else {
            strCode = "006";
        }
        
        // 設定分析文字
        mapResult["stat"] = pubClass.getLang("bmirs_" + strCode)
        mapResult["stat_ext"] = nil
        mapResult["explain"] = pubClass.getLang("bmival_002")
        mapResult["result"] = strRsCode
    }
    
    /**
     * 體脂率fat 分析文字, 正常代碼 '002'男, '005'女
     * <P>
     * 代入'性別', 說明為字代碼如. fatrs_001, ...
     */
    private func _setFat(var doubRs: Double) {
        // doubRs 格式為: 12.1
        doubRs = Double(String(format: "%.2f", doubRs))!
        
        // 設定年齡性別 對應數值資料 map
        var listFixVal_M: [[Double]] = []
        listFixVal_M.append([12.0, 17.0, 22.0, 99.0])
        listFixVal_M.append([12.4, 18.0, 23.0, 99.0])
        listFixVal_M.append([13.0, 18.4, 23.0, 99.0])
        listFixVal_M.append([13.4, 19.0, 23.4, 99.0])
        listFixVal_M.append([14.0, 19.4, 24.0, 99.0])
        
        var listFixVal_F: [[Double]] = []
        listFixVal_F.append([15.0, 22.0, 26.4, 99.0])
        listFixVal_F.append([15.4, 23.0, 27.0, 99.0])
        listFixVal_F.append([16.0, 23.4, 27.4, 99.0])
        listFixVal_F.append([16.4, 24.0, 28.0, 99.0])
        listFixVal_F.append([17.0, 24.4, 28.4, 99.0])
        
        var mapAllFixData: [String: [[Double]]] = [:]
        mapAllFixData["M"] = listFixVal_M
        mapAllFixData["F"] = listFixVal_F
        
        let aryFixAge = [17, 30, 40, 60, 120]
        
        // 比對性別年齡，取得資料所在 poistion
        var listFixVal_curr = mapAllFixData[usrGender]
        var positionVal = 0
        var positionAge = 0
        
        for (var i=0; i<aryFixAge.count; i++) {
            if (usrAge <= aryFixAge[i]) {
                positionAge = i;
                var fixVal = listFixVal_curr![i]
                
                for (var j = 0; j < fixVal.count; j++) {
                    if (doubRs <= fixVal[j]) {
                        positionVal = j;
                        
                        break;
                    }
                }
                break;
            }
        }
        
        // 判定數值是否正常
        let strRsCode: String = (positionVal == 1) ? "good" : "bad"
        
        // 正常/異常文字, 說明文字(顯示對應的年齡,正常範圍值)
        let strPositionVal = String(format: "%03d", positionVal + 1)
        let strPositionAge = String(format: "%03d", positionAge + 1)
        
        
        let strStat = pubClass.getLang("fatrs_" + usrGender + "_"
            + strPositionVal);
        let strExplain = pubClass.getLang("fatval_" + usrGender + "_"
            + strPositionAge);
        
        // 設定分析文字
        mapResult["stat"] = strStat
        mapResult["stat_ext"] = nil
        mapResult["explain"] = strExplain
        mapResult["result"] = strRsCode
    }
    
    /**
    * 含水率 water 分析文字, 正常代碼 '002'男, '005'女
    * <P>
    * 代入'年齡', 區間如下：<BR>
    * <=17, 18~30, 31~40, 41~60, >61, 五個區間
    */
    private func _setWater(doubRs: Double) {
        // 設定比對資料 map
        var listFixVal: [[Double]] = []
        listFixVal.append([54.0, 60.0])
        listFixVal.append([53.5, 59.5])
        listFixVal.append([53.0, 59.0])
        listFixVal.append([52.5, 58.5])
        listFixVal.append([52.0, 58.0])
        
        var mapFixVal: [String: [Double]] = [:]
        for (var i=0; i<5; i++) {
            let code = String(format: "%03d", i + 1)
            mapFixVal[code] = listFixVal[i]
        }
        
        // 比較數值資料, 根據年齡取得對應 map 固定比對數值資料
        var strCode: String = ""
        
        if (usrAge <= 17) {
            strCode = "001"
        }
        else if (usrAge >= 18 && usrAge <= 30) {
            strCode = "002"
        }
        else if (usrAge >= 31 && usrAge <= 40) {
            strCode = "003"
        }
        else if (usrAge >= 41 && usrAge <= 60) {
            strCode = "004"
        }
        else {
            strCode = "005"
        }
        
        // 判斷數值高/低/正常
        var strRsCode: String = "normal"

        if (doubRs < mapFixVal[strCode]![0]) {
            strRsCode = "low";
        }
        else if (doubRs > mapFixVal[strCode]![1]) {
            strRsCode = "high";
        }
        
        // 設定分析文字
        mapResult["stat"] = pubClass.getLang("waterrs_" + strRsCode)
        mapResult["stat_ext"] = nil
        mapResult["explain"] = pubClass.getLang("waterval_" + strCode)
        mapResult["result"] = (strRsCode == "normal") ? "good" : "bad"
    }
    
    /**
    * 基礎代謝 calory 分析文字, 正常代碼 '002'男, '005'女
    * <P>
    * 代入'年齡', 區間如下：<BR>
    * <=8, 9~17, 18~29, 30~49, 50~69, >=70 六個區間
    */
    private func _setCalory(doubRs: Double) {
        var positionVal: Int = 0
        var normalCalory: Int = 0  // 該年齡正常的 Calory 值
        let realCalory = Int(doubRs)
        
        // 年齡範圍 17, 18~29, 30~49, 50~69, 69~120
        var aryFixAge = [ 17, 29, 49, 69, 120 ]
        
        // 設定年齡性別 對應數值資料 map
        var mapCalory: [String: [Int]] = [:]
        mapCalory["M"] = [1610, 1550, 1500, 1350, 1220]
        mapCalory["F"] = [1300, 1210, 1170, 1100, 1010]

        // 比對年齡，取得資料所在 poistion, loop data
        for (var i=0; i<aryFixAge.count; i++) {
            if (usrAge <= aryFixAge[i]) {
                // 取得該年齡正常的 Calory 值
                normalCalory = mapCalory[usrGender]![i]
                positionVal = i
                
                break;
            }
        }
        
        // 判斷數值 正常 / 異常, 測量出的 Calory 應該要 >= 對應年齡的Calory, 表示年輕
        var strRsCode = "bad";
        if (realCalory >= normalCalory) {
            strRsCode = "good"
        }
        
        // 正常/異常文字, 說明文字(顯示對應的年齡,正常範圍值)
        let strPositionVal = String(format: "%03d", positionVal + 1);
        let strExplain = pubClass.getLang("caloryval_" + usrGender + "_" + strPositionVal);
        
        // 設定分析文字
        mapResult["stat"] = pubClass.getLang("caloryrs_" + strRsCode)
        mapResult["stat_ext"] = nil
        mapResult["explain"] = strExplain
        mapResult["result"] = strRsCode
    }
    
    /**
    * 腰臀比 whr 分析文字, 正常代碼 '003'男, '003'女
    * <P>
    * @param jobjItem
    *            : whr 包含: 'waistline', 'hipline' jobj
    */
    private func _setWhr(jobjItem: [String:AnyObject]) {
        // 取得數值文字
        let strWhr = jobjItem["val"] as! String
        let strWaist: String = jobjItem["waistline_val"]! as! String
        let strHip: String = jobjItem["hipline_val"]! as! String
        
        // 設定 '腰圍','臀圍' 數值文字
        let strStat_ext = pubClass.getLang("healthname_waistline") + ":" + strWaist + pubClass.getLang("height_cm") + ", " + pubClass.getLang("healthname_hipline") + ":" + strHip + pubClass.getLang("height_cm")

        
        // 比較數值，取得結果代碼
        var strCode = "001"
        var strRsCode = "bad"
        let dbRate = Double(strWhr)
        let dbWaist = Double(strWaist);
        
        if (usrGender == "M") {
            if (dbWaist > 90) {
                strCode = (dbRate > 0.9) ? "002" : "001"
            }
            else {
                if (dbRate > 0.9) {
                    strCode = "004"
                }
                else {
                    strCode = "003"
                    strRsCode = "good"
                }
            }
        } else {
            if (dbWaist > 80) {
                strCode = (dbRate > 0.85) ? "002" : "001"
            }
            else {
                if (dbRate > 0.85) {
                    strCode = "004"
                }
                else {
                    strCode = "003"
                    strRsCode = "good"
                }
            }
        }
        
        // 設定分析文字
        mapResult["stat"] = pubClass.getLang("waistrs_" + strCode)
        mapResult["stat_ext"] = strStat_ext
        mapResult["explain"] = pubClass.getLang("waistval_003")
        mapResult["result"] = strRsCode
    }
    
    
    
    /**
    * 健康數值計算，本 method 計算以下數值:<BR>
    * 1. BMI : 體重(公斤) / 身高2(公尺2) 2. 腰臀比 : 腰圍 / 臀圍
    * <P>
    * 計算完成的數值，加入原先代入的 jobjItem 再回傳
    * 
    * @param jobjItem
    *            : ex. {"bmi":"0.0","height":"168.0","weight":"0.0"}
    */
    func CalHealthData(strGroup: String, var jobjItem: [String:String])->[String:String] {
        // 計算 BMI
        if (strGroup == "bmi") {
            // 檢查 weigh, height
            if (jobjItem["weigh"] == nil || jobjItem["height"] == nil) {
                return jobjItem
            }
        
            // 計算 BMI
            let dbWeight = Double(jobjItem["weigh"]!)! * 10000
            let dbHeight = Double(jobjItem["height"]!)!
            let dbBMI = Double(dbWeight / (dbHeight * dbHeight))
            jobjItem["bmi"] = String(format: "%.1f", dbBMI)
            
            return jobjItem
        }
        
        // 計算腰臀比
        if (strGroup == "whr") {
            if (jobjItem["waistline"] == nil || jobjItem["hipline"] == nil) {
                return jobjItem
            }
            
            let dbWhr = Double(Double(jobjItem["waistline"]!)! / Double(jobjItem["hipline"]!)!)
            jobjItem["whr"] = String(format: "%.2f", dbWhr)
            
            return jobjItem;
        }
        
        return jobjItem;
    }
    
}