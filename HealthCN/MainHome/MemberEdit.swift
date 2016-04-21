//
// TableView Statuc, ContainerView 的延伸 view
// HTTP 連線上傳資料儲存
//

import Foundation
import UIKit


/**
 * 會員資料編輯與儲存
 */
class MemberEdit: UITableViewController, UITextFieldDelegate {
    @IBOutlet var tableList: UITableView!
    
    @IBOutlet weak var labID: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labName: UILabel!
    
    @IBOutlet weak var txtPsd: UITextField!
    @IBOutlet weak var txtRePsd: UITextField!
    
    @IBOutlet weak var txtTEL: UITextField!
    @IBOutlet weak var txtBirth: UITextField!
    @IBOutlet weak var txtHeigh: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtCNID: UITextField!
    @IBOutlet weak var txtWechat: UITextField!
    @IBOutlet weak var txtQQ: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtZip: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtAddr: UITextField!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // TableView datasource, 會員資料, 由parent 設定, 本 class 需要使用的資料
    var dictMember: Dictionary<String, String> = [:]
    
    // textView array 與 val 值對應的 array data
    private var aryTxtView: Array<UITextField> = []
    private var aryField: Array<String> = []
    
    // UITextFieldDelegate, keyboard
    private var currentTextField: UITextField?  // 目前選擇的 txtView, keyboard相關
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // 初始與設定 VCview 內的 field
            self.initViewField();
            
            return
        }
    }
    
    /**
    * 設定頁面內容
    */
    private func initViewField() {
        // set array, 注意順序
        aryTxtView = [txtTEL, txtBirth, txtHeigh, txtWeight, txtCNID, txtWechat, txtQQ, txtEmail, txtZip, txtCity, txtAddr]
        aryField = ["tel","birth","height","weight","cid_cn","id_wechat","id_qq","email","zip","province","addr"]
        
        // set val
        labID.text = dictMember["memberid"]
        labSdate.text = pubClass.formatDateWithStr(dictMember["sdate"]!, type: 8)
        labName.text = dictMember["membername"]
        
        for loopi in (0..<aryField.count) {
            aryTxtView[loopi].text = dictMember[aryField[loopi]]
            
            // textView 的 delegate
            aryTxtView[loopi].delegate = self
        }
        
        // 手動設定 textView 的 delegate
        txtPsd.delegate = self
        txtRePsd.delegate = self
    }

    /**
     * UITextFieldDelegate<BR>
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 密碼 txtView
        if textField == txtPsd {
            txtRePsd.becomeFirstResponder()
            return true
        }
        if textField == txtRePsd {
            textField.resignFirstResponder()
            return true
        }
        
        // 其他 txtView
        let currIndex = aryTxtView.indexOf(textField)!
        
        if (currIndex == (aryTxtView.count - 1)) {
            textField.resignFirstResponder()
            return true
        }
        
        aryTxtView[currIndex + 1].becomeFirstResponder()
        
        return true
    }
    
    /**
     * UITextField Delegate
     * 取得並設定目前選擇的 textView
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
    }
    
    /**
     * public class, parent class 調用，執行資料上傳程序
     */
    func startSaveData() {
        // 關閉虛擬鍵盤
        if (currentTextField != nil) {
            currentTextField!.resignFirstResponder()
        }
        
        if (!chkTextViewInputData()) {
            return
        }
        
        // 產生 arg0 _REQUEST dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        dictArg0["psd"] = txtPsd.text
        
        for loopi in (0..<aryField.count) {
            dictArg0[aryField[loopi]] = aryTxtView[loopi].text
        }

        // 產生 JSON string
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_profilesave"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        //print(dictParm)
        
        // HTTP 開始連線
        //pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        //pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 是否有更改密碼
        let strPsd = txtPsd.text ?? ""
        if (strPsd.characters.count > 0) {
            // 設定全域變數
            mAppDelegate.setValue(txtPsd.text, forKey: "V_USRPSD")
        }
        
        // 上傳與儲存完成，顯示完成訊息
        pubClass.popIsee(Msg: pubClass.getLang("datasavecompleted"))
    }

    /**
    * 檢查本頁面 TextView 的輸入資料
    */
    private func chkTextViewInputData() -> Bool {
        var hasErr = true
        
        // 檢查密碼
        let strPsd = txtPsd.text ?? ""
        let strRPsd = txtRePsd .text ?? ""
        
        if (strPsd.characters.count > 0) {
            if (strPsd.characters.count < 5) {
                pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_psd"))
                
                return false
            }
            if (strRPsd != strPsd) {
                pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_rpsd"))
                
                return false
            }
        }
        
        // 檢查必填欄位 "tel"
        let strTel = txtTEL.text ?? ""
        if (strTel.characters.count < 1) {
            pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_tel"))
            
            return false
        }
        
        // 檢查必填欄位 "birth" 生日, ex. 19700131 八碼數字
        let strBirth = txtBirth.text ?? ""
        if (strBirth.characters.count != 8) {
            pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_birth"))
            return false
        }
        if (self.chkCharIsAllNumber(strBirth, hasPoint: false) != true) {
            pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_birth"))
            return false
        }

        // 檢查數值範圍, 年齡 < 100, > 1, YY 1~12, DD 1~31
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Year, fromDate: date)
        let currYY = Int(components.year)
        
        let strYY = pubClass.subStr(strBirth, strFrom: 0, strEnd: 4)
        let strMM = pubClass.subStr(strBirth, strFrom: 4, strEnd: 6)
        let strDD = pubClass.subStr(strBirth, strFrom: 6, strEnd: 8)
        
        hasErr = false
        
        if (currYY - Int(strYY)! > 100) {
            hasErr = true
        }
        else if ( (Int(strMM)! > 12) || (Int(strMM)! < 1) ) {
            hasErr = true
        }
        else if ( (Int(strDD)! > 31) || (Int(strDD)! < 1) ) {
            hasErr = true
        }

        if (hasErr) {
            pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_birth"))
            
            return false
        }
        
        // 檢查必填欄位, "height"
        hasErr = true
        if let doubTmp = Double(txtHeigh.text!) {
            // 檢查數值範圍, 身高 50 ~ 250
            if (doubTmp < 250.0 && doubTmp > 50) {
                hasErr = false
            }
        }
        if (hasErr) {
            pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_height"))
            
            return false
        }
        
        txtHeigh.text = String(format: "%.1f", Double(txtHeigh.text!)!)
        
        // 檢查必填欄位 "weight"
        hasErr = true
        if let doubTmp = Double(txtWeight.text!) {
            // 體重 5 ~ 999
            if (doubTmp < 150 && doubTmp > 10) {
                hasErr = false
            }
        }
        if (hasErr) {
            pubClass.popIsee(Msg: pubClass.getLang("memberedit_err_weight"))
            
            return false
        }
        
        txtWeight.text = String(format: "%.1f", Double(txtWeight.text!)!)
        
        return true
    }
    
    /**
     * 動態檢查 textView 輸入字元數目, TextView 需要設定 delegate
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        switch (textField) {
        case txtHeigh, txtWeight :
            let maxLength = 5
            let currentString: NSString = textField.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            
            return newString.length <= maxLength
        default:
            return true
        }
    }
    
    /**
    * 檢查 String 是否都為'數字'
    * @param withPoint: 是否包含小數點
    */
    func chkCharIsAllNumber(strVal: String!, hasPoint withPoint: Bool ) -> Bool {
        for chr in strVal.characters {
            if (chr > "9" || chr < "0") {
                if (withPoint == false) {
                    return false
                }
                else {
                    if (chr != ".") {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}