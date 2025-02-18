//
//  UIActivityIndicatorView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIActivityIndicatorView {
    
    @discardableResult
    func activityIndicatorViewStyle(_ activityIndicatorViewStyle: UIActivityIndicatorView.Style) -> Self {
        #if swift(>=4.2)
        base.style = activityIndicatorViewStyle
        #else
        base.activityIndicatorViewStyle = activityIndicatorViewStyle
        #endif
        return self
    }
    
    @discardableResult
    func hidesWhenStopped(_ hidesWhenStopped: Bool) -> Self {
        base.hidesWhenStopped = hidesWhenStopped
        return self
    }
    
    @discardableResult
    func color(_ color: UIColor?) -> Self {
        base.color = color
        return self
    }
}
