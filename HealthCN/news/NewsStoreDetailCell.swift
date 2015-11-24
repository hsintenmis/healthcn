//
//  Cell @IBOutlet
//

import Foundation
import UIKit

/**
 * 店家新訊, 點取選擇的Item, 以 TableView 顯示的詳細資料
 */
class NewsStoreDetailCell: UITableViewCell {
    
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labContent: UILabel!
    @IBOutlet weak var imgPict: UIImageView!
}