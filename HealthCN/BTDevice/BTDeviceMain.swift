//
// UIViewController with Container,
// Container with Static TableView
//

import UIKit
import Foundation

/**
 * 藍芽設備主 View, Container 產生設備 TableList 選單
 */
class BTDeviceMain: UIViewController {
    
    // public, 會員資料, parent class 設定
    var dictMember: Dictionary<String, String> = [:]
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {        
        // 藍芽設備檢測 List segue, 設定會員資料 param
        if segue.identifier == "BTDeviceList"{
            let cvChild = segue.destinationViewController as! BTDeviceList
            cvChild.dictMember = dictMember 
            
            return
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