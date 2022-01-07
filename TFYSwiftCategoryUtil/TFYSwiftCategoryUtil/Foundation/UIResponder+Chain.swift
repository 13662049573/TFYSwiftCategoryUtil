//
//  UIResponder+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIResponder {
    
    @discardableResult
    func becomeFirstResponder() -> TFY {
        base.becomeFirstResponder()
        return self
    }
    
    @discardableResult
    func resignFirstResponder() -> TFY {
        base.resignFirstResponder()
        return self
    }
}
