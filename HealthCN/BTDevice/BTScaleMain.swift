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
    let D_HTML_FILENAME = "weight_demo"
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
    
    //  藍芽體重計 BT service class import
    var mBTScaleService: BTScaleService = BTScaleService()
    
    // @IBOutlet
    @IBOutlet weak var webChart: UIWebView!
    @IBOutlet weak var labStatMsg: UILabel!
    @IBOutlet weak var tableList: UITableView!
    
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
        
        // 整理產生本 class 需要的 健康項目 array data
        for strField in aryTestingField {
            dictAllData[strField] = mHealthDataInit.GetSingleTestData(strField)
        }
        
        dictUserData["membername"] = dictMember["membername"]
        dictUserData["gender"] = dictMember["gender"]
        dictUserData["height"] = dictMember["height"]
        
        // TODO! Server 加入 'age'欄位
        //dictUserData["age"] = dictMember["age"]
        dictUserData["age"] = "45"
        
        self.setViewChartHTML()
        
        // 初始與設定 '體重計' BT service
        mHealthDataInit.custInit(mVCtrl)
        mBTScaleService.setParentVC(self)
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
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_HEIGHT", withString: "360px");
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_WIDTH", withString: "100%");
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_VAL", withString: strWeight);
            
            // 以 HTML code 產生新的 WebView
            let baseFile = NSBundle.mainBundle().pathForResource(D_BASE_FILENAME, ofType: "html", inDirectory: D_BASE_URL)!
            let baseUrl = NSURL(fileURLWithPath: baseFile)
            self.webChart.loadHTMLString(strHTML as String, baseURL: baseUrl)
            
        } catch {
            // 資料錯誤
            //print("err")
            return
        }
    }
    
    /**
    * 本頁面 體重HTML view, TableView 健康數值 重新整理
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
    * btn 連線, 開始連線藍芽設備
    */
    @IBAction func actBTConn(sender: UIButton) {
        mBTScaleService.BTConnStart()
    }
    
    /**
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}