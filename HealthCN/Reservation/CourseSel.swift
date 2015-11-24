//
// TableView List
//

import UIKit
import Foundation

/**
 * 療程選擇 class, 由 ReservationAdd 轉入
 */
class CourseSel: UIViewController {
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // parent VC
    var mVCtrlParent: ReservationAdd!
    
    /**
     * 前一個頁面傳入的資料(療程資料) 格式如下<BR>
     * ary[0=> [String:String], ....]
     */
    var aryCourseData: Array<Dictionary<String, String>>!
    
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
        tableList.estimatedRowHeight = 80.0
        
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseSel", forIndexPath: indexPath) as! CourseSelCell
        
        // 取得目前指定 Item 的 array data
        let ditItem = aryCourseData[indexPath.row]
        
        mCell.labTitle.text = ditItem["pdname"]
        mCell.labContent.text = ditItem["pdid"]
        
        return mCell
    }
    
    /**
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 設定選擇的療程資料, ex. 'pdname', 'pdidid', 'index_id'
        var dictData: [String:String] = [:]
        
        // 取得原來的療程資料，重新設定新的 dict, 本頁面結束
        let ditItem = aryCourseData[indexPath.row]
        
        dictData["pdname"] = ditItem["pdname"]! as String
        dictData["pdid"] = ditItem["pdid"]! as String
        dictData["index_id"] = ""
        
        mVCtrlParent.setSelCourseData(dictData)
        self.dismissViewControllerAnimated(true, completion: nil)
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