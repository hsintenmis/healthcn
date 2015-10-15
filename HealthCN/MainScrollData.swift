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
class MainScrollData: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var labMemberName: UILabel!
    @IBOutlet weak var labStoreName: UILabel!
    @IBOutlet weak var labStoreTel: UILabel!
    
    @IBOutlet weak var colviewHealth: UICollectionView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    // 本 class 需要使用的 json data
    var parentData: Dictionary<String, AnyObject>!
    var aryHealth: Array<Dictionary<String, String>>?
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定相關 UI text 欄位
        //self.initViewField()
    }
    
    /**
    * 設定本 class 需要使用的 json data
    */
    internal func setParam(parm: Dictionary<String, AnyObject>) {
        parentData = parm
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    internal func initViewField() {
        // 會員資料區塊
        let dictMember = (parentData["content"])?.objectForKey("member") as! Dictionary<String, AnyObject>
        
        labMemberName.text = dictMember["usrname"] as? String
        labStoreName.text = dictMember["store_name"] as? String
        labStoreTel.text = dictMember["up_tel"] as? String
        
        // CollectionView, 健康資料重新 reload
        aryHealth = (parentData["content"])?.objectForKey("health") as? [Dictionary<String, String>]
        
        colviewHealth.reloadData();
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
        if let count = aryHealth?.count {
            //print(aryHealth?[1])
            return count
        }
        
        return 0
    }
    
    /**
    * CollectionView, 設定 Cell 的内容
    */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CellViewHealth = collectionView.dequeueReusableCellWithReuseIdentifier("cellHealthVal", forIndexPath: indexPath) as! CellViewHealth
        
        let ditItem = aryHealth[1] as Dictionary<String, String>
        
        
        cell.labVal.text = ""
        cell.labItem.text = "Item \(indexPath.row)"
        
        return cell
    }
    
    @IBAction func actEditProfile(sender: UIButton) {
        print("edit")
    }

}