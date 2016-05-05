//
// ContainerVuiew 轉入, Static TableView
//

import UIKit
import Foundation

/**
 * ScrollView 內的 VC, 本 class顯示: 會員資料<BR>
 * 今日健康資料/今日提醒, 各頁面跳轉
 */
class MainScrollData: UITableViewController {
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var labMemberName: UILabel!
    @IBOutlet weak var labStoreName: UILabel!
    @IBOutlet weak var labStoreTel: UILabel!
    @IBOutlet weak var textTodayInfo: UITextView!
    @IBOutlet weak var colviewHealth: UICollectionView!
    @IBOutlet weak var viewPictBG: UIView! // 大頭照 白色背景
    @IBOutlet weak var imgUser: UIImageView!  // 大頭照
    
    @IBOutlet weak var labActTitle: UILabel!
    @IBOutlet weak var labActMsg: UILabel!
    
    // 固定初始參數
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    private var mImageClass: ImageClass!
    
    // public property, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 本 class 需要使用的 json data
    private var dictContent: Dictionary<String, AnyObject> = [:]
    private var aryHealth: Array<Dictionary<String, String>> = []
    private var dictMember: Dictionary<String, AnyObject> = [:]
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        pubClass = PubClass(viewControl: self)
        mImageClass = ImageClass()
        
        // view  field 設定
        self.initViewField()
        
        // 初始 TableView Cell 自動調整高度
        tableList.estimatedRowHeight = 150.0
        tableList.rowHeight = UITableViewAutomaticDimension
        
        let dictActInfo = dictAllData["content"]!["actinfo"] as! Dictionary<String, String>
        labActTitle.text = dictActInfo["title"]
        labActMsg.text = dictActInfo["msg"]
    }
    
    override func viewDidAppear(animated: Bool) {
        // 紀錄本機 TOKENID, APNS推播訊息
        let strToken = mAppDelegate.V_APNSTOKENID
        
        if (strToken.characters.count > 0) {
            //self.startSaveData(mAppDelegate.V_APNSTOKENID)
            
            // 推播使用，手機 Token ID 上傳資料, 執行 http 連線資料上傳程序,
            var dictParm = Dictionary<String, String>()
            dictParm["acc"] = mAppDelegate.V_USRACC
            dictParm["psd"] = mAppDelegate.V_USRPSD
            dictParm["page"] = "memberdata"
            dictParm["act"] = "memberdata_savetoken"
            dictParm["arg0"] = "ios"
            dictParm["arg1"] = strToken
            
            pubClass.startHTTPConn(dictParm, callBack: {(dictRS: Dictionary<String, AnyObject>) -> Void in
                self.getAPNSMsg()
            })
        }
        else {
            getAPNSMsg()
        }
        
        
        // HTTP 連線取得本頁面需要的資料
        //StartHTTPConn()
    }
    
    /**
     * 檢查裝置推播用, 接收到 APNS 訊息
     */
    private func getAPNSMsg() {
        let strAPNSMsg = mAppDelegate.V_APNSALERTMSG
        if (strAPNSMsg.characters.count > 0) {
            self.mAppDelegate.V_APNSALERTMSG = ""
            self.pubClass.popIsee(self, Title: self.pubClass.getLang("APNS_prompt"), Msg: strAPNSMsg, withHandler: {
                
                // HTTP 連線取得本頁面需要的資料
                self.StartHTTPConn()
            })
        }
        else {
            // HTTP 連線取得本頁面需要的資料
            self.StartHTTPConn()
        }
    }
    
    /**
     * public, parent 調用, HTTP 連線取得本頁面需要的資料
     */
    func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_homepage"
        dictParm["arg0"] = pubClass.MemberHeadimgFile(mAppDelegate.V_USRACC)
        
        // HTTP 開始連線
        pubClass.startHTTPConn(dictParm, callBack: {(dictRS: Dictionary<String, AnyObject>) -> Void in
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                //pubClass.popIsee(Msg: dictRS["msg"] as! String)
                
                self.pubClass.popIsee(self, Msg: dictRS["msg"] as! String, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
                
                return
            }
            
            // 取得參數回傳，設定 view field
            let dictRSdata = dictRS["data"] as! Dictionary<String, AnyObject>
            self.dictContent = dictRSdata["content"] as! Dictionary<String, AnyObject>
            self.dictMember = self.dictContent["member"] as! Dictionary<String, AnyObject>
            self.aryHealth = self.dictContent["health"] as! [[String:String]]
            
            self.resetViewField()
        })
    }

    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        self.textTodayInfo.layer.borderWidth = 1
        self.textTodayInfo.layer.cornerRadius = 5
        self.textTodayInfo.layer.borderColor = pubClass.ColorHEX("#E0E0E0").CGColor
        
        // 圖片, View, btn ... 圓角，外框設定
        self.viewPictBG.layer.cornerRadius = 20
        self.viewPictBG.layer.borderWidth = 0
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    private func resetViewField() {
        self.labMemberName.text = self.dictMember["usrname"] as? String
        self.labStoreName.text = self.dictMember["store_name"] as? String
        self.labStoreTel.text = self.dictMember["up_tel"] as? String
        
        // 設定會員圖片, base64String to Image
        if let strEncode = dictContent["imgstr"] as? String {
            if (strEncode.characters.count > 0) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.imgUser.image = self.mImageClass.Base64ToImg(strEncode)
                    self.imgUser.layer.cornerRadius = 20
                })
            }
        }
        
        // 今日提醒 TextView
        var strTodayInfo = ""
        
        if let aryCourse = dictContent["course"] as? Array<Dictionary<String, String>>  {
            for dictCourse in aryCourse {
                strTodayInfo += "[" + pubClass.getLang("todayinfo_course") + "] "
                strTodayInfo += dictCourse["hh"]! + ":" + dictCourse["min"]! + " "
                strTodayInfo += dictCourse["pdname"]! + "\n"
            }
        }
        
        if let aryNews = dictContent["news"] as? Array<Dictionary<String, String>>  {
            for dictNews in aryNews {
                strTodayInfo += "[" + pubClass.getLang("todayinfo_news") + "] "
                strTodayInfo += dictNews["title"]! + "\n"
            }
        }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        let attributes = [NSParagraphStyleAttributeName : style]
        self.textTodayInfo.attributedText = NSAttributedString(string: strTodayInfo, attributes:attributes)
        self.textTodayInfo.textContainerInset = UIEdgeInsetsMake(10,5,5,5);
        
        if (strTodayInfo.characters.count < 1) {
            strTodayInfo = self.pubClass.getLang("nodata")
        }
        
        self.textTodayInfo.text = strTodayInfo
        
        // CollectionView, 健康資料重新 reload
        self.colviewHealth.reloadData()
    }
    
    /**
    * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 會員編輯 segue, 設定會員資料 param
        if segue.identifier == "MemberEditContainer"{
            let cvChild = segue.destinationViewController as! MemberEditContainer
            cvChild.dictMember = dictMember as! Dictionary<String, String>
            
            return
        }
        
        // 藍芽設備檢測 List segue,
        if segue.identifier == "BTDeviceMain"{
            let cvChild = segue.destinationViewController as! BTDeviceMain
            cvChild.dictMember = dictMember as! Dictionary<String, String>
            
            return
        }
        
        // 活動專區 WebView 頁面
        if segue.identifier == "ActWebView"{
            let dictActInfo = dictAllData["content"]!["actinfo"] as! Dictionary<String, String>
            let mVC = segue.destinationViewController as! ActWebView
            mVC.dictData = dictActInfo
            
            return
        }
        
        return
    }
    
    /**
    * #mark: CollectionView Delegate
    * CollectionView, 設定 Sections
    */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
    * #mark: CollectionView Delegate
    * CollectionView, 設定 資料總數
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if aryHealth.count > 0 {
            return aryHealth.count
        }
        return 0
    }
    
    /**
    * #mark: CollectionView Delegate
    * CollectionView, 設定資料 Cell 的内容
    */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CellViewHealth = collectionView.dequeueReusableCellWithReuseIdentifier("cellHealthVal", forIndexPath: indexPath) as! CellViewHealth
        
        let ditItem = aryHealth[indexPath.row] as [String:String]
        cell.labVal.text = ditItem["val"]
        cell.labUnit.text = ditItem["unit"]
        cell.labItem.text = ditItem["name"]
        
        return cell
    }
    
    /**
     * #mark: CollectionView Delegate
     * CollectionView, Cell 點取
     */
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        self.performSegueWithIdentifier("BTDeviceMain", sender: nil)
    }
    
    /*
    * act, 點取 '會員編輯'
    */
    @IBAction func actEditMember(sender: UIButton) {
        self.performSegueWithIdentifier("MemberEditContainer", sender: nil)
    }
    
}