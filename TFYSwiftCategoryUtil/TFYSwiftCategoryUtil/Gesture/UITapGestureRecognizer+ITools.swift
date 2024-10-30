//
//  UITapGestureRecognizer+ITools.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import Foundation
import UIKit

public extension TFY where Base == UITapGestureRecognizer {
    
    /// 手势识别器的委托
    @discardableResult
    func delegate(_ delegate: UIGestureRecognizerDelegate?) -> TFY {
        base.delegate = delegate
        return self
    }
    
    /// 默认是肯定的。禁用的手势识别器将无法接收触摸。当更改为NO时，手势识别器将被取消，如果它目前正在识别一个手势
    @discardableResult
    func enabled(_ enabled: Bool) -> TFY {
        base.isEnabled = enabled
        return self
    }
    
    /// 默认是肯定的。导致touchesCancelled:withEvent:或pressesCancelled:withEvent:在动作方法被调用之前被发送到视图中作为这个手势的一部分的所有触摸或按下。
    @discardableResult
    func cancelsTouchesInView(_ cancels: Bool) -> TFY {
        base.cancelsTouchesInView = cancels
        return self
    }

    /// 默认是否定的。只有在此手势无法识别后，才将所有触摸或按下事件发送到目标视图。设置为YES以防止视图处理任何可能被识别为此手势一部分的触摸或按下
    @discardableResult
    func delaysTouchesBegan(_ delayeBegan: Bool) -> TFY {
        base.delaysTouchesBegan = delayeBegan
        return self
    }
    
    /// 默认是肯定的。导致touchesEnded或pressesEnded事件只有在此手势无法识别后才被交付到目标视图。这确保了作为手势一部分的触摸或按下可以在手势被识别后取消
    @discardableResult
    func delaysTouchesEnded(_ delayeEnded: Bool) -> TFY {
        base.delaysTouchesEnded = delayeEnded
        return self
    }

    /// 作为nsnumber的UITouchTypes数组。
    @discardableResult
    func allowedTouchTypes(_ types: [NSNumber]) -> TFY {
        base.allowedTouchTypes = types
        return self
    }
    
    /// 作为nsnumber的uipresstype数组。
    @discardableResult
    func allowedPressTypes(_ types: [NSNumber]) -> TFY {
        base.allowedPressTypes = types
        return self
    }

    /// 默认值为YES
    @discardableResult
    func requiresExclusiveTouchType(_ requirs: Bool) -> TFY {
        base.requiresExclusiveTouchType = requirs
        return self
    }

    /// 要在日志中显示的调试名称
    @discardableResult
    func name(_ name: String?) -> TFY {
        base.name = name
        return self
    }

    /// 示例用法:一次点击可能需要双击才会失败
    @discardableResult
    func require(_ fail:UIGestureRecognizer) -> TFY {
        base.require(toFail: fail)
        return self
    }
    
    /// 添加一个目标/操作对。您可以多次调用此函数来指定多个目标/操作
    @discardableResult
    func addTarget(_ target: Any,action: Selector) -> TFY {
        base.addTarget(target, action: action)
        return self
    }

    /// 删除指定的目标/操作对。为目标传递nil匹配所有目标，对操作也是如此
    @discardableResult
    func removeTarget(_ target: Any?, action: Selector?) -> TFY {
        base.removeTarget(target, action: action)
        return self
    }
    
    /// 默认值为1。匹配所需的轻拍次数
    @discardableResult
    func numberOfTapsRequired(_ number: Int) -> TFY {
        base.numberOfTapsRequired = number
        return self
    }
    
    /// 默认值为1。手指的数量需要匹配
    @discardableResult
    func numberOfTouchesRequired(_ number: Int) -> TFY {
        base.numberOfTouchesRequired = number
        return self
    }

    /// 默认是UIEventButtonMaskPrimary，不能为0。此属性仅在间接输入设备上计算，并且是所需匹配的按下按钮的掩码。
    @available(iOS 13.4, *)
    @discardableResult
    func buttonMaskRequired(_ mask: UIEvent.ButtonMask) -> TFY {
        base.buttonMaskRequired = mask
        return self
    }
}

@objc public extension UIGestureRecognizer{
    private struct AssociateKeys {
        static var funcName   = "UIGestureRecognizer" + "funcName"
        static var closure    = "UIGestureRecognizer" + "closure"
    }
    
    /// 方法名称(用于自定义)
    var funcName: String {
        get {
            if let obj = objc_getAssociatedObject(self,(AssociateKeys.funcName)) as? String {
                return obj
            }
 
            let string = String(describing: self.classForCoder)
            objc_setAssociatedObject(self,(AssociateKeys.funcName), string, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return string
        }
        set {
            objc_setAssociatedObject(self,(AssociateKeys.funcName), newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 闭包回调
    func addAction(_ closure: @escaping (UIGestureRecognizer) -> Void) {
        objc_setAssociatedObject(self, (AssociateKeys.closure), closure, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        addTarget(self, action: #selector(p_invoke))
    }
    
    private func p_invoke() {
        if let closure = objc_getAssociatedObject(self,(AssociateKeys.closure)) as? ((UIGestureRecognizer) -> Void) {
            closure(self)
        }
    }
    
}

@objc public extension UITapGestureRecognizer {
    
    private struct AssociateKeys {
        static var closure    = "UITapGestureRecognizer" + "closure"
    }
    
    /// 闭包回调
    override func addAction(_ closure: @escaping (UITapGestureRecognizer) -> Void) {
        objc_setAssociatedObject(self, (AssociateKeys.closure), closure, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        addTarget(self, action: #selector(p_invokeTap))
    }
    
    private func p_invokeTap() {
        if let closure = objc_getAssociatedObject(self,(AssociateKeys.closure)) as? ((UIGestureRecognizer) -> Void) {
            closure(self)
        }
    }
    
    /// UILabel 富文本点击(仅支持 lineBreakMode = .byWordWrapping)
    func didTapLabelAttributedText(_ linkDic: [String: String], action: @escaping (String, String?) -> Void) {
        assert(((self.view as? UILabel) != nil), "Only supports UILabel")
        
        guard let label = self.view as? UILabel,
              let attributedText = label.attributedText
              else { return }
                
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines

        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width)*0.5 - textBoundingBox.origin.x,
                                        y:(labelSize.height - textBoundingBox.size.height)*0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                   y: locationOfTouchInLabel.y - textContainerOffset.y)

        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)
        //
        linkDic.forEach { e in
            let targetRange: NSRange = (attributedText.string as NSString).range(of: e.key)
            let isContain = NSLocationInRange(indexOfCharacter, targetRange)
            if isContain {
                action(e.key, e.value)
            }
        }
    }
}
