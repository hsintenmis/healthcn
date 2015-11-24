//
// ContainerView 的子 Class
//

import UIKit
import Foundation

/**
 *  會員編輯主頁面
 */
class MemberEditContainer: UIViewController {
    
    @IBOutlet weak var containView: UIView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 會員資料, 由parent 設定, 本 class 需要使用的資料
    var dictMember: Dictionary<String, String> = [:]
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {

        })
    }
    
    /**
     * Segue 判別跳轉哪個頁面, 給 container 的 childView 使用
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 跳轉 'MainScrollData' class
        if segue.identifier == "MemberEdit"{
            let cvChild = segue.destinationViewController as! MemberEdit
            cvChild.dictMember = dictMember
        }
        
        return
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