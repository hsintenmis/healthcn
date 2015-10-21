//
// 最新消息
//

import UIKit
import Foundation

/**
* 最新消息 class, 店家新訊與官網新訊
*/
class NewsMain: UIViewController {
    @IBOutlet weak var tableNews: UITableView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 本 class 需要使用的 json data
    var dictNewsStore: [[String: AnyObject]] = []
    var dictNewsOffice: [[String: AnyObject]] = []
    var dictCurrNewsData: [[String: AnyObject]] = []  // 目前 news 資料為 'store' or 'office'
    
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
            self.tableNews.reloadData()
            //self.tableNews.rowHeight = UITableViewAutomaticDimension
            //self.tableNews.estimatedRowHeight = 120.0
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
        dictParm["act"] = "memberdata_getnews"
        
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
        
        if dictContent["store"] != nil {
            self.dictNewsStore = dictContent["store"]! as! [[String : AnyObject]]
        }
        
        if (dictContent["office"]?.count > 0) {
            self.dictNewsOffice = dictContent["office"] as! [[String: AnyObject]]
        }
        
        dictCurrNewsData = self.dictNewsStore

        self.initViewField()
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
        return dictCurrNewsData.count
    }
    
    /** 
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (dictCurrNewsData.count < 1) {
            return nil
        }
        
        let cell: NewsCell = tableView.dequeueReusableCellWithIdentifier("cellNews", forIndexPath: indexPath) as! NewsCell
        let ditItem = dictCurrNewsData[indexPath.row] as! Dictionary<String, String>
        
        cell.labDate.text = pubClass.formatDateWIthStr(ditItem["sdate"], type: 8)
        cell.labTitle.text = ditItem["title"]

        return cell
    }
    
    /**
    * UITableView, Cell 點取
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 跳轉至指定的名稱的Segue頁面
        self.performSegueWithIdentifier("NewsDetail", sender: nil)
    }
    
    /**
    * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewsDetail"{
            // 取得點取 cell 的 index, 產生 JSON data
            let indexPath = self.tableNews.indexPathForSelectedRow!
            let ditItem = dictCurrNewsData[indexPath.row] as! Dictionary<String, String>
            let cvChild = segue.destinationViewController as! NewsDetail
            cvChild.parentData = ditItem
            
            return
        }
        
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