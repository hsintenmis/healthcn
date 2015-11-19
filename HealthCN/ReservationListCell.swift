//
// TableView Cell, 'ReservationList' 內的 Cell
//

import Foundation
import UIKit

/**
* 預約紀錄的 Cell
*/
class ReservationListCell: UITableViewCell {
    @IBOutlet weak var labYYMM: UILabel!
    @IBOutlet weak var labDD: UILabel!
    @IBOutlet weak var labWeek: UILabel!
    @IBOutlet weak var labTime: UILabel!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labExpire: UILabel!
    @IBOutlet weak var labFinish: UILabel!
    
    @IBOutlet weak var viewYMD: UIView!
}