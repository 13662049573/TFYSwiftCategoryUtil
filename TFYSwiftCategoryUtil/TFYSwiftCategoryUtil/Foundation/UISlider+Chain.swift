//
//  UISlider+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UISlider {
    
    @discardableResult
    func value(_ value: Float) -> Self {
        base.value = value
        return self
    }
    
    @discardableResult
    func minimumValue(_ minimumValue: Float) -> Self {
        base.minimumValue = minimumValue
        return self
    }
    
    @discardableResult
    func maximumValue(_ maximumValue: Float) -> Self {
        base.maximumValue = maximumValue
        return self
    }
    
    @discardableResult
    func minimumValueImage(_ minimumValueImage: UIImage?) -> Self {
        base.minimumValueImage = minimumValueImage
        return self
    }
    
    @discardableResult
    func maximumValueImage(_ maximumValueImage: UIImage?) -> Self {
        base.maximumValueImage = maximumValueImage
        return self
    }
    
    @discardableResult
    func isContinuous(_ isContinuous: Bool) -> Self {
        base.isContinuous = isContinuous
        return self
    }
    
    @discardableResult
    func minimumTrackTintColor(_ minimumTrackTintColor: UIColor?) -> Self {
        base.minimumTrackTintColor = minimumTrackTintColor
        return self
    }
    
    @discardableResult
    func maximumTrackTintColor(_ maximumTrackTintColor: UIColor?) -> Self {
        base.maximumTrackTintColor = maximumTrackTintColor
        return self
    }
    
    @discardableResult
    func thumbTintColor(_ thumbTintColor: UIColor?) -> Self {
        base.thumbTintColor = thumbTintColor
        return self
    }
}
