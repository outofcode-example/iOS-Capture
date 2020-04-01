//
//  UIView.extension.swift
//  CaptureProject
//
//  Created by DH on 2020/03/28.
//  Copyright © 2020 outofcode. All rights reserved.
//

import UIKit

extension UIView {
    var image: UIImage? {
        var image: UIImage?
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        
        return image
    }
}
