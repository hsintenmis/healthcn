//
// 會訂單資料 TableView 的 item view
//

import Foundation
import UIKit

class OdrsCell: UITableViewCell {
    
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labCustPrice: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labReturnPriceCust: UILabel!
    
    @IBOutlet weak var strReturnPrice: UILabel!
}