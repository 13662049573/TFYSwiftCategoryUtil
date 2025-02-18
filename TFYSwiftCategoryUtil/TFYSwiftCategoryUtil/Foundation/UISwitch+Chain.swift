//
//  UISwitch+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UISwitch {
    
    @discardableResult
    func onTintColor(_ onTintColor: UIColor?) -> Self {
        base.onTintColor = onTintColor
        return self
    }
    
    @discardableResult
    func thumbTintColor(_ thumbTintColor: UIColor?) -> Self {
        base.thumbTintColor = thumbTintColor
        return self
    }
    
    @discardableResult
    func onImage(_ onImage: UIImage?) -> Self {
        base.onImage = onImage
        return self
    }
    
    @discardableResult
    func offImage(_ offImage: UIImage?) -> Self {
        base.offImage = offImage
        return self
    }
    
    @discardableResult
    func isOn(_ isOn: Bool) -> Self {
        base.isOn = isOn
        return self
    }
    
    @discardableResult
    func tintColor(_ color:UIColor) -> Self {
        base.tintColor = color
        return self
    }
}
