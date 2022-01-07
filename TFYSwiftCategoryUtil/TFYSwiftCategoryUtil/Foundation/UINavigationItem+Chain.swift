//
//  UINavigationItem+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/9.
//
import UIKit

public extension TFY where Base: UINavigationItem {
    
    @discardableResult
    func title(_ title: String?) -> TFY {
        base.title = title
        return self
    }
    
    @discardableResult
    func titleView(_ titleView: UIView?) -> TFY {
        base.titleView = titleView
        return self
    }
    
    @discardableResult
    func leftBarButtonItem(_ leftBarButtonItem: UIBarButtonItem?) -> TFY {
        base.leftBarButtonItem = leftBarButtonItem
        return self
    }
    
    @discardableResult
    func rightBarButtonItem(_ rightBarButtonItem: UIBarButtonItem?) -> TFY {
        base.rightBarButtonItem = rightBarButtonItem
        return self
    }
    
    @discardableResult
    func leftBarButtonItems(_ leftBarButtonItems: [UIBarButtonItem]?) -> TFY {
        base.leftBarButtonItems = leftBarButtonItems
        return self
    }
    
    @discardableResult
    func rightBarButtonItems(_ rightBarButtonItems: [UIBarButtonItem]?) -> TFY {
        base.rightBarButtonItems = rightBarButtonItems
        return self
    }
}
