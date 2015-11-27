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
    
    // 固定參數，體重計需要的欄位 array data
    private let aryTestingField: Array<String> = ["bmi", "fat", "water", "calory",
        "bone", "muscle", "vfat"]
    private let aryTestingVal: Array<String> = ["0.0", "0.0", "0.0", "0", "0.0", "0.0","0.0" ]
    private var aryAllData: Array<Dictionary<String, String>> = []
    
    // 體重計需要傳送的固定參數，身高/年齡/性別
    private var dictUserData: Dictionary<String, String> = [:]
    
    // public, 會員資料, parent class 設定
    var dictMember: Dictionary<String, String> = [:]
    
    // BT service class import
    var mBTScaleService = BTScaleService()
    
    // @IBOutlet
    @IBOutlet weak var webChart: UIWebView!
    @IBOutlet weak var labStatMsg: UILabel!
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 健康檢測項目的欄位資料, ex. 名稱，單位，計算方式
    private var mHealthDataInit = HealthDataInit()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mHealthDataInit.custInit(mVCtrl)
        
        // 整理產生本 class 需要的 健康項目 array data
        for strField in aryTestingField {
            aryAllData.append(mHealthDataInit.GetSingleTestData(strField))
        }
        
        dictUserData["gender"] = dictMember["gender"]
        dictUserData["age"] = dictMember["age"]
        dictUserData["height"] = dictMember["height"]
        
        self.setViewChartHTML()
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
        let ditItem = aryAllData[indexPath.row]
        
        // 取得 CellView
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellBTScaleMain")!
        let strItem = ditItem["unit"]! + "     " + ditItem["name"]!
        
        mCell.textLabel?.text = ditItem["val"]!
        mCell.detailTextLabel?.text = strItem
        
        return mCell
    }
    
    /**
     * UITableView, Header 內容
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let strTitle = "Member name\n年齡 35歲, 男性, 身高 173cm"
        
        return strTitle
    }

    /**
     * View 體重計 HTML 顯示<P>
     * 設定 Chart view, 設定到 'viewChart'
     */
    private func setViewChartHTML() {
        // 取得原始 HTML String code
        do {
            let htmlFile = NSBundle.mainBundle().pathForResource(D_HTML_FILENAME, ofType: "html", inDirectory: D_HTML_URL)!
            var strHTML = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
            
            // TODO 開始執行字串取代
 
            
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