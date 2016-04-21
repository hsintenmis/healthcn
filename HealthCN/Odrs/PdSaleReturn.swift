//
// TableList
//

import UIKit
import Foundation

/**
 * 商品銷售退回明細與列表
 */
class PdSaleReturn: UIViewController {

    @IBOutlet weak var tableList: UITableView!
    
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labInvoId: UILabel!
    @IBOutlet weak var labReturnPrice: UILabel!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    // TableView datasource, 由 parent class 設定帶入
    var dictAllData: Dictionary<String, AnyObject>!
    
    // 全部退貨array data
    private var aryAllReturn: Array<Dictionary<String, AnyObject>>!
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        aryAllReturn = dictAllData["return"] as! Array<Dictionary<String, AnyObject>>
        
        self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
        // TableCell autoheight
        self.tableList.estimatedRowHeight = 160.0
        self.tableList.rowHeight = UITableViewAutomaticDimension
        self.tableList.reloadData()
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        labSdate.text = pubClass.formatDateWithStr(dictAllData["sdate"] as! String, type: 14)
        labInvoId.text = dictAllData["id"] as? String
        labReturnPrice.text = dictAllData["returnprice"] as? String
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
        return aryAllReturn.count
    }
    
    /**
     * UITableView, Cell 內容(商品資料)
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let ditItem = aryAllReturn[indexPath.row] as Dictionary<String, AnyObject>
        let mCell: PdSaleReturnCell = tableView.dequeueReusableCellWithIdentifier("cellPdSaleReturn", forIndexPath: indexPath) as! PdSaleReturnCell
        let strSdate = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: 12)
        
        mCell.labSdate.text = pubClass.getLang("odrs_listname_returndate") + " " + strSdate
        mCell.labPrice.text = ditItem["price"] as? String
        mCell.labPriceCust.text = ditItem["custprice"] as? String
        
        dispatch_async(dispatch_get_main_queue(), {
            mCell.labReturnMsg.text = self.getReturnMsg(ditItem["pd"] as! Array<Dictionary<String, String>>)
        })
        
        return mCell
    }
    
    /**
    *  產生退貨商品文字, 帶入退貨商品 array, 產生格式如下：
    *
    *   YS-500 遠紅外線保健儀(大床，店家專用) (C00001)
    *   單價: 7680, 退貨數量:10, 合計: 76800
    *
    *   通暢導引精華油精華(C00001),
    *   單價: 120, 退貨數量:3, 合計: 360
    */
    private func getReturnMsg(aryPd: Array<Dictionary<String, String>>!)->String {
        var strRS = ""
        let nums = aryPd.count
        var strName = "", strID = "", strQty = "", strPrice = "", strAmout = "0";
        
        // loop data
        for loopi in (0..<nums) {
            let dictItem = aryPd[loopi]
            strName = dictItem["pdname"]!
            strID = dictItem["pdid"]!
            strQty = dictItem["qty"]!
            strPrice = dictItem["price"]!
            strAmout = String(Int(strQty)! * Int(strPrice)!)
            
            strRS += strName + "(" + strID + ")" + "\n"
            strRS += pubClass.getLang("odrs_listname_unitprice") + strPrice + ", " + pubClass.getLang("odrs_listname_rqty") + strQty + ", " + pubClass.getLang("odrs_listname_amount") + strAmout
            
            if (loopi < (nums - 1)) {
                strRS += "\n\n"
            }
        }
        
        return strRS
    }
    
    /**
     * UITableView, Header 內容
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pubClass.getLang("odrs_returndetail")
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