//
//  UIStepper+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIStepper {
    
    @discardableResult
    func isContinuous(_ isContinuous: Bool) -> Self {
        base.isContinuous = isContinuous
        return self
    }
    
    @discardableResult
    func autorepeat(_ autorepeat: Bool) -> Self {
        base.autorepeat = autorepeat
        return self
    }
    
    @discardableResult
    func wraps(_ wraps: Bool) -> Self {
        base.wraps = wraps
        return self
    }
    
    @discardableResult
    func value(_ value: Double) -> Self {
        base.value = value
        return self
    }
    
    @discardableResult
    func minimumValue(_ minimumValue: Double) -> Self {
        base.minimumValue = minimumValue
        return self
    }
    
    @discardableResult
    func maximumValue(_ maximumValue: Double) -> Self {
        base.maximumValue = maximumValue
        return self
    }
    
    @discardableResult
    func stepValue(_ stepValue: Double) -> Self {
        base.stepValue = stepValue
        return self
    }
    
    @discardableResult
    func backgroundImage(_ image: UIImage?, for state: UIControl.State...) -> Self {
        state.forEach { base.setBackgroundImage(image, for: $0) }
        return self
    }
    
    @discardableResult
    func dividerImage(_ image: UIImage?,
                      forLeftSegmentState leftState: UIControl.State,
                      rightSegmentState rightState: UIControl.State) -> Self {
        base.setDividerImage(image, forLeftSegmentState: leftState, rightSegmentState: rightState)
        return self
    }
    
    @discardableResult
    func incrementImage(_ image: UIImage?, for state: UIControl.State) -> Self {
        base.setIncrementImage(image, for: state)
        return self
    }
    
    @discardableResult
    func decrementImage(_ image: UIImage?, for state: UIControl.State) -> Self {
        base.setDecrementImage(image, for: state)
        return self
    }
}
