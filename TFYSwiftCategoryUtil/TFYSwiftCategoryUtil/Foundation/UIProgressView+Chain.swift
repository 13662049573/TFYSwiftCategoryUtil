//
//  UIProgressView+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/9.
//
import UIKit

public extension TFY where Base: UIProgressView {
    
    @discardableResult
    func progress(_ progress: Float) -> TFY {
        base.progress = progress
        return self
    }
    
    @discardableResult
    func progressViewStyle(_ progressViewStyle: UIProgressView.Style) -> TFY {
        base.progressViewStyle = progressViewStyle
        return self
    }
    
    @discardableResult
    func progressTintColor(_ progressTintColor: UIColor?) -> TFY {
        base.progressTintColor = progressTintColor
        return self
    }
    
    @discardableResult
    func trackTintColor(_ trackTintColor: UIColor?) -> TFY {
        base.trackTintColor = trackTintColor
        return self
    }
    
    @discardableResult
    func progressImage(_ progressImage: UIImage?) -> TFY {
        base.progressImage = progressImage
        return self
    }
    
    @discardableResult
    func trackImage(_ trackImage: UIImage?) -> TFY {
        base.trackImage = trackImage
        return self
    }
}
