//
// 療程主頁面，使用 containerView, 根據不同 class 帶入對應的 ViewControler
//

import UIKit
import Foundation

/**
 * 療程主頁面
 */
class ReservationMain: UIViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var vavyBar: UINavigationItem!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    private var isDataSourceReady = false
    
    // 目前選擇的 'Class' 
    var vcAdd = UIViewController()
    private var strClass = "ReservationAdd"
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        vcAdd = self.storyboard!.instantiateViewControllerWithIdentifier("ReservationAdd")

        viewContainer.addSubview(vcAdd.view)
        self.addChildViewController(vcAdd)
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // HTTP 連線取得本頁面需要的資料
            //self.StartHTTPConn()
            
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
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}