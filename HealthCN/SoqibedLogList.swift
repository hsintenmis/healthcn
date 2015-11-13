//
// TabvleView 資料列表, Cell 使用標準內建格式 'SubTitle'
//

/**
* Soqibed 私人+標準 列表 TableView List, 點取 Cell 顯示詳細資料
*/
class SoqibedLoglist: UIViewController {
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // public, 由 parent 設定, 本 class 需要使用的資料
    var strLogType: String = ""  // priv or stand
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSoqibedLogList")!
        let strSDate = pubClass.formatDateWIthStr(ditItem["sdate"] as? String, type: "8s")
        let strCounts = ditItem["count"] as! String
        
        let strSubTitle = pubClass.getLang("soqibed_actdate") + ": " + strSDate + ", " + pubClass.getLang("soqibed_usecount") + ": " + strCounts
        
        mCell.textLabel?.text = ditItem["title"] as? String
        mCell.detailTextLabel?.text = strSubTitle
        
        return mCell
    }
     
     /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 取得點取 cell 的 index, 產生 JSON data
        let indexPath = self.tableNews.indexPathForSelectedRow!
        let ditItem = aryAllData[indexPath.row] as! Dictionary<String, String>
        let cvChild = segue.destinationViewController as! NewsStoreDetail
        cvChild.parentData = ditItem
        
        return
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}