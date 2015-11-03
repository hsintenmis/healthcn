//
// Collection View Cell class
//

import Foundation
import UIKit

/**
 * 選擇預約日期的 Cell, 包含在 Collection View, main class 'ReservationAdd'
 */
class SelDateCell: UICollectionViewCell {
    @IBOutlet weak var labMM: UILabel!
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labWeek: UILabel!
}