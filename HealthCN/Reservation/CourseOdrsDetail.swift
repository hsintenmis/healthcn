//
// TableView List, datasource 由 parent 設定帶入
//

import UIKit
import Foundation

/**
 * 已購買療程的使用紀錄列表
 */
class CourseOdrsDetail: UIViewController {
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 本 class TableView 需要的資料集, 預約資料
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var strTodayYMD = ""
    let dictColor = ["blue":"000099", "red":"CC0000"]
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 初始 TableView Cell 自動調整高度
        tableList.rowHeight = UITableViewAutomaticDimension
        tableList.estimatedRowHeight = 200.0
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {

    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            
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
        return 1
    }
    
    /**
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        // 取得 Cell View
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseOdrsDetail", forIndexPath: indexPath) as! CourseOdrsDetailCell
        
        // 取得目前指定 Item 的 array data
        let ditItem = dictAllData
        
        mCell.labTitle.text = ditItem["pdname"] as? String
        mCell.labContent.text = ditItem["pdid"] as? String
        mCell.labSdate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: 8)
        mCell.labEddDate.text = pubClass.formatDateWithStr(ditItem["end_date"] as! String, type: 8)
        mCell.labSugst.text = ditItem["card_msg"] as? String
        mCell.labUseTimes.text = ditItem["usecount"] as? String
        mCell.labSugst.text = ditItem["card_msg"] as? String
        mCell.labCardType.text = self.getTypeMsg(ditItem)
        
        return mCell
    }
    
    /**
     * 取得療程卡資料文字
     */
    private func getTypeMsg(ditItem: Dictionary<String, AnyObject>)->String {
        var strMsg = ""
        let strType = ditItem["card_type"] as! String
        let strTimes = ditItem["card_times"] as! String
        
        if (strType == "M") {
            // 包月文字, 'cardtype' == "M",  card_times = "2",  包月2個月
            strMsg = "\(pubClass.getLang("course_odrstype_M")): \(strTimes)\(pubClass.getLang("course_odrstype_M_unit"))"
        }
        else {
            // 包次文字, 'cardtype' == "T",  card_times = "10", 包次10次
            strMsg = "\(pubClass.getLang("course_odrstype_T")): \(strTimes)\(pubClass.getLang("course_odrstype_T_unit"))"
        }
        
        return (strMsg + ", " + pubClass.getLang("course_fee") + ": \(ditItem["price"]!)")
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