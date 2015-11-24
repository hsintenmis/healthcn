//
// ViewControler 資料輸入 + WebView
//

import UIKit
import Foundation

/**
 * 健康數值資料輸入，Item 欄位變動
 */
class HealthItemEdit: UIViewController, UITextFieldDelegate {
    // WebHTML, 固定參數
    let D_BASE_FILENAME = "index"
    let D_BASE_URL = "html/html_cn"
    
    // @IBOutlet
    @IBOutlet weak var navyTopBar: UINavigationItem!
    @IBOutlet weak var webHealth: UIWebView!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet var colLabName: [UILabel]!
    @IBOutlet var colLabUnit: [UILabel]!
    @IBOutlet var txtVal: [UITextField]!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 全部的檢測資料數值 dict array
    var dictAllData: Dictionary<String, Dictionary<String, String>> = [:]
    
    // 指定的檢測項目 key name, ex. 'bmi', 參考 'HealthDataInit'
    var strItemKey = ""
    
    // 日期資料, parent 設定
    var dictCurrDate: Dictionary<String, String> = [:]
    
    // group key
    private var strGroup = ""
    
    // other class import, 健康項目資料產生整理好的資料 class
    private var mHealthDataInit = HealthDataInit()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定頁面顯示資料
        self.setFieldData()
        self.setHTMLView()
        
        navyTopBar.title = pubClass.getLang("healthgroup_" + strGroup)
        labSdate.text = dictCurrDate["YY"]! + " / " + dictCurrDate["MM"]! + " / " + dictCurrDate["DD"]!
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {

    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
    * 根據檢測項目的 key name, 以 key 'group' 重新產生本 class 需要的資料集
    * 回傳如: ary(dict0, dict1 ...), dict = ('field'=> 'val', ...)
    */
    private func getEditData()->Array<Dictionary<String, String>> {
        // 參數設定, 取得 group key
        var dictRS: Array<Dictionary<String, String>> = []
        strGroup = dictAllData[strItemKey]!["group"]!
        
        // loop data 取得相同 group data
        for strKey in mHealthDataInit.D_HEALTHITEMKEY {
            let dictItem = dictAllData[strKey]!
            if (dictItem["group"] == strGroup) {
                dictRS.append(dictItem)
            }
        }
        
        return dictRS
    }
    
    /**
    * 設定健康數值輸入的：欄位名稱/單位/數值
    */
    private func setFieldData() {
        // 取得資料集
        let aryData = self.getEditData()
        var loopi = 0
        
        // 相關欄位預設 disable
        for (loopi = 0; loopi<3; loopi++) {
            colLabName[loopi].alpha = 0.0
            colLabUnit[loopi].alpha = 0.0
            txtVal[loopi].alpha = 0.0
            txtVal[loopi].enabled = false
        }
        
        // loop data, 設定 @IBOutlet val
        for (loopi = 0; loopi<aryData.count; loopi++) {
            let dictItem = aryData[loopi]
            colLabName[loopi].text = dictItem["name"]
            colLabUnit[loopi].text = dictItem["unit"]
            txtVal[loopi].text = dictItem["val"]
            
            colLabName[loopi].alpha = 1.0
            colLabUnit[loopi].alpha = 1.0
            txtVal[loopi].alpha = 1.0
            txtVal[loopi].enabled = true
            
            // 手動設定 textView Delegate
            txtVal[loopi].delegate = self
        }
    }
    
    /**
    * 顯示 HTML view
    */
    private func setHTMLView() {
        // 取得 HTML base path
        let baseFile = NSBundle.mainBundle().pathForResource(D_BASE_FILENAME, ofType: "html", inDirectory: D_BASE_URL)!
        let baseUrl = NSURL(fileURLWithPath: baseFile)
        
        // 取得指定 HTML 檔案, 若無檔案 return
        let strHTMLFileName = strGroup + "_info"

        if let htmlFile = NSBundle.mainBundle().pathForResource(strHTMLFileName, ofType: "html", inDirectory: D_BASE_URL) {
            do {
                let strHTML = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
                self.webHealth.loadHTMLString(strHTML as String, baseURL: baseUrl)
            } catch {
                // 資料錯誤
                //print("err")
                return
            }
        }
    }
    
    /**
    * 動態檢查 textView 輸入字元數目, TextView 需要設定 delegate
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 5
        let currentString: NSString = textField.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        
        return newString.length <= maxLength
    }
    
    /**
     * btn '儲存' 點取
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
