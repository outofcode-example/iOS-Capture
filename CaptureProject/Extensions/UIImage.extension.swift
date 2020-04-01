//
//  UIImage.extension.swift
//  CaptureProject
//
//  Created by DH on 2020/03/28.
//  Copyright © 2020 outofcode. All rights reserved.
//

import UIKit
import Photos

extension Optional where Wrapped == UIImage {
    func saveAlbum(name albumName: String, completion: @escaping (PHPPhotoLibrarySaveStatus) -> Void) {
        if let image = self {
            image.saveAlbum(name: albumName, completion: completion)
        } else {
            return completion(.fail)
        }
    }
}

extension UIImage {
    func saveAlbum(name albumName: String, completion: @escaping (PHPPhotoLibrarySaveStatus) -> Void) {
        PHPhotoLibrary.shared().saveAlbum(name: albumName, image: self, completion: completion)
    }
}
