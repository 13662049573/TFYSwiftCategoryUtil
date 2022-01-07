//
//  UIBarItem+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/8.
//
import UIKit

public extension TFY where Base: UIBarItem {
    
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> TFY {
        base.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func titleTextAttributes(_ titleTextAttributes: [NSAttributedString.Key: Any]?,
                             for state: UIControl.State...) -> TFY {
        state.forEach { base.setTitleTextAttributes(titleTextAttributes, for: $0) }
        return self
    }
}
