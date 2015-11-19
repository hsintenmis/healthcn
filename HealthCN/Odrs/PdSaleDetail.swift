//
//
//
import Foundation


/**
* 會員購貨明細(訂單明細)，提供以下資料:<BR>
* Invoice 相關數值資料，購買商品項目明細
*/
class PdSaleDetail: UIViewController {
    
    
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labInvoId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labCustPrice: UILabel!
    @IBOutlet weak var labReturnPrice: UILabel!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    
    /**
     * 前一個頁面傳入的資料
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
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {

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