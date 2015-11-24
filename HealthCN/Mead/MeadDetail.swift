//
// 本 class 使用 webview, 取得 HTML string code
// 帶入 'webView.loadHTMLString'
//

import UIKit
import Foundation

/**
 * 能量檢測詳細內容 class, 圖表顯示
 */
class MeadDetail: UIViewController {
    // !!TODO!! WebHTML, 圖表固定參數
    let D_HTML_FILENAME = "mead01"
    let D_HTML_URL = "html/mead"
    let D_BASE_FILENAME = "index"
    let D_BASE_URL = "html"
    
    // @IBOutlet
    @IBOutlet weak var webChart: UIWebView!
    @IBOutlet weak var viewLoading: UIActivityIndicatorView!
    @IBOutlet weak var labLoading: UILabel!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    // 檢測結果的 val 與  key array
    var aryKey: Array<String> = []
    var aryVal: Array<String> = []
    
    // 高低標與平均值
    var strAvg = "0", strAvgH = "0", strAvgL = "0";
    
    /**
     * 前一個頁面傳入的資料, 參數如下<BR>
     */
    var parentData: Dictionary<String, String>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 解析檢測結果 string 為 string array
        aryKey = parentData["testing_id"]!.componentsSeparatedByString(",")
        aryVal = parentData["testing_val"]!.componentsSeparatedByString(",")

        strAvg = parentData["avg"]!
        strAvgH = parentData["avgH"]!
        strAvgL = parentData["avgL"]!
        
        
        //print(parentData)
        self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
        self.setViewChartHTML()
        //tableDetail.reloadData()
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {

    }
    
    /**
    * View ChartHTML 方式顯示<P>
    * 設定 Chart view, 設定到 'viewChart', '橫向', 數值資料要重新排列順序
    */
    private func setViewChartHTML() {
        var mapVal: Dictionary<String, String> = [:]
        var loopi = 0;
        
        // 取得數組 'aryVal' 最大值作為圖表 Y 軸最大值
        var currMax = 0, newMax = 0;
        for (loopi = 0; loopi < 24; loopi++) {
            newMax = Int(aryVal[loopi])!
            if (newMax > currMax) {
                currMax = newMax;
            }
        }
        //currMax += 10;
        mapVal["D_YAXIS_MAX"] = String(currMax)

        // 檢測的全部數值，前12個為 'H', 後12個為 'F', 解析為 '左右'
        var strD_L_VAL = "", strD_R_VAL = ""
        
        for (loopi = 17; loopi >= 12; loopi--) {
            strD_L_VAL += aryVal[loopi] + ","
        }
        
        for (loopi = 5; loopi >= 0; loopi--) {
            strD_L_VAL += aryVal[loopi];
            
            if (loopi > 0) {
                strD_L_VAL += ","
            }
        }
        mapVal["D_L_VAL"] = strD_L_VAL
        
        for (loopi = 23; loopi >= 18 ; loopi--) {
            strD_R_VAL += aryVal[loopi] + ","
        }
        for (loopi = 11; loopi >= 6; loopi--) {
            strD_R_VAL += aryVal[loopi];
            
            if (loopi > 6) {
                strD_R_VAL += ","
            }
        }
        mapVal["D_R_VAL"] = strD_R_VAL
        
        // 設定平均值, 高低標數值
        mapVal["D_AVG"] = strAvg
        mapVal["D_HI"] = strAvgH
        mapVal["D_LOW"] = strAvgL

        // 設定圖表尺寸
        mapVal["D_CHART_HEIGHT"] = "500px"
        mapVal["D_CHART_WIDTH"] = "420px"
        
        // 圖表相關, 標題/次標題, 帶入會員資料
        let strGender = pubClass.getLang("gender_" + parentData["gender"]!)
        let strAge = parentData["age"]! + pubClass.getLang("agename")
        let strDate = pubClass.getLang("testingdate") + ":" + pubClass.formatDateWithStr(parentData["sdate"], type: 8)
        let strChartSubTitle = strGender + ", " + strAge + ", " + strDate
        
        mapVal["D_CHART_TITLE"] = parentData["membername"]!
        mapVal["D_CHART_SUBTITLE"] = strChartSubTitle
        
        // 取得原始 HTML String code
        do {
            let htmlFile = NSBundle.mainBundle().pathForResource(D_HTML_FILENAME, ofType: "html", inDirectory: D_HTML_URL)!
            var strHTML = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
            
            // 開始執行字串取代
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_HEIGHT", withString: mapVal["D_CHART_HEIGHT"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_WIDTH", withString: mapVal["D_CHART_WIDTH"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_AVG", withString: mapVal["D_AVG"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_HI", withString: mapVal["D_HI"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_LOW", withString: mapVal["D_LOW"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_L_VAL", withString: mapVal["D_L_VAL"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_R_VAL", withString: mapVal["D_R_VAL"]!)
            
            // 取得圖表 Y 軸 MAX, 取得數組最大值
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_YAXIS_MAX", withString: mapVal["D_YAXIS_MAX"]!)
            
            // 設定圖表標題
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_TITLE", withString: mapVal["D_CHART_TITLE"]!)
            
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_SUBTITLE", withString: mapVal["D_CHART_SUBTITLE"]!)
            
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
    
    /** WebView delegate Start */
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        //print("Webview fail with error \(error)");
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType)->Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        labLoading.alpha = 1.0
        viewLoading.alpha = 1.0
        //print("Webview started Loading")
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        labLoading.alpha = 0.0
        viewLoading.alpha = 0.0
        //print("Webview did finish load")
    }
    /** WebView delegate End */
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 取得點取 cell 的 index, 產生 JSON data
        let cvChild = segue.destinationViewController as! MeadDetailTxt
        cvChild.dictMeadData = parentData
        
        return
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
