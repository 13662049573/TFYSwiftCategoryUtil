//
//  UIProgressView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIProgressView {
    
    @discardableResult
    func progress(_ progress: Float) -> Self {
        base.progress = progress
        return self
    }
    
    @discardableResult
    func progressViewStyle(_ progressViewStyle: UIProgressView.Style) -> Self {
        base.progressViewStyle = progressViewStyle
        return self
    }
    
    @discardableResult
    func progressTintColor(_ progressTintColor: UIColor?) -> Self {
        base.progressTintColor = progressTintColor
        return self
    }
    
    @discardableResult
    func trackTintColor(_ trackTintColor: UIColor?) -> Self {
        base.trackTintColor = trackTintColor
        return self
    }
    
    @discardableResult
    func progressImage(_ progressImage: UIImage?) -> Self {
        base.progressImage = progressImage
        return self
    }
    
    @discardableResult
    func trackImage(_ trackImage: UIImage?) -> Self {
        base.trackImage = trackImage
        return self
    }
}
