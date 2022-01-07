//
//  UIActivityIndicatorView+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/8.
//
import UIKit

public extension TFY where Base: UIActivityIndicatorView {
    
    @discardableResult
    func activityIndicatorViewStyle(_ activityIndicatorViewStyle: UIActivityIndicatorView.Style) -> TFY {
        #if swift(>=4.2)
        base.style = activityIndicatorViewStyle
        #else
        base.activityIndicatorViewStyle = activityIndicatorViewStyle
        #endif
        return self
    }
    
    @discardableResult
    func hidesWhenStopped(_ hidesWhenStopped: Bool) -> TFY {
        base.hidesWhenStopped = hidesWhenStopped
        return self
    }
    
    @discardableResult
    func color(_ color: UIColor?) -> TFY {
        base.color = color
        return self
    }
}
