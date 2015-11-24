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
    
    // 本頁面的 textView 根據顯示順序產生一個 array 
    private var aryTxtField: Array<UITextField> = []
    
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
            
            //HTTP 連線取得 news JSON data
            //self.StartHTTPConn()
            
            return
        }
    }
    
    /**
    * 設定頁面內容
    */
    private func initViewField() {
        // set array
        aryTxtField = [txtTEL, txtBirth, txtHeigh, txtWeight, txtCNID, txtWechat, txtQQ, txtEmail, txtZip, txtCity, txtAddr]
        
        // set val
        labID.text = dictMember["memberid"]
        labSdate.text = pubClass.formatDateWithStr(dictMember["sdate"]!, type: 8)
        labName.text = dictMember["membername"]
        
        txtTEL.text = dictMember["tel"]
        txtBirth.text = dictMember["birth"]
        txtHeigh.text = dictMember["height"]
        txtWeight.text = dictMember["weight"]
        txtCNID.text = dictMember["cid_cn"]
        txtWechat.text = dictMember["id_wechat"]
        txtQQ.text = dictMember["id_qq"]
        txtEmail.text = dictMember["email"]
        txtZip.text = dictMember["zip"]
        txtCity.text = dictMember["province"]
        txtAddr.text = dictMember["addr"]
        
        // 手動設定 textView 的 delegate
        txtPsd.delegate = self
        txtRePsd.delegate = self
        
        for txtView in aryTxtField {
            txtView.delegate = self
        }
    }
    
    /**
     * HTTP 連線, 上傳資料儲存
     */
    func StartHTTPSaveConn() {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "health"
        dictParm["act"] = "health_savehealthdata"
        
        // 產生 arg0 參數資料
        var dictArg: Dictionary<String, String> = [:]
        dictArg["filename"] = pubClass.MemberHeadimgFile(mAppDelegate.V_USRACC)
        dictArg["type"] = "head"
        //dictArg["image"] = self.strImgBase64
        dictArg["mime"] = "png"
        
        // 產生 JSON string
        do {
            let jobjData = try NSJSONSerialization.dataWithJSONObject(dictArg, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSASCIIStringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // HTTP 開始連線
        pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 上傳與儲存完成，本 class 結束
        pubClass.popIsee(Msg: pubClass.getLang("pictupdatecomplete"))
        self.dismissViewControllerAnimated(true, completion: nil)
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
        let currIndex = aryTxtField.indexOf(textField)!
        
        if (currIndex == (aryTxtField.count - 1)) {
            textField.resignFirstResponder()
            return true
        }
        
        aryTxtField[currIndex + 1].becomeFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}