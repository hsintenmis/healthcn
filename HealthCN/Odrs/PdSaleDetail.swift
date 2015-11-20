//
// TableList
//

import UIKit
import Foundation

/**
* 會員購貨明細(訂單明細)，提供以下資料:<BR>
* Invoice 相關數值資料，購買商品項目明細
*/
class PdSaleDetail: UIViewController {
    
    @IBOutlet weak var btnReturnDetail: UIBarButtonItem!
    @IBOutlet weak var tableList: UITableView!
    
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labInvoId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labCustPrice: UILabel!
    
    @IBOutlet weak var labRetrunName: UILabel!
    @IBOutlet weak var labReturnPrice: UILabel!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    // TableView datasource, 由 parent class 設定帶入
    var dictAllData: Dictionary<String, AnyObject>!
    private var aryOdrsPd: Array<Dictionary<String, AnyObject>> = []
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        aryOdrsPd = dictAllData["odrs"] as! Array<Dictionary<String, AnyObject>>
        
        self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        labSdate.text = pubClass.formatDateWithStr(dictAllData["sdate"] as! String, type: 12)
        labInvoId.text = dictAllData["id"] as? String
        labPrice.text = dictAllData["price"] as? String
        labCustPrice.text = dictAllData["custprice"] as? String
        labRetrunName.alpha = 0.0
        labReturnPrice.alpha = 0.0
        
        // 是否有退貨
        let strReturnPrice = dictAllData["returnprice"] as! String
        if (Int(strReturnPrice) > 0) {
            labRetrunName.alpha = 1.0
            labReturnPrice.alpha = 1.0
            labReturnPrice.text = strReturnPrice
        }
        else {
            btnReturnDetail.title = ""
            btnReturnDetail.enabled = false
        }
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
        return aryOdrsPd.count
    }
    
    /**
     * UITableView, Cell 內容(商品資料)
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {

        let ditItem = aryOdrsPd[indexPath.row] as Dictionary<String, AnyObject>
        let mCell: PdSaleDetailCell = tableView.dequeueReusableCellWithIdentifier("cellPdSaleDetail", forIndexPath: indexPath) as! PdSaleDetailCell
        
        let strQty = ditItem["qty"] as! String
        let strPrice = ditItem["price"] as! String
        let strAmount = String(Int(strQty)! * Int(strPrice)!)
        
        mCell.labPdName.text = ditItem["pdname"] as? String
        mCell.labPdId.text = ditItem["pdid"] as? String
        mCell.labPriceUnit.text = strPrice
        mCell.labQty.text = strQty
        mCell.labAmout.text = strAmount
        
        // 判斷是否有退貨
        mCell.labReturnMsg.text = ""
        let rQty = ditItem["returnQty"] as! String
        if (Int(rQty) > 0) {
            mCell.labReturnMsg.text = pubClass.getLang("odrs_returnqty") + ": " + rQty
        }
        
        return mCell
    }
    
    /**
     * UITableView, Header 內容
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pubClass.getLang("odrs_orderpdlist")
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // segue = "PdSaleReturn", 退貨明細列表
        if (segue.identifier == "PdSaleReturn") {
            let cvChild = segue.destinationViewController as! PdSaleReturn
            cvChild.dictAllData = dictAllData
            
            return
        }
        
        return
    }
    
    /**
     * btn '退貨明細' 點取
     */
    @IBAction func actReturn(sender: UIBarButtonItem) {
        //self.dismissViewControllerAnimated(true, completion: nil)
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