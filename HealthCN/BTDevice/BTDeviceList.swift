//
// TableView Static, ContainerView 的延伸 view
//

import Foundation
import UIKit


/**
 * 藍芽設備 TableView List, 點取  Cell 跳轉對應的 VC
 */
class BTDeviceList: UITableViewController {
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
        // 藍芽體脂計 設備檢測 List segue, 設定會員資料 param
        if segue.identifier == "BTScaleMain"{
            let cvChild = segue.destinationViewController as! BTScaleMain
            cvChild.dictMember = dictMember
            
            return
        }
        
        // 藍芽血壓計
        /*
        if segue.identifier == "BTBPMain"{
            let cvChild = segue.destinationViewController as! BTBPMain
            cvChild.dictMember = dictMember
            
            return
        }
        */

        return
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {

    }
}