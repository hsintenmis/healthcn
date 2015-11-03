//
// 本 class 包含三個 CollectionView, 日期, 時間, 服務區
//

import UIKit
import Foundation

/**
 * 療程預約 新增頁面
 * HTTP 回傳三個主要項目的資料如下：
 * 1. 'data': 七天內店家可供預約時間的資料
 *
 *
 */
class ReservationAdd: UIViewController {
    
    @IBOutlet weak var colvSelDate: UICollectionView!
    @IBOutlet weak var colvSelServ: UICollectionView!
    @IBOutlet weak var colvSelTime: UICollectionView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    private var isDataSourceReady = false
    
    
    /*日期/時間/服務區  JSON 資料 */
    // colvView 選擇日期的資料集, ex. 0=>{'ymd'="20151031,..., 'service'=JSONAry "}
    private var dictDataSelDate: [[String:AnyObject]] = [[:]]
    
    // colvView 選擇服務區資料
    private var numsSrvZone = 0  // 服務區總數
    private var positionServ = 0  // 目前選擇的服務區 position
    
    // colvView, 選擇時段 ex. 0(第一個服務區)=>{有幾個jobj時段, ex. 'hh'="9"}
    private var dictDataTime: [[String:AnyObject]] = [[:]]  // 目前選擇的'時段'資料集
    
    // 日期相關設定
    private var today: String = ""
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    // View did Appear
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
        dictParm["page"] = "reservation"
        dictParm["act"] = "reservation_add"
        
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
        
        // 設定今天日期相關參數
        today = dictContent["today"] as! String
        
        // 解析 '選擇日期' 的資料
        dictDataSelDate = dictContent["date"] as! [[String:AnyObject]]
        
        // 取得'服務區'總數
        numsSrvZone = dictDataSelDate[0]["service"]!.count
        
        // 取得預設選擇時段資料集 ex. 0(第一個服務區)=>{有幾個jobj時段, ex. 'hh'="9"}
        dictDataTime = dictDataSelDate[0]["service"]![0] as! [[String:AnyObject]]
        
        // 重新 reload View
        isDataSourceReady = true
        
        dispatch_async(dispatch_get_main_queue(), {
            self.colvSelDate.reloadData()
            self.colvSelServ.reloadData()
            self.colvSelTime.reloadData()
        })
        
    }
    
    /**
     * CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * CollectionView, 設定每列 資料數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (!isDataSourceReady) {
            return 0
        }
        
        let strIdent = collectionView.restorationIdentifier
        
        if (strIdent == "colvSelDate") {
            return dictDataSelDate.count
        }
        else if (strIdent == "colvSelTime") {
            return dictDataTime.count
        }
        else if (strIdent == "colvSelServ") {
            return numsSrvZone
        }
        
        return 0
    }
    
    /**
     * CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (!isDataSourceReady) {
            return collectionView.cellForItemAtIndexPath(indexPath)!
        }
        
        let strIdent = collectionView.restorationIdentifier
        
        //  根據 collectionView 對應的 Identifier 取得並回傳對應的 Cell
        if (strIdent == "colvSelDate") {
            return self.getCellDate(collectionView, indexPath: indexPath)
        }
        else if (strIdent == "colvSelServ") {
            return self.getCellServ(collectionView, indexPath: indexPath)
        }
        
        return self.getCellTime(collectionView, indexPath: indexPath)
    }
    
    /**
    * 回傳 collectionView '選擇日期' CellView
    */
    func getCellDate(collectionView: UICollectionView, indexPath: NSIndexPath)->UICollectionViewCell {
        let mCell: SelDateCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellSelDate", forIndexPath: indexPath) as! SelDateCell
        
        let dictItem = dictDataSelDate[indexPath.row]
        let strMM = pubClass.subStr(dictItem["ymd"] as! String, strFrom: 4, strEnd: 6)
        let strDD = pubClass.subStr(dictItem["ymd"] as! String , strFrom: 6, strEnd: 8)
        
        mCell.labMM.text = pubClass.getLang("mm_" + strMM)
        mCell.labDate.text = String(Int(strDD)!)
        mCell.labWeek.text = pubClass.getLang("week_" + (dictItem["week"] as! String))
        
        // 樣式/外觀/顏色
        mCell.layer.borderWidth = 1
        mCell.layer.cornerRadius = 5
        mCell.layer.borderColor = (pubClass.ColorHEX("E0E0E0")).CGColor
        
        return mCell
    }
    
    /**
     * 回傳 collectionView '選擇服務區' CellView
     */
    func getCellServ(collectionView: UICollectionView, indexPath: NSIndexPath)->UICollectionViewCell {
        let mCell: SelServCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellSelServ", forIndexPath: indexPath) as! SelServCell
        
        mCell.labName.text = pubClass.getLang("servicezone") + String(indexPath.row)
        
        // 樣式/外觀/顏色
        mCell.layer.borderWidth = 1
        mCell.layer.cornerRadius = 5
        mCell.layer.borderColor = (pubClass.ColorHEX("E0E0E0")).CGColor
        
        if (indexPath.row == positionServ) {
            mCell.layer.backgroundColor = (pubClass.ColorHEX("FFCCCC")).CGColor
        } else {
            mCell.layer.backgroundColor = (pubClass.ColorHEX("FFFFFF")).CGColor
        }
    
        return mCell
    }
    
    /**
     * 回傳 collectionView '選擇時間' CellView
     */
    func getCellTime(collectionView: UICollectionView, indexPath: NSIndexPath)->UICollectionViewCell {
        let mCell: SelTimeCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellSelTime", forIndexPath: indexPath) as! SelTimeCell
        
        let dictItem = dictDataTime[indexPath.row]
        mCell.labTime.text = String(format: "%02d", dictItem["hh"] as! Int) + ":00"
        
        // 樣式/外觀/顏色
        mCell.layer.borderWidth = 1
        mCell.layer.cornerRadius = 5
        mCell.layer.borderColor = (pubClass.ColorHEX("E0E0E0")).CGColor
        
        if ((dictItem["isavail"] as! String) == "N") {
            mCell.layer.backgroundColor = (pubClass.ColorHEX("F0F0F0")).CGColor
            mCell.labStat.text = pubClass.getLang("srv_notavail")
        } else {
            mCell.layer.backgroundColor = (pubClass.ColorHEX("FFFFFF")).CGColor
            mCell.labStat.text = pubClass.getLang("")
        }
        
        return mCell
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