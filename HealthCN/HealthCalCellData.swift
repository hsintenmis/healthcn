//
//  CollectionView 全部 Cell 的 'Block' dicy arydata
//

import UIKit
import Foundation

class HealthCalCellData {
    private var pubClass: PubClass!
    
    // 月曆相關參數設定
    private let aryFixWeek = ["Sun", "Mon","Tue","Wed","Thu","Fri","Sat"]
    private var dictDataSource: [String:[String:String]] = [:]
    private let dictColor = ["white":"FFFFFF", "green":"99CC33", "red":"FF6666"]
    
    let mCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    let mNSDate = NSDate()
    let components: NSDateComponents
    
    /**
    * init
    */
    init() {
        components = mCalendar!.components(NSCalendarUnit.Month, fromDate: mNSDate)
        components.timeZone = NSTimeZone(name: "ASIA/Taipei")
    }
    
    func cusInit(mVC: UIViewController) {
        pubClass = PubClass(viewControl: mVC)
    }
    
    /**
    * 設定本 Class 需要使用的資料, dict key ex. "D_20151031"
    */
    func setDataSource(mData: [String:[String:String]]) {
        dictDataSource = mData
    }
    
    /**
    * 產生全部的 'Block' dicy arydata
    */
    func getAllData(dictCurrDate: [String:String] )->[[[String:String]]] {
        // 初始相關參數
        var aryAllBlock: [[[String:String]]] = []
        let strDictKey = "D_" + dictCurrDate["YY"]! + dictCurrDate["MM"]!
        
        components.year = Int(dictCurrDate["YY"]!)!
        components.month = Int(dictCurrDate["MM"]!)!
        
        // 指定月份的第一天，最後一天，格式為 NSDate
        components.day = 1
        let firstDateOfMonth: NSDate = mCalendar!.dateFromComponents(components)!
        components.month += 1
        components.day = 0
        let lastDateOfMonth: NSDate = mCalendar!.dateFromComponents(components)!
        
        // 取得 [10月01日] 是星期幾, 最後一天是幾號
        let firstWeekName: String = pubClass.subStr(getFormatYMD(firstDateOfMonth), strFrom: 8, strEnd: 11)
        let lastMonthDay: Int = Int(pubClass.subStr(getFormatYMD(lastDateOfMonth), strFrom: 6, strEnd: 8))!
        
        // 產生月曆每個 'Block' 的資料
        var currDay: Int = 1;  // 目前處理 aryAllBlock 的 '日期'
        
        // 月曆 第一個 sect 資料列
        var arySect: [[String:String]] = []
        var isStartSet = false  // 是否開始設定資料 flag
        
        for (var loopi = 0; loopi < 7; loopi++) {
            var dictBlock: [String:String] = [:]
            
            // 設定 block 從第幾個開始有資料
            if (firstWeekName == aryFixWeek[loopi] && !isStartSet) {
                isStartSet = true
            }
            
            if (!isStartSet) {
                dictBlock["txt_day"] = ""
                dictBlock["hasdata"] = "N"
                dictBlock["color"] = dictColor["white"]
                arySect.append(dictBlock)
                
                continue
            }
            
            // 設定 block 判別該日期是否有資料
            if let data = dictDataSource[strDictKey + String(format: "%02d", currDay)] {
                dictBlock = data
                dictBlock["hasdata"] = "Y"
                dictBlock["color"] = dictColor["green"]
            }
            else {
                dictBlock["hasdata"] = "N"
                dictBlock["color"] = dictColor["white"]
            }
            
            dictBlock["txt_day"] = String(currDay)
            currDay += 1
            arySect.append(dictBlock)
        }
        
        aryAllBlock.append(arySect)
        
        // 其他 sect 列設定, 2~6 列
        for (var currSect = 2; currSect <= 6; currSect++) {
            var arySect: [[String:String]] = []
            
            // 指定的 sect 列, 設定「星期幾」的資料
            for (var loopi = 0; loopi < 7; loopi++) {
                var dictBlock: [String:String] = [:]
                
                if (currDay <= lastMonthDay) {                    
                    // 設定 block 判別該日期是否有資料
                    if let data = dictDataSource[strDictKey + String(format: "%02d", currDay)] {
                        dictBlock = data
                        dictBlock["hasdata"] = "Y"
                        dictBlock["color"] = dictColor["green"]
                    }
                    else {
                        dictBlock["hasdata"] = "N"
                        dictBlock["color"] = dictColor["white"]
                    }
                    
                    dictBlock["txt_day"] = String(currDay)
                }
                else {
                    dictBlock["txt_day"] = ""
                    dictBlock["hasdata"] = "N"
                    dictBlock["color"] = dictColor["white"]
                }
                
                arySect.append(dictBlock)
                currDay++
            }
            
            aryAllBlock.append(arySect)
        }
        
        
        return aryAllBlock
    }
    
    /**
     * 回傳格式化後的 日期/時間
     * http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
     *
     * 本 class 需要的格式回傳如: '20151031Wed' (YYYY MM DD Week)
     */
    func getFormatYMD(mDate: NSDate)->String {
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd ccc HH:mm"
        dateFormatter.dateFormat = "yyyyMMddccc"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(mDate)
    }
    
}