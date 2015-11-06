//
// 預約紀錄
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
            aryAllData = jaryData
        }
        else {
            pubClass.popIsee(Msg: pubClass.getLang("nodata"))
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }

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
        
        // 取得目前指定 Item 的 array data
        let ditItem = aryAllData[indexPath.row]
        
        mCell.labYYMM.text = ditItem["yymm"] as? String
        mCell.labDD.text = ditItem["dd"] as? String
        mCell.labCourse.text = ditItem["pdname"] as? String
        
        return mCell
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}