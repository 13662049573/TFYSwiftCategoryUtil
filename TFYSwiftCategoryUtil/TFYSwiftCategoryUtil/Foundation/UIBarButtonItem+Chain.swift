//
//  UIBarButtonItem+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit
import Foundation

public extension TFY where Base: UIBarButtonItem {
    
    @discardableResult
    func width(_ width: CGFloat) -> Self {
        base.width = width
        return self
    }
    
    @discardableResult
    func tintColor(_ tintColor: UIColor?) -> Self {
        base.tintColor = tintColor
        return self
    }
}
