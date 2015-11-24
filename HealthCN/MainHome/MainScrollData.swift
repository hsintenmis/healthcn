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
    
    @IBOutlet weak var colviewHealth: UICollectionView!
    @IBOutlet weak var viewTodayInfo: UIView!  // 今日提醒資料 View list
    @IBOutlet var btnGroup: [UIButton]! // 跳轉的 UIButton array
    
    @IBOutlet weak var imgUser: UIImageView!  // 大頭照
    @IBOutlet weak var btnPict: UIButton! // 更改照片
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    let mImageClass = ImageClass()
    
    // 本 class 需要使用的 json data
    var parentData: Dictionary<String, AnyObject>!
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
        
        // 設定相關 UI text 欄位
        self.self.initViewField()
        
        // 重新整理 btnGroup 為 Dictionary
        for btnItem: UIButton in btnGroup {
            dictBtn[btnItem.restorationIdentifier!] = btnItem
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        btnPict.reloadInputViews()
    }

    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        viewTodayInfo.layer.borderWidth = 2
        viewTodayInfo.layer.borderColor = pubClass.ColorHEX("#E0E0E0").CGColor
        
        self.imgUser.layer.cornerRadius = 20
    }
    
    /**
    * public, 設定本 class 需要使用的 json data
    */
    internal func setParam(parm: Dictionary<String, AnyObject>) {
        parentData = parm
    }
    
    /**
    * public method, 初始與設定 VCview 內的 field
    */
    internal func resetViewField() {
        // 會員資料區塊
        dictMember = (parentData["content"])?.objectForKey("member") as! Dictionary<String, AnyObject>
        
        dispatch_async(dispatch_get_main_queue(), {
            self.labMemberName.text = self.dictMember["usrname"] as? String
            self.labStoreName.text = self.dictMember["store_name"] as? String
            self.labStoreTel.text = self.dictMember["up_tel"] as? String
            
            // CollectionView, 健康資料重新 reload
            let dicContent = self.parentData["content"] as! Dictionary<String, AnyObject>
            self.aryHealth = dicContent["health"] as! [[String:String]]
            self.colviewHealth.reloadData()
            
            self.btnPict.reloadInputViews()
        })
        
        // 設定會員圖片, base64String to Image
        if let strEncode = parentData["content"]!["imgstr"] as? String {
            if (strEncode.characters.count > 0) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.imgUser.image = self.mImageClass.Base64ToImg(strEncode)
                })
            }
        }

    }
    
    /**
    * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Scroll View
        if segue.identifier == "MainCategory"{
            //let cvChild = segue.destinationViewController as! MainCategory
            return
        }
        
        // 會員編輯 segue, 設定會員資料 param
        if segue.identifier == "MemberEditContainer"{
            let cvChild = segue.destinationViewController as! MemberEditContainer
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
    
    @IBAction func actEditProfile(sender: UIButton) {
        
    }

}