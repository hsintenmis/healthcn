//
// 藍芽設備 連線/資料傳輸
//

import UIKit
import Foundation

/**
 * 血壓計 量測主頁面
 */
class BTBPMain: UIViewController {
    
    @IBOutlet weak var labBTStat: UILabel!
    
    @IBOutlet weak var labVal_H: UILabel!
    @IBOutlet weak var labVal_L: UILabel!
    @IBOutlet weak var labVal_beat: UILabel!

    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    //  藍芽體重計 BT service class import
    var mBTBPService: BTBPService = BTBPService()
    
    // 本class 需要的健康項目 dict array
    private let aryTestingField = ["sbp", "dbp", "heartbeat"]
    private var dictTestingData: Dictionary<String, String> = [:]
    
    var dictMember: Dictionary<String, String> = [:]
    private var isDataSave = false;
    
    /**
     * View load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        pubClass.getDevToday()
        
        for strItem in aryTestingField {
            dictTestingData[strItem] = "0"
        }
        
        // 初始與設定 '血壓計' BT service
        mBTBPService.setParentVC(self)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            // 樣式/外觀/顏色
        })
    }
    
    /**
     * public, 藍芽設備訊息更新
     */
    func notifyBTStat(strMsg: String!) {
        labBTStat.text = pubClass.getLang(strMsg)
    }
    
    /**
     * public, 本頁面 健康數值 重新整理
     * 血壓計回傳資料後，需重設/重整資料
     */
    func reloadPage(dictTestingVal: Dictionary<String, String>!) {
        self.labVal_H.text = dictTestingVal["val_H"]
        self.labVal_L.text = dictTestingVal["val_L"]
        self.labVal_beat.text = dictTestingVal["beat"]

        dictTestingData["sbp"] = dictTestingVal["val_H"]
        dictTestingData["dbp"] = dictTestingVal["val_L"]
        dictTestingData["heartbeat"] = dictTestingVal["beat"]
    }
    
    /**
     * btn act, 儲存資料
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        // 檢查是否有資料， 'heartbeat' 數值判別
        let strBeat = dictTestingData["heartbeat"]!
        if ( Int(strBeat) < 1 ) {
            pubClass.popIsee(Msg: pubClass.getLang("BT_MSG_testingnoval"))
            return
        }
        
        // 整理要上傳的數值資料, 產生 _REQUEST dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        dictArg0["sdate"] = pubClass.subStr(pubClass.getDevToday(), strFrom: 0, strEnd: 8)
        dictArg0["age"] = dictMember["age"]
        dictArg0["gender"] = dictMember["gender"]
        
        // loop 已量測回傳的 val
        var dictItemNew: Dictionary<String, String> = [:]
        dictItemNew["height"] = dictMember["height"]
        
        for strField in aryTestingField {
            dictItemNew[strField] = dictTestingData[strField]!
        }
        
        dictArg0["data"] = dictItemNew
        
        // 產生 JSON string
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "health"
        dictParm["act"] = "health_savehealthdata"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // HTTP 開始連線
        //pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        //pubClass.closePopLoading()
        
        // 回傳失敗顯示錯誤訊息
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            
            return
        }
        
        // 上傳與儲存完成
        pubClass.popIsee(Msg: pubClass.getLang("healthvalsavecompleted"))
        isDataSave = true
    }
    
    /**
     * btn 連線, 開始連線藍芽設備
     */
    @IBAction func actBTConn(sender: UIButton) {
        mBTBPService.BTConnStart()
    }
    
    /**
     * btn act, 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        mBTBPService.BTDisconn()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}