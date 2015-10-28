//
// 健康管理行事曆
//

import UIKit
import Foundation

/**
 * 以月曆型態顯示會員的健康檢測數值資料
 */
class HealthCalendar: UIViewController {
    @IBOutlet weak var viewCalendar: UICollectionView!
    @IBOutlet weak var labMM: UILabel!
    @IBOutlet weak var labYY: UILabel!

    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 本 class 需要使用的 json data
    private var dictMMData: [String: [String:String]] = [:]  // jobj data, ex. 'D_20151031'
    private var dictMember: [String: String] = [:]  // 會員資料
    private var today: String = ""
    
    // calendar 相關
    private let firstYYMM = "201503", lastYYMM = "202512"  // 本月曆的起始 YYMM
    private var aryAllBlock: [[[String:String]]] = []  // 月曆全部的 'block' 資料
    private var dictCurrDate: [String: String] = [:]  // 日期相關按鍵點取後，設定的YY MM DD
    
    // CollectionView Cell 的 'Block' dict 資料 class
    private var mHealthDictData = HealthDictData()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        mHealthDictData.cusInit(mVCtrl)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // HTTP 連線取得本頁面需要的資料
            self.StartHTTPConn()
            
            return
        }
    }
    
    /**
     * HTTP 連線取得 news JSON data
     */
    func StartHTTPConn() {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "health"
        dictParm["act"] = "health_getdatamember"
        
        // HTTP 開始連線
        pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 解析正確的 http 回傳結果，設定本 class JSON 資料
        let dictRespon = dictRS["data"] as! Dictionary<String, AnyObject>
        let dictContent = dictRespon["content"] as! Dictionary<String, AnyObject>
        
        if (dictContent["member"]?.count > 0) {
            self.dictMember = dictContent["member"]! as! [String : String]
        }
        
        if (dictContent["data"]?.count > 0) {
            self.dictMMData = dictContent["data"] as! [String: [String:String]]
        }
        
        // 設定今天日期相關參數
        today = dictContent["today"] as! String
        dictCurrDate["YY"] = pubClass.subStr(today, strFrom: 0, strEnd: 4)
        dictCurrDate["MM"] = pubClass.subStr(today, strFrom: 4, strEnd: 6)
        dictCurrDate["DD"] = pubClass.subStr(today, strFrom: 6, strEnd: 8)
        
        // 初始 Calendar, 重新 reload collectionView
        mHealthDictData.setDataSource(dictMMData)
        self.initCalendarParm()
    }
    
    /**
    * 初始 NSCalendar, NSDate 相關參數<BR>
    */
    func initCalendarParm() {
        aryAllBlock = mHealthDictData.getAllData(dictCurrDate)
        
         // collectionView Reload
        dispatch_async(dispatch_get_main_queue(), {
            self.labMM.text = self.dictCurrDate["MM"]! + "月"
            self.labYY.text = self.dictCurrDate["YY"]!
            self.viewCalendar.reloadData()
        })
    }
    
    /**
     * CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 6
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

        if (aryAllBlock.count < 1) {
            return cell
        }
        
        let dictBlock: [String:String] = aryAllBlock[indexPath.section][indexPath.row] 
        cell.labDate.text = dictBlock["txt_day"]

        // 樣式/外觀/顏色
        cell.labDate.layer.borderWidth = 2
        cell.labDate.layer.cornerRadius = 5
        cell.labDate.layer.borderColor = (pubClass.ColorHEX(dictBlock["color"]!)).CGColor

        return cell
    }
    
    /**
     * CollectionView, Cell 長寬
     */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.size.width/7), height: 40);
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    * 前月 Btn 點取
    */
    @IBAction func actMMPre(sender: UIButton) {
        var YY: Int = Int(dictCurrDate["YY"]!)!
        var MM: Int = Int(dictCurrDate["MM"]!)!
        
        if (firstYYMM == (dictCurrDate["YY"]! + dictCurrDate["MM"]!)) {
            return
        }
        
        MM--;
        if (MM < 1) {
            MM = 12; YY--;
        }
        
        dictCurrDate["YY"] = String(YY)
        dictCurrDate["MM"] = String(format:"%02d", MM)
        dictCurrDate["DD"] = "01"
        
        self.initCalendarParm()
    }
    
    /**
     * 次月 Btn 點取
     */
    @IBAction func actMMNext(sender: UIButton) {
        var YY: Int = Int(dictCurrDate["YY"]!)!
        var MM: Int = Int(dictCurrDate["MM"]!)!
        
        if (lastYYMM == (dictCurrDate["YY"]! + dictCurrDate["MM"]!)) {
            return
        }
        
        MM++;
        if (MM > 12) {
            MM = 1; YY++;
        }
        
        dictCurrDate["YY"] = String(YY)
        dictCurrDate["MM"] = String(format:"%02d", MM)
        dictCurrDate["DD"] = "01"
        
        self.initCalendarParm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}