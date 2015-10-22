//
//  會員訂單 List
//

import UIKit
import Foundation

/**
 * 會員訂單 List
 */
class OdrsList: UIViewController {
    @IBOutlet weak var tableMain: UITableView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 本 class 需要使用的 json data
    var dictAllData: [[String: AnyObject]] = []
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // HTTP 連線取得本頁面需要的資料
            self.StartHTTPConn()
            
            return
        }
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableMain.reloadData()
        })
    }
    
    /**
     * HTTP 連線取得 news JSON data
     */
    func StartHTTPConn() {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_getOdrs"
        
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
        
        // 解析正確的 http 回傳結果，設定本 class News JSON 資料
        let dictRespon = dictRS["data"] as! Dictionary<String, AnyObject>
        let dictContent = dictRespon["content"] as! Dictionary<String, AnyObject>
        
        if dictContent["data"]?.count < 1 {
            pubClass.popIsee(Msg: pubClass.getLang("nodata") )
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        self.dictAllData = dictContent["data"]! as! [[String : AnyObject]]
        self.initViewField()
    }
    
    /**
     * UITableView<BR>
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     * 可根據 'section' 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return dictAllData.count
    }
    
    /**
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (dictAllData.count < 1) {
            return nil
        }
        
        let cell: OdrsCell = tableView.dequeueReusableCellWithIdentifier("cellOdrs", forIndexPath: indexPath) as! OdrsCell
        let ditItem = dictAllData[indexPath.row] as Dictionary<String, AnyObject>
        
        cell.labSdate.text = pubClass.formatDateWIthStr(ditItem["sdate"] as! String, type: 14)
        cell.labId.text = ditItem["id"] as? String
        cell.labPrice.text = ditItem["price"] as? String
        cell.labCustPrice.text = ditItem["custprice"] as? String
        
        let returnPrice = ditItem["returnpricecust"] as? String
        if ( Int(returnPrice!) > 0) {
            cell.labReturnPriceCust.alpha = 1
            cell.strReturnPrice.alpha = 1
            cell.labReturnPriceCust.text = returnPrice
        } else {
            cell.labReturnPriceCust.alpha = 0
            cell.strReturnPrice.alpha = 0
        }
        
        return cell
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 取得點取 cell 的 index, 產生 JSON data
        /*
        let indexPath = self.tableMain.indexPathForSelectedRow!
        let ditItem = dictAllData[indexPath.row] as! Dictionary<String, AnyObject>
        let cvChild = segue.destinationViewController as! MeadDetail
        cvChild.parentData = ditItem
        */
        
        return
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}