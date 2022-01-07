//
//  UIControl+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIControl {
    
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> TFY {
        base.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func isSelected(_ isSelected: Bool) -> TFY {
        base.isSelected = isSelected
        return self
    }
    
    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> TFY {
        base.isHighlighted = isHighlighted
        return self
    }
    
    @discardableResult
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> TFY {
        base.addTarget(target, action: action, for: controlEvents)
        return self
    }
}
