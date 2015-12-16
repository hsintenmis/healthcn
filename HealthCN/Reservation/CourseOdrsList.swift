//
// TableView List, HTTP 連線取得 fatasource
//

import UIKit
import Foundation

/**
 * 已購買療程的使用紀錄列表
 */
class CourseOdrsList: UIViewController {
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    private var isDataSourceReady = false
    
    // 本 class TableView 需要的資料集, 預約資料
    private var aryAllData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    private var strTodayYMD = ""
    let dictColor = ["blue":"000099", "red":"CC0000"]
    
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
            
            // HTTP 連線取得本頁面需要的資料
            self.StartHTTPConn()
            
            // 初始與設定 VCview 內的 field
            self.initViewField();
            
            return
        }
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * HTTP 連線取得 JSON data
     */
    func StartHTTPConn() {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_getcourseodrs"
        
        // HTTP 開始連線
        //pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        //pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 解析正確的 http 回傳結果，設定本 class JSON 資料
        let dictRespon = dictRS["data"] as! Dictionary<String, AnyObject>
        let dictContent = dictRespon["content"] as! Dictionary<String, AnyObject>
        
        // 取得 JSON 資料
        if let jaryData = dictContent["data"] as? Array<Dictionary<String, AnyObject>> {
            aryAllData = jaryData
        }
        else {
            pubClass.popIsee(Msg: pubClass.getLang("nodata"))
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        strTodayYMD = pubClass.subStr((dictContent["today"] as! String), strFrom: 0, strEnd: 8)
        
        // 設定 tableView
        dispatch_async(dispatch_get_main_queue(), {
            self.tableList.reloadData()
        })
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
        return aryAllData.count
    }
    
    /**
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryAllData.count < 1) {
            return nil
        }
        
        // 取得 Cell View
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseOdrsList", forIndexPath: indexPath) as! CourseOdrsListCell
        
        // 設定 cell field
        let dictItem = aryAllData[indexPath.row]
        let eDateYMD = pubClass.subStr((dictItem["end_date"] as? String)!, strFrom: 0, strEnd: 8)
        
        mCell.labPdName.text = dictItem["pdname"] as? String
        mCell.labUseCount.text = dictItem["usecount"] as? String
        mCell.labSdate.text = pubClass.formatDateWithStr((dictItem["sdate"] as? String)!, type: "8s")
        mCell.labEdate.text = pubClass.formatDateWithStr((dictItem["end_date"] as? String)!, type: "8s")
        
        // 是否過期, 文字顏色改變
        let strColor = (Int(eDateYMD) < Int(strTodayYMD)) ? "red" : "blue"
        mCell.labEdate.textColor = pubClass.ColorHEX(dictColor[strColor])
        
        return mCell
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 取得點取 cell 的 index, 產生 JSON data
        let indexPath = self.tableList.indexPathForSelectedRow!
        let ditItem = aryAllData[indexPath.row] 
        let cvChild = segue.destinationViewController as! CourseOdrsDetail
        cvChild.dictAllData = ditItem
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}