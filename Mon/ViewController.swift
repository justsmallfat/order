//
//  ViewController.swift
//  Crispy
//
//  Created by 小胖 on 2020/4/6.
//  Copyright © 2020 riti. All rights reserved.
//

import UIKit
import Photos
import FBSDKShareKit
import GoogleMobileAds




class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, orderSetDelegate, SharingDelegate, BannerViewDelegate {
    func orderSet(index: Int, name: String?, count: Int?) {
        if name != nil {
            self.datas[index]["name"] = name
        }
        if count != nil {
            self.datas[index]["count"] = count
        }
        print(self.datas)
    }
    
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var bannerView: BannerView!
    
    @IBOutlet var gamesCollectionView: UICollectionView!
    
//    var bannerView : GADBannerView!
    var datas = [[String:Any]]()
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("sharer1")
    }

    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("sharer2")
    }

    func sharerDidCancel(_ sharer: Sharing) {
        print("sharerDidCancel")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if checkCamPhoto() {
            //有權限
        }else{
            //無權限
        }
        NSLog("checkCamPhoto()  \(checkCamPhoto())")
        
        
        let userDefault = UserDefaults.standard
        var defaultDatas = userDefault.object(forKey: "order")
        userDefault.synchronize()
        
        if (defaultDatas == nil) {
            defaultDatas = [
                ["index":1, "name":"鹹酥雞", "count":1],["index":2, "name":"魷魚","count":1],
                ["index":3, "name":"雞排","count":0],["index":4, "name":"地瓜","count":1],
                ["index":5, "name":"百頁豆腐","count":2],["index":6, "name":"四季豆","count":1],
                ["index":7, "name":"香菇","count":1],["index":8, "name":"雞皮","count":0],
                ["index":9, "name":"花椰菜","count":2],["index":10, "name":"玉米","count":1],
                ["index":11, "name":"青椒","count":0],["index":12, "name":"甜不辣","count":0],
                ["index":13, "name":"糯米腸","count":1],["index":14, "name":"芋粿巧","count":1],
                ["index":15, "name":"花枝丸","count":1],["index":16, "name":"雞屁股","count":4],
                ["index":17, "name":"雞腳","count":0],["index":18, "name":"雞胗","count":0],
                ["index":19, "name":"雞心","count":0],["index":20, "name":"魚板","count":0],
                ["index":21, "name":"雞翅","count":2],["index":22, "name":"銀絲捲","count":0],
                ["index":23, "name":"芋籤","count":0],["index":24, "name":"豆乾","count":1],
                ["index":25, "name":"豬血糕","count":0],["index":26, "name":"熱狗","count":0],
                ["index":27, "name":"雞蛋豆腐","count":1],["index":28, "name":"雞腸","count":4]]
        }
        // Do any additional setup after loading the view.
        datas = defaultDatas as! [[String : Any]]
        
        self.gamesCollectionView.register(UINib(nibName: "BoxCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BoxCollectionViewCell")
        self.gamesCollectionView.delegate = self
        self.gamesCollectionView.dataSource = self
        
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            print("App Version: \(version)")
            print("Build Number: \(build)")
            self.versionLabel.text = "版本：\(version)"
        }
        
        bannerView.adUnitID = "ca-app-pub-2248104426660919/3784368423"
        bannerView.rootViewController = self
        bannerView.load(Request())

        bannerView.delegate = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxCollectionViewCell", for: indexPath) as! BoxCollectionViewCell
        cell.initWithData(data: self.datas[indexPath.row])
        cell.delegate = self
        cell.name.tag = indexPath.row
        cell.count.tag = indexPath.row+100
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow: CGFloat = 2  // 你要一行顯示幾個
        let paddingSpace = 40 * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    @IBAction func catchView(_ sender: Any) {
        
        let userDefault = UserDefaults.standard
        userDefault.set(datas, forKey: "order")
        userDefault.synchronize()
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0)
        gamesCollectionView.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let shareImage = UIGraphicsGetImageFromCurrentImageContext()
        let avc = UIActivityViewController(activityItems: [shareImage as Any], applicationActivities: nil)

        // 🔧 修正 iPad popover crash
        if let popover = avc.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                        y: self.view.bounds.midY,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }

        self.present(avc, animated: true, completion: nil)
        
//        [self presentViewController:avc animated:YES completion:nil];
        UIGraphicsEndImageContext()
//        // Create a dialog for sharing to Messenger
        let content = SharePhotoContent()

        let dialog = MessageDialog(
          content: content,
          delegate: self
        )

        guard dialog.canShow else {
            print("Facebook Messenger must be installed in order to share to it")
            return
        }

        dialog.show()
        PhotoAlbumUtil.saveImageInAlbum(image: shareImage!, albumName: "吃炸Ｇ") { (result) in
            switch result{
            case .success:
                print("保存成功!")
                //通过标志符获取对应的资源
                let assetResult = PHAsset.fetchAssets(
                    withLocalIdentifiers: [PhotoAlbumUtil.localId], options: nil)
                let asset = assetResult[0]
                let options = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
                    -> Bool in
                    return true
                }

                let option = PHImageRequestOptions()
                option.isSynchronous = true
                //获取保存的原图
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFit,
                    options: option,
                    resultHandler:
                    { (image, _:[AnyHashable : Any]?) in
                        let errorAlertController = UIAlertController(title: "恭喜", message: "照片儲存成功", preferredStyle: UIAlertController.Style.alert)
                        
                        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {(UIAlertAction) in
                            
                        })
                        errorAlertController.addAction(okAction)
                        self.present(errorAlertController, animated: true, completion: nil)
                        print("保存成功2!")
                })

            case .denied:
                print("被拒绝")
            case .error:
                print("保存错误")
            }
        }
        
    }
    
    func checkCamPhoto() -> Bool {
        let photoLibraryStatus = PHPhotoLibrary.authorizationStatus() //相簿請求
        let camStatus = AVCaptureDevice.authorizationStatus(for: .video) //相機請求
        
        let okAction = UIAlertAction(title: NSLocalizedString("Setting", comment: ""), style: .default, handler: { (UIAlertAction) in
            self.toSetting()
        })
        return false
    }

    
    func toSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString){
            if (UIApplication.shared.canOpenURL(url)){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

