//
// TableView List, HTTP 連線取得 fatasource
//

import UIKit
import Foundation

/**
 * 已經預約的記錄列表，提供刪除功能
 */
class ReservationList: UIViewController {
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
        dictParm["page"] = "reservation"
        dictParm["act"] = "reservation_list"
        
        // HTTP 開始連線
        pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 解析正確的 http 回傳結果，設定本 class JSON 資料
        let dictRespon = dictRS["data"] as! Dictionary<String, AnyObject>
        let dictContent = dictRespon["content"] as! Dictionary<String, AnyObject>

        // 取得預約資料
        if let jaryData = dictContent["data"] as? Array<Dictionary<String, AnyObject>> {
            // 小於此日期的資料不顯示, 30天前, 重新產生 'aryAllData'
            let minNSDate = NSDate(timeInterval: -(24*60*60*30), sinceDate: NSDate())
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let minYMD = dateFormatter.stringFromDate(minNSDate)
            
            var strYMD = ""
            for dictItem in jaryData  {
                strYMD = (dictItem["yymm"] as? String)! + (dictItem["dd"] as? String)!
                
                if (Int(strYMD) > Int(minYMD)) {
                   aryAllData.append(dictItem)
                }
            }
            
            if (aryAllData.count < 1) {
                pubClass.popIsee(Msg: pubClass.getLang("nodata"))
                self.dismissViewControllerAnimated(true, completion: nil)
                
                return
            }
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellReservationList", forIndexPath: indexPath) as! ReservationListCell
        
        // 設定 cell field
        let dictItem = aryAllData[indexPath.row]
        let strYMD = (dictItem["yymm"] as? String)! + (dictItem["dd"] as? String)!
        let strYM = (dictItem["yy"] as? String)! + pubClass.getLang("mm_" + (dictItem["mm"] as? String)!)
        
        mCell.labYYMM.text = strYM
        mCell.labDD.text = dictItem["dd"] as? String
        mCell.labCourse.text = dictItem["pdname"] as? String
        mCell.labTime.text = (dictItem["hh"] as? String)! + ":" + (dictItem["min"] as? String)!
        
        // 是否完成/過期
        mCell.labExpire.alpha = 0.0
        
        if (dictItem["issale"] as? String == "Y") {
            mCell.labFinish.alpha = 1.0
        } else {
            mCell.labFinish.alpha = 0.0
            
            // 是否過期
            if (strTodayYMD > strYMD) {
                mCell.labExpire.alpha = 1.0
            }
        }
        
        // 樣式/外觀/顏色
        mCell.viewYMD.layer.cornerRadius = 5
        
        return mCell
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}