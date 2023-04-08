//
//  MTBrowseAssetUtils.swift
//  MTPhotoBroswer
//
//  Created by cyc on 2023/4/8.
//

import Foundation

public extension UIView {
    public var mt_controller: UIViewController? {
        var next = next
        while next != nil {
            if next is UIViewController {
                return next as? UIViewController
            }
            next = next?.next
        }
        return nil
    }
}
