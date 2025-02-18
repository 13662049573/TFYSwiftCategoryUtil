//
//  UINavigationItem+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UINavigationItem {
    
    @discardableResult
    func title(_ title: String?) -> Self {
        base.title = title
        return self
    }
    
    @discardableResult
    func titleView(_ titleView: UIView?) -> Self {
        base.titleView = titleView
        return self
    }
    
    @discardableResult
    func leftBarButtonItem(_ leftBarButtonItem: UIBarButtonItem?) -> Self {
        base.leftBarButtonItem = leftBarButtonItem
        return self
    }
    
    @discardableResult
    func rightBarButtonItem(_ rightBarButtonItem: UIBarButtonItem?) -> Self {
        base.rightBarButtonItem = rightBarButtonItem
        return self
    }
    
    @discardableResult
    func leftBarButtonItems(_ leftBarButtonItems: [UIBarButtonItem]?) -> Self {
        base.leftBarButtonItems = leftBarButtonItems
        return self
    }
    
    @discardableResult
    func rightBarButtonItems(_ rightBarButtonItems: [UIBarButtonItem]?) -> Self {
        base.rightBarButtonItems = rightBarButtonItems
        return self
    }
}
