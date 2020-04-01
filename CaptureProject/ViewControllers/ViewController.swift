//
//  ViewController.swift
//  CaptureProject
//
//  Created by DH on 2020/03/28.
//  Copyright © 2020 outofcode. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func didClickButton(_ sender: Any) {
        view.image?.saveAlbum(name: "aaa", completion: { status in
            switch status {
            case .authorizationFail:
                let url = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(url)
            case .authorizationCancel:
                // Not work
                break
            case .fail:
                print("fail")
            case .success(_):
                print("success")
            }
        })
    }
}
