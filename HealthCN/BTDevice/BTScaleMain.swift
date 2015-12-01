//
// UIViewController with Container, TableView Cell 使用標準內建格式 'SubTitle'
// 藍芽設備 連線/資料傳輸
//

import UIKit
import Foundation

/**
 * 藍芽體脂計 量測主頁面
 */
class BTScaleMain: UIViewController {
    // !!TODO!! WebHTML, 圖表固定參數
    let D_HTML_FILENAME = "weight"
    let D_HTML_URL = "html/weight"
    let D_BASE_FILENAME = "index"
    let D_BASE_URL = "html"
    
    // TableView 健康項目的 field
    private let aryTestingField: Array<String> = ["weight", "bmi", "fat", "water", "calory", "bone", "muscle", "vfat"]
    
    // 本 class 需要的 健康項目 field 對應的 dict data, 測量項目的 field name, val, unit name ...
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 體重計需要傳送的固定參數，身高/年齡/性別, child class 也會使用
    var dictUserData: Dictionary<String, String> = [:]
    
    // public, 會員資料, parent class 設定,
    var dictMember: Dictionary<String, String> = [:]
    private var isDataSave = false;
    
    //  藍芽體重計 BT service class import
    var mBTScaleService: BTScaleService = BTScaleService()
    
    // @IBOutlet
    @IBOutlet weak var webChart: UIWebView!
    @IBOutlet weak var labStatMsg: UILabel!
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var btnConn: UIButton!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 健康檢測項目的欄位資料 class, ex. 名稱，單位，計算方式
    private var mHealthDataInit = HealthDataInit()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        pubClass.getDevToday()
        
        // 本 class 執行必要餐數檢查(user資料)
        dictUserData["membername"] = dictMember["membername"]
        dictUserData["gender"] = dictMember["gender"]
        dictUserData["height"] = dictMember["height"]
        dictUserData["age"] = dictMember["age"]
        
        // 整理產生本 class 需要的 健康項目 array data
        mHealthDataInit.custInit(mVCtrl)
        for strField in aryTestingField {
            dictAllData[strField] = mHealthDataInit.GetSingleTestData(strField)
        }
        
        // 初始與設定 '體重計' BT service
        mBTScaleService.setParentVC(self)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            // 樣式/外觀/顏色
            self.btnConn.layer.cornerRadius = 5
        })
        
        self.setViewChartHTML("0")
    }
    
    /**
     * UITableView, 'section' 回傳指定的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView!)->Int {
        return 1
    }
    
    /**
     * UITableView<BR>
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     * 可根據 'section' 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return aryTestingField.count
    }
    
    /**
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        // 取得 Item data source
        let strField = aryTestingField[indexPath.row]
        let ditItem = dictAllData[strField] as! Dictionary<String, String>

        // 取得 CellView
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellBTScaleMain")!
        var strItem = ditItem["name"]!
        if (ditItem["unit"]?.characters.count > 0)  {
            strItem += "  ( " + ditItem["unit"]! + " )"
        }
        
        mCell.textLabel?.text = ditItem["val"]!
        mCell.detailTextLabel?.text = strItem
        
        return mCell
    }
    
    /**
     * UITableView, Header 內容
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var strTitle = dictUserData["membername"]! + ", "
        strTitle += pubClass.getLang("gender_" + dictUserData["gender"]!) + ", "
        strTitle += pubClass.getLang("age") + ":" + dictUserData["age"]! + ", "
        strTitle += pubClass.getLang("healthname_height") + ":" + dictUserData["height"]! +  pubClass.getLang("height_cm")
        
        return strTitle
    }

    /**
     * View 體重計 HTML 顯示<P>
     * 設定 Chart view, 設定到 'viewChart'
     */
    private func setViewChartHTML(strWeight: String = "0") {
        // 取得原始 HTML String code
        do {
            let htmlFile = NSBundle.mainBundle().pathForResource(D_HTML_FILENAME, ofType: "html", inDirectory: D_HTML_URL)!
            var strHTML = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
            
            // TODO 開始執行字串取代
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_HEIGHT", withString: "280px");
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_WIDTH", withString: "100%");
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_VAL", withString: strWeight);
            
            // 以 HTML code 產生新的 WebView
            let baseFile = NSBundle.mainBundle().pathForResource(D_BASE_FILENAME, ofType: "html", inDirectory: D_BASE_URL)!
            let baseUrl = NSURL(fileURLWithPath: baseFile)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.webChart.loadHTMLString(strHTML as String, baseURL: baseUrl)
            })
            
        } catch {
            // 資料錯誤
            //print("err")
            return
        }
    }
    
    /**
    * public, 本頁面 體重HTML view, TableView 健康數值 重新整理
    * 體重計回傳資料後，需重設資料
    */
    func reloadPage(dictTestingVal: Dictionary<String, String>!) {
        self.setViewChartHTML(dictTestingVal["weight"]!)
        
        // loop data
        for strField in aryTestingField {
            var dictNewData = dictAllData[strField] as! Dictionary<String, String>
            dictNewData["val"] = dictTestingVal[strField]
            dictAllData[strField] = dictNewData
        }
        
        tableList.reloadData()
    }
    
    /**
    * public, 藍芽設備訊息更新
    */
    func notifyBTStat(strMsg: String!) {
       labStatMsg.text = pubClass.getLang(strMsg)
    }
    
    /**
     * btn act, 儲存資料
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        // 檢查是否有資料， 'weight' 數值判別
        let strWeight = dictAllData["weight"]!["val"] as! String
        
        if ( Float(strWeight) < 1.0 ) {
            pubClass.popIsee(Msg: pubClass.getLang("BT_MSG_testingnoval"))
            return
        }
        
        // 整理要上傳的數值資料, 產生 _REQUEST dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        dictArg0["sdate"] = pubClass.subStr(pubClass.getDevToday(), strFrom: 0, strEnd: 8)
        dictArg0["age"] = dictMember["age"]
        dictArg0["gender"] = dictMember["gender"]
        
        // loop 以量測回傳的 val
        var dictItemNew: Dictionary<String, String> = [:]
        dictItemNew["height"] = dictMember["height"]
        
        for strField in aryTestingField {
            dictItemNew[strField] = dictAllData[strField]!["val"] as? String
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
        pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        pubClass.closePopLoading()
        
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
        mBTScaleService.BTConnStart()
    }
    
    /**
     * btn act, 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        mBTScaleService.BTDisconn()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}