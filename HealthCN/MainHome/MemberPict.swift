//
// 圖片選擇 + 裁切 + HTTP 上傳
//
// UIImagePickerControllerSourceType.PhotoLibrary
// UIImagePickerControllerSourceType.Camera
// UIImagePickerControllerSourceType.SavedPhotosAlbum
//
// 此處info 有六個值
// UIImagePickerControllerMediaType; // an NSString UTTypeImage)
// UIImagePickerControllerOriginalImage;  // a UIImage 原始圖片
// UIImagePickerControllerEditedImage;    // a UIImage 裁剪後圖片
// UIImagePickerControllerCropRect;       // an NSValue (CGRect)
// UIImagePickerControllerMediaURL;       // an NSURL
// UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
// UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
//
//

import Foundation
import UIKit

/**
 * 會員大頭照上傳, 圖片轉為 base64 string 上傳儲存
 */
class MemberPict: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    @IBOutlet weak var imgPict: UIImageView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // ImagePicker, 圖片相關設定
    let aryPictSize = [256, 256]  // 長/寬
    let imagePicker = UIImagePickerController()
    var mImage = UIImage()
    let mImageClass = ImageClass()
    var strImgBase64 = ""  // 選擇完成的圖片 Base64 string
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(parentData)
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定相關 IBOutlet 欄位
        self.initViewField()
        
        // ImagePicker, 圖片相關設定
        imagePicker.delegate = self
        
        // 設定手勢 Gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapImageView))
        self.imgPict.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!isPageReloadAgain) {
            isPageReloadAgain = true

            return
        }
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * Read the Image Picked from UIImagePickerController
     * 此處info 有六個值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始圖片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪後圖片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage pickImg: UIImage, editingInfo: [String : AnyObject]?) {
        
        // 選擇圖片後，執行第三方圖片處理
        dismissViewControllerAnimated(true, completion: {
            ()->Void in
            
            self.mImage = pickImg
            
            let cropController = TOCropViewController(image: pickImg)
            cropController.delegate = self
            self.presentViewController(cropController, animated: true, completion: nil)
        })
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * 第三方圖片處理, 裁切完成後傳回圖片
     */
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        
        self.imgPict.hidden = true
        
        cropViewController.dismissAnimatedFromParentViewController(self, withCroppedImage: image, toFrame: self.imgPict.frame, completion: {
            () -> Void in
            
            let newImage = self.mImageClass.ResizeImage(image, targetSize: CGSize(width: self.aryPictSize[0], height: self.aryPictSize[1]))
            self.imgPict.image = newImage

            self.imgPict.hidden = false
        })
    }
    
    /**
    * 手勢 Gesture, 調整圖片大小
    */
    func didTapImageView() {
        let cropController = TOCropViewController(image: self.mImage)
        cropController.delegate = self;

        self.presentViewController(cropController, animated: true, completion: nil)
    }
    
    /**
     * 點取 本地相簿
     */
    @IBAction func actSelPhotoLibrary(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /**
     * 點取 選擇相機
     */
    @IBAction func actSelCamera(sender: UIBarButtonItem) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = .Photo
            presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            pubClass.popIsee(Msg: pubClass.getLang("nocameramsg"))
        }
    }
    
    /**
     * 儲存圖片
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        self.strImgBase64 = self.mImageClass.ImgToBase64(self.imgPict.image!)
        
        if (strImgBase64.characters.count < 1) {
            pubClass.popIsee(Msg: pubClass.getLang("plsselpict"))
            
            return
        }
        
        self.StartHTTPSaveConn()
    }
    
    /**
     * HTTP 連線, 上傳資料儲存
     */
    func StartHTTPSaveConn() {
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = mAppDelegate.V_USRACC
        dictParm["psd"] = mAppDelegate.V_USRPSD
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_sendpict"
        dictParm["arg1"] = self.strImgBase64
        
        // 產生 arg0 參數資料
        var dictArg: Dictionary<String, String> = [:]
        dictArg["filename"] = pubClass.MemberHeadimgFile(mAppDelegate.V_USRACC)
        dictArg["type"] = "head"
        //dictArg["image"] = self.strImgBase64
        dictArg["mime"] = "png"
        
        // 產生 JSON string
        do {
            let jobjData = try NSJSONSerialization.dataWithJSONObject(dictArg, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSASCIIStringEncoding)! as String

            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // HTTP 開始連線
        //pubClass.showPopLoading(nil)
        pubClass.startHTTPConn(dictParm, callBack: HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        //pubClass.closePopLoading()
        
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            pubClass.popIsee(self, Msg: dictRS["msg"] as! String, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})

            return
        }
        
        // 上傳與儲存完成，本 class 結束
        pubClass.popIsee(self, Msg: pubClass.getLang("pictupdatecomplete"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
        
        return
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