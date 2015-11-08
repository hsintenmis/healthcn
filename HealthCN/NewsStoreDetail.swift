//
// 店家新訊詳細內容
//

import UIKit
import Foundation

/**
 * 店家新訊詳細內容 class,
 */
class NewsStoreDetail: UIViewController {
    @IBOutlet weak var tableDetail: UITableView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    /**
     * 前一個頁面傳入的資料, 參數如下<BR>
     * title, content, pict:'img_店家編號_流水號.png'
     */
    var parentData: Dictionary<String, String>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        //print(parentData)
        self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        tableDetail.reloadData()
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        // 初始 TableView Cell 自動調整高度
        tableDetail.estimatedRowHeight = 250.0
        tableDetail.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * UITableView, 'section' 回傳指定的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView!)->Int {
        return 1
    }
    
    /**
     * UITableView<BR>
     * 宣告這個 UITableView 畫面上的控制項總共有多少筆資料<BR>
     * 可根據 'section' 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return 1
    }
    
    /**
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell: NewsStoreDetailCell = tableView.dequeueReusableCellWithIdentifier("cellNewsStoreDetail", forIndexPath: indexPath) as! NewsStoreDetailCell
        
        cell.labDate.text = pubClass.formatDateWIthStr(parentData["sdate"], type: 8)
        cell.labTitle.text = parentData["title"]
        cell.labContent.text = parentData["content"]
        
        // image 處理
        let url = NSURL(string: (pubClass.D_WEBURL + "upload/" + parentData["pict"]!))
        
        if let mData = NSData(contentsOfURL: url!) {
            let mImg: UIImage = pubClass.resizeImageWithWidth(UIImage(data: mData)!, imgWidth: 320.0)
            cell.imgPict.frame.size = mImg.size
            cell.imgPict.image = mImg
        } else {
            cell.imgPict.hidden = true
        }
        
        return cell
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}