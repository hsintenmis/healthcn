//
// TabvleView 資料列表, Cell 使用標準內建格式 'SubTitle'
//

/**
* Soqibed 全部紀錄列表 TableView List, 點取 Cell 顯示詳細資料
*/
class SoqibedLogAll: UIViewController {
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // public, 由 parent 設定, 本 class 需要使用的資料
    var strLogType: String = "stand"  // priv or stand
    var aryAllData: Array<Dictionary<String, AnyObject>> = [[:]]
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableList.reloadData()
        })
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
        return aryAllData.count
    }
    
    /**
     * UITableView, Cell 內容, 使用內建格式 'SubTitle'
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryAllData.count < 1) {
            return nil
        }
        
        // 取得 Item data source
        let ditItem = aryAllData[indexPath.row]
        
        // 取得 CellView
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSoqibedLogAll")!
        let strSDate = pubClass.formatDateWIthStr(ditItem["sdate"] as? String, type: "8s")
        
        mCell.textLabel?.text = ditItem["title"] as? String
        mCell.detailTextLabel?.text = strSDate
        
        return mCell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}