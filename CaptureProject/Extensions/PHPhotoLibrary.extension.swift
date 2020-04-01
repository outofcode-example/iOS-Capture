//
//  UIImage+SaveAlbum.swift
//  CaptureProject
//
//  Created by DH on 2020/03/28.
//  Copyright © 2020 outofcode. All rights reserved.
//

import UIKit
import Photos

// MARK: - Save Photo

enum PHPPhotoLibrarySaveStatus {
    case authorizationFail
    case cancel
    case success(PHAsset)
    case fail
}

enum PHPRequestAuthorizationStatus {
    case cancel
    case fail
    case success
}

extension PHPhotoLibrary {
    
    class func syncRequestAuthorization() -> PHPRequestAuthorizationStatus {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            return .success
        case .denied, .restricted:
            return .fail
        case .notDetermined:
            break
        @unknown default:
            fatalError()
        }
        
        let semaphore = DispatchSemaphore(value: 0)

        PHPhotoLibrary.requestAuthorization{ _ in
            semaphore.signal()
        }
        
        semaphore.wait()
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            return .success
        case .denied, .restricted, .notDetermined:
            return .cancel
        @unknown default:
            fatalError()
        }
    }
    
    func saveAlbum(name albumName: String, image: UIImage, completion: @escaping (PHPPhotoLibrarySaveStatus) -> Void) {
        let authorizationStatus = PHPhotoLibrary.syncRequestAuthorization()
        guard authorizationStatus == .success else {
            switch authorizationStatus {
            case .fail:
                completion(.authorizationFail)
            case .cancel:
                completion(.cancel)
            default:
                break
            }
            return
        }
        
        let saveCompletion: ((PHAsset?) -> ()) = { asset in
            if let asset = asset {
                completion(.success(asset))
            } else {
                completion(.fail)
            }
        }
        
        if let album = findAlbum(albumName: albumName) {
            saveImage(image: image, album: album, completion: saveCompletion)
        } else {
            createAlbum(albumName: albumName, completion: { [weak self] (collection) in
                guard let self = self else { return }
                
                if let collection = collection {
                    self.saveImage(image: image, album: collection, completion: saveCompletion)
                } else {
                    completion(.fail)
                }
            })
        }
    }
    
    private func findAlbum(albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }
    
    private func createAlbum(albumName: String, completion: @escaping (PHAssetCollection?) -> Void) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    completion(nil)
                    return
                }
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                completion(album)
            } else {
                completion(nil)
            }
        })
    }
    
    private func saveImage(image: UIImage, album: PHAssetCollection, completion: @escaping (PHAsset?) -> Void) {
        var placeholder: PHObjectPlaceholder?
        performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }
            placeholder = photoPlaceholder
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                completion(nil)
                return
            }
            
            if success {
                let assets:PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                let asset:PHAsset? = assets.firstObject
                completion(asset)
            } else {
                completion(nil)
            }
        })
    }
}
