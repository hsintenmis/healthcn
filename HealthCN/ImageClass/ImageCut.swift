//
// 圖片選擇 + 裁切 + 上傳
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
 * 會員大頭照上傳
 */
class ImageCut: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    @IBOutlet weak var imgPict: UIImageView!
    @IBOutlet weak var imgPreview: UIImageView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // ImagePicker 設定
    let imagePicker = UIImagePickerController()
    var mImage = UIImage()
    let mImageClass = ImageClass()
    
    // View load
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(parentData)
        
        // 固定初始參數
        mVCtrl = self
        pubClass = PubClass(viewControl: mVCtrl)
        
        // 設定相關 UI text 欄位 delegate to textfile
        self.initViewField()
        
        // ImagePicker 設定
        imagePicker.delegate = self
        
        // 設定手勢 Gesture
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapImageView")
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // 選擇圖片後，執行第三方圖片處理
        dismissViewControllerAnimated(true, completion: {
            ()->Void in
            
            self.mImage = image
            
            let cropController = TOCropViewController(image: image)
            cropController.delegate = self
            self.presentViewController(cropController, animated: true, completion: nil)
        })
    }
    /*
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imgPict.contentMode = .ScaleAspectFit
            imgPict.image = pickedImage
        }
    }
    */

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
            
            self.imgPict.image = image
            self.imgPict.hidden = false
            
            let newImage = self.mImageClass.ResizeImage(image, targetSize: CGSize(width: 128, height: 128))
            let strImgEncode = self.mImageClass.ImgToBase64(newImage)
            self.imgPreview.image = self.mImageClass.Base64ToImg(strImgEncode)
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
            noCamera()
        }
    }
    
    /**
    * 沒有相機，彈出視窗
    */
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    /**
     * 儲存圖片
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let strImgEncode = mImageClass.ImgToBase64(self.imgPreview.image!)
        
        print(strImgEncode)
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