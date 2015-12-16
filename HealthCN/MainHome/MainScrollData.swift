//
// MainCategory 內的 ScrollView VC<BR>
// 本 class顯示: 會員資料, 今日健康資料/今日提醒, 各頁面跳轉
//

import UIKit
import Foundation

/**
 * ScrollView 內的 VC, 本 class顯示: 會員資料<BR>
 * 今日健康資料/今日提醒, 各頁面跳轉
 */
class MainScrollData: UIViewController {
    
    @IBOutlet weak var labMemberName: UILabel!
    @IBOutlet weak var labStoreName: UILabel!
    @IBOutlet weak var labStoreTel: UILabel!
    
    @IBOutlet weak var textTodayInfo: UITextView!
    @IBOutlet weak var colviewHealth: UICollectionView!
    @IBOutlet var btnGroup: [UIButton]! // 跳轉的 UIButton array
    
    @IBOutlet weak var viewPictBG: UIView! // 大頭照 白色背景
    @IBOutlet weak var imgUser: UIImageView!  // 大頭照
    @IBOutlet weak var btnPict: UIButton! // 更改照片
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    let mImageClass = ImageClass()
    private var isFirstEnter = true // child close, 返回本class辨識標記
    
    // 本 class 需要使用的 json data
    var dictAllData: Dictionary<String, AnyObject>!
    var aryHealth: [[String:String]] = []
    private var dictMember: Dictionary<String, AnyObject> = [:]
    
    // 跳轉其他 class 的 UIButton
    // Dictionary 的 key 要在 storyboard 設定 restorationIdentifier
    var dictBtn = Dictionary<String, UIButton>()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 註冊一個 NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notifyReloadMainScrollData", name:"ReloadMainScrollData", object: nil)
        
        // 重新整理 btnGroup 為 Dictionary
        for btnItem: UIButton in btnGroup {
            dictBtn[btnItem.restorationIdentifier!] = btnItem
        }
        
        // 設定相關 UI text 欄位
        //self.self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (isFirstEnter) {
            isFirstEnter = false
            
            dispatch_async(dispatch_get_main_queue(), {
                self.initViewField()
            })
            
            // HTTP 連線取得本頁面需要的資料
            self.StartHTTPConn()
            
            return
        }
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
     * HTTP 連線取得本頁面需要的資料
     */
    private func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_homepage"
        dictParm["arg0"] = pubClass.MemberHeadimgFile(mAppDelegate.V_USRACC)
        
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
            return
        }
        
        // 解析正確的 http 回傳結果，傳遞 JSONdata, 設定 'MainScrollData' view 資料
        dictAllData = dictRS["data"] as! Dictionary<String, AnyObject>
        
        // 設定相關 UI text 欄位
        dispatch_async(dispatch_get_main_queue(), {
            self.resetViewField()
        })
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    private func resetViewField() {
        let dictContent = dictAllData["content"]!
        
        // 會員資料區塊
        dictMember = dictContent["member"] as! Dictionary<String, AnyObject>
        
        self.labMemberName.text = self.dictMember["usrname"] as? String
        self.labStoreName.text = self.dictMember["store_name"] as? String
        self.labStoreTel.text = self.dictMember["up_tel"] as? String
            
        // CollectionView, 健康資料重新 reload
        self.aryHealth = dictContent["health"] as! [[String:String]]
        
        dispatch_async(dispatch_get_main_queue(), {
            self.colviewHealth.reloadData()
        })
        
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
        
        dispatch_async(dispatch_get_main_queue(), {
            self.textTodayInfo.text = strTodayInfo
        })
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
        
        // 藍芽設備檢測 List segue, 設定會員資料 param
        if segue.identifier == "BTDeviceMain"{
            let cvChild = segue.destinationViewController as! BTDeviceMain
            cvChild.dictMember = dictMember as! Dictionary<String, String>
            
            return
        }
        
        return
    }
    
    /**
    * CollectionView, 設定 Sections
    */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
    * CollectionView, 設定 資料總數
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if aryHealth.count > 0 {
            return aryHealth.count
        }
        
        return 0
    }
    
    /**
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
     * Button 點取時執行程序
     */
    @IBAction func actBtnClick(sender: UIButton) {
        // 取得點取 Button 的 resoration ID
        //self.performSegueWithIdentifier(sender.restorationIdentifier!, sender: nil)
        
        // 設定 btn 背景, 放開時
        self.changeBtnBackgroung(sender, strMode: "up")
    }
    
    /**
    * Button '按下'時執行程序
    */
    @IBAction func actBtnDown(sender: UIButton) {
        // 設定 btn 背景, 按下時
        self.changeBtnBackgroung(sender, strMode: "down")
    }
    
    /**
     * Button 點取與放開時的背景顏色
     * @param strMode : ex. "up", "down"
     */
    private func changeBtnBackgroung(sender: UIButton, strMode: String) {
        let strKey: String = sender.restorationIdentifier!
        let btnCurr = self.dictBtn[strKey]!

        if (strMode == "up") {
            dispatch_async(dispatch_get_main_queue(), {
                btnCurr.backgroundColor = self.pubClass.ColorHEX("#FFFFFF")
            })
        } else {
            btnCurr.backgroundColor = self.pubClass.ColorHEX("#E0E0E0")
        }

    }
    
    /**
     * NSNotificationCenter, 必須先在 ViewLoad declare
     * child class 可以調用此 method
     */
    func notifyReloadMainScrollData() {
        // HTTP 連線取得本頁面需要的資料
        self.StartHTTPConn()
    }

}