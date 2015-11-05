//
// 療程選擇 TableView
//

import UIKit
import Foundation

/**
 * 療程選擇 (已購買) class, 由 ReservationAdd 轉入
 */
class CourseSelCust: UIViewController {
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    /**
     * 前一個頁面傳入的資料(療程資料) 格式如下<BR>
     * ary[0=> [String:String], ....]
     */
    var aryCourseData: Array<Dictionary<String, AnyObject>>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    override func viewDidAppear(animated: Bool) {
        // 初始 TableView Cell 自動調整高度
        tableList.rowHeight = UITableViewAutomaticDimension
        tableList.estimatedRowHeight = 200.0
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableList.reloadData()
        })
        
        return
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
        return aryCourseData.count
    }
    
    /**
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryCourseData.count < 1) {
            return nil
        }
        
        // 取得 Cell View
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseCustSel", forIndexPath: indexPath) as! CourseSelCustCell
        
        // 取得目前指定 Item 的 array data
        let ditItem = aryCourseData[indexPath.row]
        
        mCell.labTitle.text = ditItem["pdname"] as? String
        mCell.labContent.text = ditItem["pdid"] as? String
        mCell.labSdate.text = pubClass.formatDateWIthStr(ditItem["sdate"] as! String, type: 8)
        mCell.labEddDate.text = pubClass.formatDateWIthStr(ditItem["end_date"] as! String, type: 8)
        mCell.labSugst.text = ditItem["card_msg"] as? String
        mCell.labUseTimes.text = ditItem["usecount"] as? String
        mCell.labCardType.text = self.getTypeMsg(ditItem)
        
        return mCell
    }
    
    /**
    * 取得療程卡資料文字
    */
    func getTypeMsg(ditItem: Dictionary<String, AnyObject>)->String {
        let strType = ditItem["cardtype"] as! String
        let strTimes = ditItem["card_times"] as! String
        
        // 包月文字, 'cardtype' == "M",  card_times = "2",  包月2個月
        if (strType == "M") {
            return "包月: \(strTimes)個月"
        }
        
        // 包次文字, 'cardtype' == "T",  card_times = "10", 包次10次
        return "包次: \(strTimes)次"
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