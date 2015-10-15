//
// APP 首次進入頁面
//

import UIKit
import Foundation

/**
 * 本專案首頁，USER登入頁面
 */
class MainLogin: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtAcc: UITextField!
    @IBOutlet weak var txtPsd: UITextField!
    @IBOutlet weak var labVer: UILabel!
    @IBOutlet weak var labSaveAcc: UILabel!
    @IBOutlet weak var switchSave: UISwitch!
    @IBOutlet weak var btnLogin: UIButton!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    var popLoading: UIAlertController! // 彈出視窗 popLoading
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // 虛擬鍵盤相關參數
    private var currentTextField: UITextField?  // 目前選擇的 txtView
    private var isKeyboardShown = false
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        popLoading = pubClass.getPopLoading()
        dictPref = pubClass.getPrefData()
        
        dispatch_async(dispatch_get_main_queue(), {
           self.initViewField()
        })

        // Keyboard show/hide, 宣告此頁面的 VC NSNotificationCenter
        pubClass.setKeyboardNotify()
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        pubClass.setVCBackgroundImg("back002.jpg")
        txtAcc.delegate = self
        txtPsd.delegate = self
    
        txtAcc.text = dictPref["acc"] as? String
        txtPsd.text = dictPref["psd"] as? String
        switchSave.setOn((dictPref["issave"] as! Bool), animated: false)

        txtAcc.placeholder = pubClass.getLang("login_acc")
        txtPsd.placeholder = pubClass.getLang("login_psd")
        labSaveAcc.text = pubClass.getLang("saveaccpsd")
        btnLogin.setTitle(pubClass.getLang("login"), forState: UIControlState.Normal)
        
        labVer.text = pubClass.getLang("version") + ":" +
            (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)
    }
    
    /**
     * user 登入資料送出, HTTP 連線檢查與初始
     */
    func StartHTTPConn() {
        // acc, psd 檢查
        if ((txtAcc.text?.isEmpty) == true || (txtPsd.text?.isEmpty) == true) {
            pubClass.popIsee(Msg: pubClass.getLang("err_accpsd"))
            
            return
        }
        
        currentTextField = nil
        
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = txtAcc.text;
        dictParm["psd"] = txtPsd.text;
        dictParm["page"] = "memberdata";
        dictParm["act"] = "memberdata_login";
        
        var strConnParm: String = "";
        for (strParm, strVal) in dictParm {
            strConnParm += "\(strParm)=\(strVal)&"
        }
        
        // HTTP 開始連線
        mVCtrl.presentViewController(popLoading, animated: false, completion: nil)
        pubClass.startHTTPConn(strConnParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        popLoading.dismissViewControllerAnimated(true, completion: {})

        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            return
        }
        
        // 解析正確的 http 回傳結果，執行後續動作
        self.HttpResponAnaly(dictRS["data"] as! Dictionary<String, AnyObject>)
    }
    
    /**
     * 解析正確的 http 回傳結果，執行後續動作
     */
    func HttpResponAnaly(dictRespon: Dictionary<String, AnyObject>) {
        //print("JSONDictionary! \(dictRespon)")
        
        // 資料存入 'Prefer'
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        
        if (switchSave.on == true) {
            mPref.setObject(txtAcc.text, forKey: "acc")
            mPref.setObject(txtPsd.text, forKey: "psd")
            mPref.setObject(true, forKey: "issave")
        }
        else {
            mPref.setObject("", forKey: "acc")
            mPref.setObject("", forKey: "psd")
            mPref.setObject(false, forKey: "issave")
        }

        mPref.synchronize()
        
        // 設定全域變數
        let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        mAppDelegate.setValue(txtAcc.text, forKey: "V_USRACC")
        mAppDelegate.setValue(txtPsd.text, forKey: "V_USRPSD")
        
        // 跳轉至指定的名稱的Segue頁面, 傳遞參數
        self.performSegueWithIdentifier("MainCategory", sender: dictRespon)
        
        //pubClass.popIsee(Msg: "登入完成")
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MainCategory"{
            let cvChild = segue.destinationViewController as! MainCategory
            cvChild.parentData = sender as! Dictionary<String, AnyObject>
        }
        
        return
    }

    /**
     * 點取 [登入] 按鈕
     */
    @IBAction func actLogin() {
        self.StartHTTPConn();
    }
    
    // ********** 以下為常用固定 function ********** //
    
    /**
     * UITextFieldDelegate<BR>
     * 取得並設定目前選擇的 textView
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
    }
    
    /**
     * UITextFieldDelegate<BR>
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txtAcc {
            txtPsd.becomeFirstResponder();
            
            return true
        }
        
        if textField == txtPsd {
            textField.resignFirstResponder()
            self.StartHTTPConn()
            
            return true
        }
        
        return true
    }
    
    /**
     * 虛擬鍵盤: 將要 [顯示] 時執行相關程序
     */
    func keyboardWillShow(mNotify: NSNotification) {
        if isKeyboardShown || (currentTextField != txtPsd && currentTextField != txtAcc) {
            return
        }
        
        isKeyboardShown = true
        pubClass.KBShowProc(mNotify)
    }
    
    /**
     * 虛擬鍵盤: 將要 [關閉] 時執行相關程序
     */
    func keyboardWillHide(mNotify: NSNotification) {
        isKeyboardShown = false
        pubClass.KBHideProc(mNotify)
    }
    
    /**
     * 虛擬鍵盤: [關閉]
     */
    func keyboardHide(tapG: UITapGestureRecognizer){
        if (isKeyboardShown) {
            currentTextField!.resignFirstResponder()
        }
    }
    
    
    
}

