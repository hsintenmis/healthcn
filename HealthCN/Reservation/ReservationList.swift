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
    @IBOutlet var gestLongPress: UILongPressGestureRecognizer!
    
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
        
        // Gesture 設定，long press
        gestLongPress.delaysTouchesBegan = true
        tableList.addGestureRecognizer(gestLongPress)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // HTTP 連線取得本頁面需要的資料
            self.StartHTTPConn()
            
            return
        }
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
        aryAllData = []  // 重新初始
        
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
        mCell.labWeek.text = pubClass.getLang("weeklong_" + (dictItem["week"] as? String)!)

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

    /**
    * act, LongPressGesture, 長按 'Cell' 執行刪除程序
    */
    @IBAction func actCellLongPress(sender: UILongPressGestureRecognizer) {
        if (sender.state != UIGestureRecognizerState.Began){
            return
        }
        
        // 取得選取的 'indexPath', 彈出刪除確認視窗
        if let indexPath: NSIndexPath = self.tableList.indexPathForRowAtPoint(sender.locationInView(self.tableList)) {
            self.tableList.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            
            // 標記為 '已完成' 不能刪除
            if (self.aryAllData[indexPath.row]["issale"] as! String == "Y") {
                return
            }
            
            popConfirm(indexPath.row);
        }
    }
    
    /**
     * 彈出視窗，button 'Yes' 'No', 確認是否刪除資料
     * @param positionItem : TableView cell position
     */
    func popConfirm(positionItem: Int) {
        let mAlert = UIAlertController(title: pubClass.getLang("sysprompt"), message: pubClass.getLang("reservation_confirmdel"), preferredStyle:UIAlertControllerStyle.Alert)
        
        // btn 'Yes', 執行刪除資料程序
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("confirm_yes"), style:UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) in
            
            // 取得選取'預約療程'資料的 'id', ex. 'C0000481', 執行 HTTP 連線資料上傳
            self.StartHTTPConnSave(self.aryAllData[positionItem]["id"] as! String)
        }))
        
        // btn ' No', 取消，關閉 popWindow
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("confirm_no"), style:UIAlertActionStyle.Cancel, handler:nil ))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
     * HTTP 連線, 由本 class 傳送資料至 server 取得儲存結果
     */
    private func StartHTTPConnSave(strArg0: String!) {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "reservation"
        dictParm["act"] = "reservation_del"
        dictParm["arg0"] = strArg0
        
        // HTTP 開始連線
        pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        pubClass.closePopLoading()
        
        // 回傳失敗
        if (dictRS["result"] as! Bool != true) {
            self.popResponResult(Msg: pubClass.getLang("err_trylatermsg"))
        }
        else {
            self.popResponResult(Msg: pubClass.getLang("reservation_delcompleted"))
        }
    }
    
    /**
     * [我知道了] 彈出視窗,
     */
    func popResponResult(Msg strMsg: String!) {
        let mAlert = UIAlertController(title: pubClass.getLang("sysprompt"), message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("i_see"), style: UIAlertActionStyle.Default, handler:{ (action: UIAlertAction!) in
            // 頁面重整
            self.StartHTTPConn()
        }))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}