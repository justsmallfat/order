//
//  PhotoAlbumUtil.swift
//  tms
//
//  Created by 小胖 on 2019/2/26.
//  Copyright © 2019 kevin. All rights reserved.
//

import Photos
import UIKit
//操作结果枚举
enum PhotoAlbumUtilResult {
    case success, error, denied
}

//相册操作工具类
class PhotoAlbumUtil: NSObject {
    
    //存放照片资源的标志符
    static var localId = ""
    
    //存放照片资源的ㄆ位置
    static var localpath = ""
    
    
    //判断是否授权
    class func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized ||
            PHPhotoLibrary.authorizationStatus() == .notDetermined
    }
    
    //保存图片到相册
    class func saveImageInAlbum(image: UIImage, albumName: String = "",
                                completion: ((_ result: PhotoAlbumUtilResult) -> ())?) {
        
        //权限验证
        if !isAuthorized() {
            completion?(.denied)
            return
        }
        var assetAlbum: PHAssetCollection?
        
        //如果指定的相册名称为空，则保存到相机胶卷。（否则保存到指定相册）
        if albumName.isEmpty {
            let list = PHAssetCollection
                .fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary,
                                       options: nil)
            assetAlbum = list[0]
        } else {
            //看保存的指定相册是否存在
            let list = PHAssetCollection
                .fetchAssetCollections(with: .album, subtype: .any, options: nil)
            list.enumerateObjects({ (album, index, stop) in
                let assetCollection = album
                if albumName == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    stop.initialize(to: true)
                }
            })
            //不存在的话则创建该相册
            if assetAlbum == nil {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest
                        .creationRequestForAssetCollection(withTitle: albumName)
                }, completionHandler: { (isSuccess, error) in
                    self.saveImageInAlbum(image: image, albumName: albumName,
                                          completion: completion)
                })
                return
            }
        }
        
        //保存图片
        PHPhotoLibrary.shared().performChanges({
            //添加的相机胶卷
            let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
            //是否要添加到相簿
            if !albumName.isEmpty {
                let assetPlaceholder = result.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(for:
                    assetAlbum!)
                albumChangeRequset!.addAssets([assetPlaceholder!]  as NSArray)
                
                localId = (assetPlaceholder?.localIdentifier)!
            }
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                
                let assetResult = PHAsset.fetchAssets(
                    withLocalIdentifiers: [self.localId], options: nil)
                let asset = assetResult[0]
                let options = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
                    -> Bool in
                    return true
                }
                //获取保存的图片路径
                asset.requestContentEditingInput(with: options, completionHandler: {
                    (contentEditingInput:PHContentEditingInput?, info: [AnyHashable : Any]) in
                    localpath = contentEditingInput!.fullSizeImageURL!.absoluteString
                    completion?(.success)
                })
                
            } else{
                NSLog(error!.localizedDescription)
                completion?(.error)
            }
        }
    }
    
    
    
    class func getImage(id : String) -> UIImage {
        let assetResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [id], options: nil)
        
        var returnImage = UIImage()
        if (assetResult == nil || assetResult.count<1) {
            return returnImage
        }
        let asset = assetResult[0]
        let options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
            -> Bool in
            return true
        }
        
        
        var imageRequestOptions: PHImageRequestOptions?
        imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions?.resizeMode = .exact
        imageRequestOptions?.isSynchronous = true
        
        //获取保存的原图
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: imageRequestOptions,
            resultHandler: {
                (image, _:[AnyHashable : Any]?) in
                if(image != nil){
                    returnImage = image!
                }else{
                    NSLog("获取原图失敗：\(id)")
                }
        })
        
        return returnImage
    }
}
