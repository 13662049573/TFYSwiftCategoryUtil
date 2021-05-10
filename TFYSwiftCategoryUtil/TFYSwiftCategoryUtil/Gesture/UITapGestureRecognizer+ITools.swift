//
//  UITapGestureRecognizer+ITools.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import Foundation
import UIKit

extension TFY where Base == UITapGestureRecognizer {
    
    /// 手势识别器的委托
    @discardableResult
    func delegate(_ delegate: UIGestureRecognizerDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    /// 默认是肯定的。禁用的手势识别器将无法接收触摸。当更改为NO时，手势识别器将被取消，如果它目前正在识别一个手势
    @discardableResult
    func enabled(_ enabled: Bool) -> Self {
        base.isEnabled = enabled
        return self
    }
    
    /// 默认是肯定的。导致touchesCancelled:withEvent:或pressesCancelled:withEvent:在动作方法被调用之前被发送到视图中作为这个手势的一部分的所有触摸或按下。
    @discardableResult
    func cancelsTouchesInView(_ cancels: Bool) -> Self {
        base.cancelsTouchesInView = cancels
        return self
    }

    /// 默认是否定的。只有在此手势无法识别后，才将所有触摸或按下事件发送到目标视图。设置为YES以防止视图处理任何可能被识别为此手势一部分的触摸或按下
    @discardableResult
    func delaysTouchesBegan(_ delayeBegan: Bool) -> Self {
        base.delaysTouchesBegan = delayeBegan
        return self
    }
    
    /// 默认是肯定的。导致touchesEnded或pressesEnded事件只有在此手势无法识别后才被交付到目标视图。这确保了作为手势一部分的触摸或按下可以在手势被识别后取消
    @discardableResult
    func delaysTouchesEnded(_ delayeEnded: Bool) -> Self {
        base.delaysTouchesEnded = delayeEnded
        return self
    }

    /// 作为nsnumber的UITouchTypes数组。
    @discardableResult
    func allowedTouchTypes(_ types: [NSNumber]) -> Self {
        base.allowedTouchTypes = types
        return self
    }
    
    /// 作为nsnumber的uipresstype数组。
    @discardableResult
    func allowedPressTypes(_ types: [NSNumber]) -> Self {
        base.allowedPressTypes = types
        return self
    }

    /// 默认值为YES
    @discardableResult
    func requiresExclusiveTouchType(_ requirs: Bool) -> Self {
        base.requiresExclusiveTouchType = requirs
        return self
    }

    /// 要在日志中显示的调试名称
    @discardableResult
    func name(_ name: String?) -> Self {
        base.name = name
        return self
    }

    /// 示例用法:一次点击可能需要双击才会失败
    @discardableResult
    func require(_ fail:UIGestureRecognizer) -> Self {
        base.require(toFail: fail)
        return self
    }
    
    /// 添加一个目标/操作对。您可以多次调用此函数来指定多个目标/操作
    @discardableResult
    func addTarget(_ target: Any,action: Selector) -> Self {
        base.addTarget(target, action: action)
        return self
    }

    /// 删除指定的目标/操作对。为目标传递nil匹配所有目标，对操作也是如此
    @discardableResult
    func removeTarget(_ target: Any?, action: Selector?) -> Self {
        base.removeTarget(target, action: action)
        return self
    }
    
    /// 默认值为1。匹配所需的轻拍次数
    @discardableResult
    func numberOfTapsRequired(_ number: Int) -> Self {
        base.numberOfTapsRequired = number
        return self
    }
    
    /// 默认值为1。手指的数量需要匹配
    @discardableResult
    func numberOfTouchesRequired(_ number: Int) -> Self {
        base.numberOfTouchesRequired = number
        return self
    }

    /// 默认是UIEventButtonMaskPrimary，不能为0。此属性仅在间接输入设备上计算，并且是所需匹配的按下按钮的掩码。
    @available(iOS 13.4, *)
    @discardableResult
    func buttonMaskRequired(_ mask: UIEvent.ButtonMask) -> Self {
        base.buttonMaskRequired = mask
        return self
    }
}
