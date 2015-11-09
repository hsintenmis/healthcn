//
// ContainerView 的子 Class
//

import UIKit
import Foundation

/**
 * 官網新訊, 點取 Cell 顯示詳細資料
 */
class NewsOffice: UIViewController {
    @IBOutlet weak var tableNews: UITableView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // public, 由parent 設定, 本 class 需要使用的資料
    var aryAllData: Array<Dictionary<String, AnyObject>> = [[:]]
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // TableCell autoheight
        tableNews.estimatedRowHeight = 80.0
        tableNews.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableNews.reloadData()
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
        
        let cell: NewsOfficeCell = tableView.dequeueReusableCellWithIdentifier("cellNewsOffice", forIndexPath: indexPath) as! NewsOfficeCell
        let ditItem = aryAllData[indexPath.row] as! Dictionary<String, String>

        cell.labDate.text = pubClass.formatDateWIthStr(ditItem["sdate"], type: 8)
        cell.labTitle.text = ditItem["title"]
        
        return cell
    }
     
     /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 取得點取 cell 的 index, 產生 JSON data
        let indexPath = self.tableNews.indexPathForSelectedRow!
        let ditItem = aryAllData[indexPath.row] as! Dictionary<String, String>
        let cvChild = segue.destinationViewController as! NewsOfficeDetail
        cvChild.parentData = ditItem
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}