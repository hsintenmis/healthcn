//
// 主選單
//

import UIKit
import Foundation

/**
* 主選單 class
*/
class MainCategory: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var viewScrolle: UIScrollView!
    var containerView: UIView!
    
    // public property
    var mVCtrl: UIViewController!
    var pubClass: PubClass!
    var popLoading: UIAlertController! // 彈出視窗 popLoading
    let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // 前一個頁面傳入的資料
    var parentData: Dictionary<String, AnyObject>!

    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(parentData)
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        popLoading = pubClass.getPopLoading()
        
        // Scroll View 處理
        // 设置container view来保持你定制的视图层次
        let containerSize = CGSize(width: 640.0, height: 640.0)
        containerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:containerSize))
        viewScrolle.addSubview(containerView)
        
        // 设置你定制的视图层次
        let redView = UIView(frame: CGRect(x: 0, y: 0, width: 640, height: 80))
        redView.backgroundColor = UIColor.redColor();
        containerView.addSubview(redView)
        
        let blueView = UIView(frame: CGRect(x: 0, y: 560, width: 640, height: 80))
        blueView.backgroundColor = UIColor.blueColor();
        containerView.addSubview(blueView)
        
        let greenView = UIView(frame: CGRect(x: 160, y: 160, width: 320, height: 320))
        greenView.backgroundColor = UIColor.greenColor();
        containerView.addSubview(greenView)
        
        let imageView = UIImageView(image: UIImage(named: "slow.png"))
        imageView.center = CGPoint(x: 320, y: 320);
        containerView.addSubview(imageView)
        
        // 告诉scroll view内容的尺寸
        viewScrolle.contentSize = containerSize;
        
        // 设置最大和最小的缩放系数
        let scrollViewFrame = viewScrolle.frame
        let scaleWidth = scrollViewFrame.size.width / viewScrolle.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / viewScrolle.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        viewScrolle.minimumZoomScale = minScale
        viewScrolle.maximumZoomScale = 1.0
        viewScrolle.zoomScale = 1.0
        
        //centerScrollViewContents()
        
        // 設定相關 UI text 欄位 delegate to textfile
        //self.initViewField()
    }
    
    override func viewDidAppear(animated: Bool) {
        // HTTP 連線取得本頁面需要的資料
        self.StartHTTPConn()
    }
    
    /**
    * 初始與設定 VCview 內的 field
    */
    func initViewField() {
    }
    
    /**
     * UIScrollViewDelegate 內建方法
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {

    }
    
    /**
    * HTTP 連線取得本頁面需要的資料
    */
    func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_homepage"
        
        var strConnParm: String = "";
        for (strParm, strVal) in dictParm {
            strConnParm += "\(strParm)=\(strVal)&"
        }
        
        // HTTP 開始連線
        mVCtrl.presentViewController(popLoading, animated: false, completion: nil)
        pubClass.startHTTPConn(strConnParm, callBack: HttpResponChk)
    }
    
    /**
    * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callbac function
    */
    func HttpResponChk(mData: NSData?) {
        popLoading.dismissViewControllerAnimated(true, completion: {})
        
        // 檢查回傳的 'NSData'
        if mData == nil {
            print(pubClass.getLang("err_data"))
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // 解析回傳的 NSData 為 JSON
        do {
            let jobjRoot = try NSJSONSerialization.JSONObjectWithData(mData!, options:NSJSONReadingOptions(rawValue: 0))
            
            guard let dictRespon = jobjRoot as? Dictionary<String, AnyObject> else {
                pubClass.popIsee(Msg: "資料解析錯誤 (JSON data error)！")
                
                return
            }
            
            if ( dictRespon["result"] as! Bool != true) {
                pubClass.popIsee(Msg: "回傳結果失敗！")
                print("JSONDictionary! \(dictRespon)")
                
                return;
            }
            
            // 解析正確的 jobj data
            self.HttpResponAnaly(dictRespon)
        }
        catch let errJson as NSError {
            pubClass.popIsee(Msg: "資料解析錯誤!\n\(errJson)")
            
            return
        }
        
        return
    }
    
    /**
    * 解析正確的 http 回傳結果，執行後續動作
    */
    func HttpResponAnaly(dictRespon: Dictionary<String, AnyObject>) {
        //print("JSONDictionary! \(dictRespon)")
    }



}