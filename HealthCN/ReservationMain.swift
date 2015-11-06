//
// 療程主頁面，使用 containerView, 根據不同 class 帶入對應的 ViewControler
//

import UIKit
import Foundation

/**
 * 療程主頁面, 帶入三個 view with class, 如下：
 *  預約新增：ReserationAdd
 *  療程紀錄：CourseList
 *  預約記錄：ReservationList
 */
class ReservationMain: UIViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var navyTopBar: UINavigationItem!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    private var isDataSourceReady = false
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // viewContainer加入 viewControl, 預設初始為 預約新增 ReserationAdd
        self.setContainerView("ReserAdd")
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
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
    * 設定 viewContainer 內容
    * @param flag : ex. 'ReserAdd', 'CourseList', 'ReserList'
    */
    private func setContainerView(flag: String!) {
        var mSubVC = UIViewController()
        var strTitle = ""
        viewContainer.clearsContextBeforeDrawing = true
        
        if (flag == "ReserAdd") {
            mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("ReservationAdd")
            strTitle = pubClass.getLang("course_reservation_add")
        }
        else if (flag == "CourseList") {
            strTitle = pubClass.getLang("course_uselist")
        }
            
        else if (flag == "ReserList") {
            mSubVC = self.storyboard!.instantiateViewControllerWithIdentifier("ReservationList")
            strTitle = pubClass.getLang("course_reservation_list")
        }
        
        navyTopBar.title = strTitle
        viewContainer.addSubview(mSubVC.view)
        self.addChildViewController(mSubVC)
    }

    /**
    * 點取 預約新增：ReserationAdd
    */
    @IBAction func actReserAdd(sender: UIBarButtonItem) {
        self.setContainerView("ReserAdd")
    }
    
    /**
     * 點取 療程紀錄：CourseList
     */
    @IBAction func actCourseList(sender: UIBarButtonItem) {
    }
    
    /**
     * 預約記錄：ReservationList
     */
    @IBAction func actReserList(sender: UIBarButtonItem) {
        self.setContainerView("ReserList")
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