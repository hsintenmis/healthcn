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
class ImageCut: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgPict: UIImageView!
    
    // common property
    private var isPageReloadAgain = false // child close, 返回本class辨識標記
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    private let mAppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    // ImagePicker 設定
    let imagePicker = UIImagePickerController()
    
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imgPict.contentMode = .ScaleAspectFit
            imgPict.image = pickedImage
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * 點取 選擇圖片
     */
    @IBAction func actSelPict(sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
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