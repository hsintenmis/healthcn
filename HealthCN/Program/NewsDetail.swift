//
// 最新消息詳細內容
//

import UIKit
import Foundation

/**
* 最新消息詳細內容 class,
*/
class NewsDetail: UIViewController {
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
        tableDetail.estimatedRowHeight = 10.0
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
        
        let cell: NewsDetailCell = tableView.dequeueReusableCellWithIdentifier("cellNewsDetail", forIndexPath: indexPath) as! NewsDetailCell
        
        cell.labDate.text = pubClass.formatDateWIthStr(parentData["sdate"], type: 8)
        cell.labTitle.text = parentData["title"]
        cell.labContent.text = parentData["content"]
        
        print(parentData["pict"])
        
        // image 處理
        if let url = NSURL(string: (pubClass.D_WEBURL + "upload/" + parentData["pict"]!)) {
            if let data = NSData(contentsOfURL: url) {
                cell.imgPict.image = UIImage(data: data)
            }        
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