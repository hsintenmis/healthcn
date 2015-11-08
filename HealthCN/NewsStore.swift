//
// ConyainerView 的子 Class
//

import UIKit
import Foundation

/**
 * 店家新訊, 點取 Cell 顯示詳細資料
 */
class NewsStore: UIViewController {
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
    
    // View did Appear
    /*
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // 初始與設定 VCview 內的 field
            self.initViewField();
            
            return
        }
    }
    */
    
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
        
        let cell: NewsStoreCell = tableView.dequeueReusableCellWithIdentifier("cellNewsStore", forIndexPath: indexPath) as! NewsStoreCell
        let ditItem = aryAllData[indexPath.row] as! Dictionary<String, String>
        
        cell.labDate.text = pubClass.formatDateWIthStr(ditItem["sdate"], type: 8)
        cell.labTitle.text = ditItem["title"]
        
        return cell
    }
    
    /**
     * UITableView, Cell 點取
     */
     /*
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     // 跳轉至指定的名稱的Segue頁面
     self.performSegueWithIdentifier("NewsDetail", sender: nil)
     }
     */
     
     /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 取得點取 cell 的 index, 產生 JSON data
        let indexPath = self.tableNews.indexPathForSelectedRow!
        let ditItem = aryAllData[indexPath.row] as! Dictionary<String, String>
        let cvChild = segue.destinationViewController as! NewsStoreDetail
        cvChild.parentData = ditItem
        
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