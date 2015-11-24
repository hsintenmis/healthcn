//
// 前一個頁面的 Cell 點取進入本頁面
//

/**
* 氧身工程模式新增編修，本 Class 僅作顯示
* <P>
* 會員使用模式資料, 新增/編輯刪除<BR>
* 各個裝置(H01, H02..)都需要設定預設值
* <P>
* 資料產生方式:<BR>
* 1. MEAD檢測結果產生<br>
* 2. 購買療程<br>
* 3. 自行輸入
*/
class SoqibedAdEd: UIViewController {
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labH00: UILabel!
    @IBOutlet weak var labH01: UILabel!
    @IBOutlet weak var labH02: UILabel!
    @IBOutlet weak var labH10: UILabel!
    @IBOutlet weak var labH11: UILabel!
    @IBOutlet weak var labH12: UILabel!
    @IBOutlet weak var labS00: UILabel!
    
    // common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // 本頁面需要的 data source
    var aryAllData: Dictionary<String, AnyObject> = [:]  // parent 設定
    private var aryTimes: Array<Dictionary<String, String>> = []  // 使用時間 array
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 取得使用時間 array
        if let tmpAry = aryAllData["times"] as? Array<Dictionary<String, String>> {
            aryTimes = tmpAry
        }
        
        // 初始與設定 VCview 內的 field
        self.initViewField()
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            self.labTitle.text = self.aryAllData["title"] as? String
            self.labH00.text = self.aryAllData["H00"] as? String
            self.labH01.text = self.aryAllData["H01"] as? String
            self.labH02.text = self.aryAllData["H02"] as? String
            self.labH10.text = self.aryAllData["H10"] as? String
            self.labH11.text = self.aryAllData["H11"] as? String
            self.labH12.text = self.aryAllData["H12"] as? String
            self.labS00.text = self.aryAllData["S00"] as? String
        })

        if let _ = self.aryAllData["id"] {
            let strSdate = pubClass.getLang("soqibed_builddate") + ":" + pubClass.formatDateWithStr(self.aryAllData["sdate"] as! String, type: 8)
            self.labSdate.text = strSdate
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
        return aryTimes.count
    }
    
    /**
     * UITableView, Cell 內容, 使用內建格式 'Basic'
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryTimes.count < 1) {
            return nil
        }
        
        // 取得 Item data source, 設定 CellView field
        let ditItem = aryTimes[indexPath.row]
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSoqibedAdEd")!
        let strSDate = pubClass.formatDateWithStr(ditItem["sdate"], type: "14s")
        mCell.textLabel?.text = strSDate
        
        return mCell
    }
    
    /**
     * 返回前頁
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}