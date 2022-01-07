//
//  UISwitch+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/15.
//
import UIKit

public extension TFY where Base: UISwitch {
    
    @discardableResult
    func onTintColor(_ onTintColor: UIColor?) -> TFY {
        base.onTintColor = onTintColor
        return self
    }
    
    @discardableResult
    func thumbTintColor(_ thumbTintColor: UIColor?) -> TFY {
        base.thumbTintColor = thumbTintColor
        return self
    }
    
    @discardableResult
    func onImage(_ onImage: UIImage?) -> TFY {
        base.onImage = onImage
        return self
    }
    
    @discardableResult
    func offImage(_ offImage: UIImage?) -> TFY {
        base.offImage = offImage
        return self
    }
    
    @discardableResult
    func isOn(_ isOn: Bool) -> TFY {
        base.isOn = isOn
        return self
    }
}
