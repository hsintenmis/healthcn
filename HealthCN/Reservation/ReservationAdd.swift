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
class ReservationAdd: UITableViewController {
    @IBOutlet weak var labReserDate: UILabel!
    @IBOutlet weak var labReserTime: UILabel!
    @IBOutlet weak var labReserCourse: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var colvSelDate: UICollectionView!
    @IBOutlet weak var colvSelServ: UICollectionView!
    @IBOutlet weak var colvSelTime: UICollectionView!
    
    @IBOutlet weak var labMsgSelDate: UILabel!
    @IBOutlet weak var btnCourseDef: UIButton!
    @IBOutlet weak var btnCourseCust: UIButton!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate

    private var isDataSourceReady = false
    
    // public, parent VC, parent class 設定
    var mVCtrlParent: ReservationMain = ReservationMain()   // 指定為 'ReservationMain'
    
    // CollectionView Cell 背景
    private let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0"]
    
    // Collectuion Cell View 目前選擇的 position, 選擇的療程資料
    private var positionDate = -1
    private var positionServ = 0
    private var positionTime = -1
    private var dictSelCourse: Dictionary<String, String> = [:]
    
    // Collectuion Cell View 目前選擇的 NSIndexPath
    private var indexpathDate: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    private var indexpathServ = NSIndexPath(forRow: 0, inSection: 0)
    private var indexpathTime: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    /*日期/時間/服務區  JSON 資料 */
    // colvView 選擇日期的資料集, ex. 0=>{'ymd'="20151031,..., 'service'=JSONAry "}
    private var dictDataSelDate: Array<Dictionary<String, AnyObject>> = []
    
    // colvView 選擇服務區資料
    private var numsSrvZone = 0  // 服務區總數
    
    // colvView, 選擇時段 ex. 0(第一個服務區)=>{有幾個jobj時段, ex. 'hh'="9"}
    private var aryDataTime: Array<Dictionary<String, AnyObject>> = []  // 目前選擇的'時段'資料集
    
    // 日期相關設定
    private var today: String = ""
    
    // 療程相關資料集, 預設療程/購買的療程
    private var dictCourse_def: Array<Dictionary<String, String>>!
    private var dictCourse_cust: [[String:AnyObject]] = []
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        labMsgSelDate.alpha = 0.0
    }
    
    // View did Appear
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true
            
            // HTTP 連線取得本頁面需要的資料
            self.StartHTTPConn()
            
            // 初始與設定 VCview 內的 field
            self.initViewField();
            
            return
        }
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {   
            // 樣式/外觀/顏色
            self.btnCourseDef.layer.cornerRadius = 5
            self.btnCourseCust.layer.cornerRadius = 5
            self.btnSave.layer.cornerRadius = 5
            
            self.btnCourseDef.layer.borderWidth = 1
            self.btnCourseCust.layer.borderWidth = 1
            self.btnSave.layer.borderWidth = 1
            
            self.btnCourseDef.layer.borderColor = self.pubClass.ColorCGColor("E0E0E0")
            self.btnCourseCust.layer.borderColor = self.pubClass.ColorCGColor("E0E0E0")
            self.btnSave.layer.borderColor = self.pubClass.ColorCGColor("CC0000")
        })
    }
    
    /**
     * HTTP 連線取得 JSON data
     */
    func StartHTTPConn() {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "reservation"
        dictParm["act"] = "reservation_add"
        
        // HTTP 開始連線
        //pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        //pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: dictRS["msg"] as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        // 解析正確的 http 回傳結果，設定本 class JSON 資料
        let dictRespon = dictRS["data"] as! Dictionary<String, AnyObject>
        let dictContent = dictRespon["content"] as! Dictionary<String, AnyObject>
        
        // 預設療程資料集
        dictCourse_def = dictContent["coursedef"] as! Array<Dictionary<String, String>>
        
        // 已購買療程資料集
        if let jaryData = dictContent["coursecust"] as? Array<Dictionary<String, AnyObject>> {
            dictCourse_cust = jaryData
        }

        // 設定今天日期相關參數
        today = dictContent["today"] as! String
        
        // 解析 '選擇日期' 的資料
        dictDataSelDate = dictContent["date"] as! [[String:AnyObject]]
        
        // 取得'服務區'總數
        numsSrvZone = dictDataSelDate[0]["service"]!.count
        
        // 取得預設選擇時段資料集 ex. 0(第一個服務區)=>{有幾個jobj時段, ex. 'hh'="9"}
        let dictServZone = dictDataSelDate[0]["service"] as! Array<AnyObject>
        aryDataTime = dictServZone[0] as! Array<Dictionary<String, AnyObject>>
        //aryDataTime = dictDataSelDate[0]["service"]![0] as! [[String:AnyObject]]
        
        // 重新 reload View
        isDataSourceReady = true
        
        dispatch_async(dispatch_get_main_queue(), {
            self.colvSelDate.reloadData()
            self.colvSelServ.reloadData()
            self.colvSelTime.reloadData()
            
            if (self.dictCourse_cust.count < 1) {
                self.btnCourseCust.layer.backgroundColor = self.pubClass.ColorCGColor(self.dictColor["gray"])
            }
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
            return aryDataTime.count
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
    * 回傳 collectionView CellView, '選擇日期'
    */
    func getCellDate(collectionView: UICollectionView, indexPath: NSIndexPath)->UICollectionViewCell {
        let mCell: SelDateCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellSelDate", forIndexPath: indexPath) as! SelDateCell
        
        let dictItem = dictDataSelDate[indexPath.row]
        let strMM = pubClass.subStr(dictItem["ymd"] as! String, strFrom: 4, strEnd: 6)
        let strDD = pubClass.subStr(dictItem["ymd"] as! String , strFrom: 6, strEnd: 8)
        
        mCell.labMM.text = pubClass.getLang("mm_" + strMM)
        mCell.labDate.text = String(Int(strDD)!)
        
        // 顯示公休
        var strWeek = pubClass.getLang("week_" + (dictItem["week"] as! String))
        if (dictItem["isrest"] as! String == "Y") {
            strWeek += "(休)"
        }
        
        mCell.labWeek.text = strWeek
        
        // 樣式/外觀/顏色
        mCell.layer.borderWidth = 1
        mCell.layer.cornerRadius = 5
        mCell.layer.borderColor = pubClass.ColorCGColor(dictColor["gray"])
        
        // 背景
        if (positionDate == indexPath.row) {
            mCell.layer.backgroundColor = pubClass.ColorCGColor(dictColor["red"])
        } else {
            mCell.layer.backgroundColor = pubClass.ColorCGColor(dictColor["white"])
        }
        
        return mCell
    }
    
    /**
     * 回傳 collectionView CellView,  '選擇服務區'
     */
    func getCellServ(collectionView: UICollectionView, indexPath: NSIndexPath)->UICollectionViewCell {
        let mCell: SelServCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellSelServ", forIndexPath: indexPath) as! SelServCell
        
        mCell.labName.text = pubClass.getLang("servicezone") + String(indexPath.row + 1)
        
        // 樣式/外觀/顏色
        mCell.layer.borderWidth = 1
        mCell.layer.cornerRadius = 5
        mCell.layer.borderColor = pubClass.ColorCGColor(dictColor["gray"])
        
        // 背景
        if (positionServ == indexPath.row) {
            mCell.layer.backgroundColor = pubClass.ColorCGColor(dictColor["red"])
        } else {
            mCell.layer.backgroundColor = pubClass.ColorCGColor(dictColor["white"])
        }
        
        return mCell
    }
    
    /**
     * 回傳 collectionView CellView, '選擇時間'
     */
    func getCellTime(collectionView: UICollectionView, indexPath: NSIndexPath)->UICollectionViewCell {
        let mCell: SelTimeCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellSelTime", forIndexPath: indexPath) as! SelTimeCell
        
        let dictItem = aryDataTime[indexPath.row]
        mCell.labTime.text = String(format: "%02d", dictItem["hh"] as! Int) + ":00"
        
        // 樣式/外觀/顏色
        mCell.layer.borderWidth = 1
        mCell.layer.cornerRadius = 5
        mCell.layer.borderColor = pubClass.ColorCGColor(dictColor["gray"])
        mCell.labStat.text = pubClass.getLang("")
        
        if ((dictItem["isavail"] as! String) == "N") {
            mCell.layer.backgroundColor = pubClass.ColorCGColor(dictColor["silver"])
            mCell.labStat.text = pubClass.getLang("srv_notavail")
        }
        else if (positionTime == indexPath.row) {
            mCell.layer.backgroundColor = pubClass.ColorCGColor(dictColor["red"])
        }
        else {
            mCell.layer.backgroundColor = pubClass.ColorCGColor(dictColor["white"])
        }
        
        return mCell
    }
    
    /**
     * CollectionView, 點取 Cell
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let strIdent = collectionView.restorationIdentifier

        // 點選日期
        if (strIdent == "colvSelDate") {
            
            let dictItem = dictDataSelDate[indexPath.row]
            
            // 檢查是否允許點取(公休)
            if ((dictItem["isrest"] as! String) == "Y") {
                return
            }
            
            positionDate = indexPath.row
            self.resetDataDate()
        }
        else if (strIdent == "colvSelServ") {
            if (positionDate < 0) {
                labMsgSelDate.alpha = 1.0
                return
            }
            
            positionServ = indexPath.row
            self.resetDataServ()
        }
        else if (strIdent == "colvSelTime") {
            if (positionDate < 0) {
                labMsgSelDate.alpha = 1.0
                return
            }
            
            let dictItem = aryDataTime[indexPath.row]
            
            // 檢查是否允許點取
            if ((dictItem["isavail"] as! String) == "N") {
                return
            }
            
            positionTime = indexPath.row
            
            // lab 文字顯示
            labReserTime.text = String(format: "%02d", dictItem["hh"] as! Int) + ":00"
            
            self.resetDataTime()
        }
    }
    
    /**
    * 日期選擇點取，服務區重新顯示
    */
    func resetDataDate() {
        positionServ = 0
        labMsgSelDate.alpha = 0.0
        
        // lab 文字顯示
        let dictItem = dictDataSelDate[positionDate]
        let strLabDate = pubClass.formatDateWithStr(pubClass.subStr(dictItem["ymd"] as! String, strFrom: 0, strEnd: 8), type: 8) + " " + pubClass.getLang("weeklong_" + (dictItem["week"] as! String))
        labReserDate.text = strLabDate
        
        // cell reload
        dispatch_async(dispatch_get_main_queue(), {
            self.colvSelDate.reloadData()
        })
        
        self.resetDataServ()
    }
    
    /**
     * 服務區選擇點取，時段重新顯示
     */
    func resetDataServ() {
        positionTime = -1
        labReserTime.text = ""
        
        // 根據服務區, 取得2對應時段資料集 ex. 0(第一個服務區)=>{有幾個jobj時段, ex. 'hh'="9"}
        
        let dictServZone = dictDataSelDate[positionDate]["service"] as! Array<AnyObject>
        aryDataTime = dictServZone[positionServ] as! Array<Dictionary<String, AnyObject>>
        
        //aryDataTime = dictDataSelDate[positionDate]["service"]![positionServ] as! [[String:AnyObject]]
        
        dispatch_async(dispatch_get_main_queue(), {
            self.colvSelServ.reloadData()
        })
        
        self.resetDataTime()
    }
    
    /**
     * 時段選擇點取
     */
    func resetDataTime() {
        dispatch_async(dispatch_get_main_queue(), {
            self.colvSelTime.reloadData()
        })
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 跳轉預設療程選擇頁面
        if (segue.identifier == "CourseSel") {
            let cvChild = segue.destinationViewController as! CourseSel
            cvChild.mVCtrlParent = self
            cvChild.aryCourseData = dictCourse_def
            
            return
        }
        
        // 跳轉已購買療程頁面
        if (segue.identifier == "CourseSelCust" && self.dictCourse_cust.count > 0) {
            let cvChild = segue.destinationViewController as! CourseSelCust
            cvChild.mVCtrlParent = self
            cvChild.aryCourseData = dictCourse_cust
            
            return
        }
    }

    /**
    * 設定'已選擇療程'資料，通常由 child 'dismissViewControllerAnimated' 執行
    * @param dictData: 選擇的療程資料，key => 'pdname', 'pdid', 'index_id'
    */
    func setSelCourseData(dictData: Dictionary<String, String>?) {
        if (dictData?.count < 1) {
            return
        }
        
        dictSelCourse = dictData!
        
        dispatch_async(dispatch_get_main_queue(), {
            self.labReserCourse.text = dictData!["pdname"]
        })
    }
    
    /**
     * btn action '資料儲存',  資料 HTTP 上傳儲存
     */
    @IBAction func actSave(sender: UIButton) {
        // 檢查資料
        if (positionDate < 0) {
            pubClass.popIsee(Msg: pubClass.getLang("reservationadd_err_date"))
            return
        }
        else if (positionTime < 0) {
            pubClass.popIsee(Msg: pubClass.getLang("reservationadd_err_time"))
            return
        }
        else if (dictSelCourse["pdid"]?.characters.count < 1) {
            pubClass.popIsee(Msg: pubClass.getLang("reservationadd_err_course"))
            return
        }
        
        let dictYMD = dictDataSelDate[positionDate]
        let strYMD = pubClass.subStr(dictYMD["ymd"] as! String, strFrom: 0, strEnd: 8)
        let strHH = String(format: "%02d", aryDataTime[positionTime]["hh"] as! Int)
        
        // 產生 Request dict array, 轉為 JSON String
        var strJSONStr = ""
        var dictArg0: Dictionary<String, String> = [:]
        dictArg0["time"] = strYMD + strHH +  "00"
        dictArg0["odrs_id"] = dictSelCourse["odrs_id"]
        dictArg0["pdid"] = dictSelCourse["pdid"]
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            strJSONStr = jsonString
        } catch {
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        self.StartHTTPConnSave(strJSONStr)
    }
    
    /**
     * HTTP 連線, 由本 class 傳送資料至 server 取得儲存結果
     */
    private func StartHTTPConnSave(strArg0: String!) {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "reservation"
        dictParm["act"] = "reservation_addsave"
        dictParm["arg0"] = strArg0
        
        // HTTP 開始連線
        //pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        //pubClass.closePopLoading()
        
        // 回傳失敗
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(Msg: pubClass.getLang("err_trylatermsg"))
            //self.dismissViewControllerAnimated(true, completion: nil)
            
            return
        }
        
        self.popResponResult(Msg: pubClass.getLang("reservation_addsavecomplete"))
    }
    
    /**
     * [我知道了] 彈出視窗, 新增資料完成後跳轉其他 class
     */
    func popResponResult(Msg strMsg: String!) {
        let mAlert = UIAlertController(title: pubClass.getLang("sysprompt"), message: strMsg, preferredStyle:UIAlertControllerStyle.Alert)
        
        mAlert.addAction(UIAlertAction(title:pubClass.getLang("i_see"), style: UIAlertActionStyle.Default, handler:{ (action: UIAlertAction!) in

            /**
            * 跳轉新的 class, '預約記錄' 頁面
            * NSNotificationCenter, parent class 'ReservationMain'
            */
            
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName("ChangeReserList", object: nil)
            })
        }))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mVCtrl.presentViewController(mAlert, animated: true, completion: nil)
        })
    }
    
    /**
    * act, 點取 '預設療程'
    */
    @IBAction func actCourseSel(sender: UIButton) {
        self.performSegueWithIdentifier("CourseSel", sender: nil)
    }
    
    /**
     * act, 點取 '已購買療程'
     */
    @IBAction func actCourseSelCust(sender: UIButton) {
        if (self.dictCourse_cust.count < 1) {
            return
        }
        
        self.performSegueWithIdentifier("CourseSelCust", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}