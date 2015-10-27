//
// 健康管理行事曆
//

import UIKit
import Foundation

/**
 * 會員訂單 List
 */
class HealthCalendar: UIViewController {
    @IBOutlet weak var viewCalendar: UICollectionView!

    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // calendar 相關
    private var today: String = ""
    
    //let mCalendar = NSCalendar.currentCalendar()
    let mCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)

    // 本 class 需要使用的 json data
    var dictAllData: [[String: AnyObject]] = []
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // HTTP 連線取得本頁面需要的資料
            //self.StartHTTPConn()
            
            // Calendar init
            self.initCalendarParm()
            
            return
        }
    }
    
    /**
    * 回傳格式化後的 日期/時間
    * http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
    */
    func getFormatYMD(mDate: NSDate)->String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter.stringFromDate(mDate)
    }
    
    /**
    * 初始 NSCalendar, NSDate 相關參數<BR>
    */
    func initCalendarParm() {
        let mNSDate = NSDate()
        let components = mCalendar!.components(NSCalendarUnit.Month, fromDate: mNSDate)
        components.year = 2015
        components.month = 10
        
        // Getting the First and Last date of the month
        components.day = 1
        let firstDateOfMonth: NSDate = mCalendar!.dateFromComponents(components)!
        print(getFormatYMD(firstDateOfMonth))
        
        components.month  += 1
        components.day     = 0
        let lastDateOfMonth: NSDate = mCalendar!.dateFromComponents(components)!
        print(getFormatYMD(lastDateOfMonth))
        
        
        
        /*

        // Getting the First and Last date of the month
        components.day = 1
        let firstDateOfMonth: NSDate = calendar.dateFromComponents(components)!
        
        components.month  += 1
        components.day     = 0
        let lastDateOfMonth: NSDate = calendar.dateFromComponents(components)!
        
        var unitFlags = NSCalendarUnit.WeekOfMonthCalendarUnit |
        NSCalendarUnit.WeekdayCalendarUnit     |
        NSCalendarUnit.CalendarUnitDay
        
        let firstDateComponents = calendar.components(unitFlags, fromDate: firstDateOfMonth)
        let lastDateComponents  = calendar.components(unitFlags, fromDate: lastDateOfMonth)
        
        // Sun = 1, Sat = 7
        let firstWeek = firstDateComponents.weekOfMonth
        let lastWeek  = lastDateComponents.weekOfMonth
        
        let numOfDatesToPrepend = firstDateComponents.weekday - 1
        let numOfDatesToAppend  = 7 - lastDateComponents.weekday + (6 - lastDateComponents.weekOfMonth) * 7
        
        let startDate: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: -numOfDatesToPrepend, toDate: firstDateOfMonth, options: nil)!
        let endDate:   NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: numOfDatesToAppend, toDate: lastDateOfMonth, options: nil)!
        
        Array(map(0..<42) {
        calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: $0, toDate: startDate, options: nil)!
        })
        
        "\(components.year)"
        
        
        var dateString = "2014-10-3" // change to your date format
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        var someDate = dateFormatter.dateFromString(dateString)
        println(someDate)

        */
        
    }
    
    /**
     * CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    /**
     * CollectionView, 設定 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    /**
     * CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CellCalendarDate = collectionView.dequeueReusableCellWithReuseIdentifier("cellCalendarDate", forIndexPath: indexPath) as! CellCalendarDate
        
        cell.labDate.text = "31"
        
        return cell
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