//
//  UIBarButtonItem+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/8.
//
import UIKit

public extension TFY where Base: UIBarButtonItem {
    
    @discardableResult
    func width(_ width: CGFloat) -> TFY {
        base.width = width
        return self
    }
    
    @discardableResult
    func tintColor(_ tintColor: UIColor?) -> TFY {
        base.tintColor = tintColor
        return self
    }
}
