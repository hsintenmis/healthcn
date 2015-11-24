//
// ViewControler 資料輸入 + WebView
//

import UIKit
import Foundation

/**
 * 健康數值資料輸入，Item 欄位變動
 */
class HealthItemEdit: UIViewController {
    @IBOutlet weak var navyTopBar: UINavigationItem!
    @IBOutlet weak var webHealth: UIWebView!
    
    @IBOutlet weak var labSdate: UILabel!
    
    @IBOutlet var colLabName: [UILabel]!
    @IBOutlet var colLabUnit: [UILabel]!

    @IBOutlet var txtVal: [UITextField]!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
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
     * btn '儲存' 點取
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
