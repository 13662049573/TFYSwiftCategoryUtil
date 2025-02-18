//
//  UITextView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UITextView {
    
    @discardableResult
    func delegate(_ delegate: UITextViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func isEditable(_ isEditable: Bool) -> Self {
        base.isEditable = isEditable
        return self
    }
    
    @discardableResult
    func isSelectable(_ isSelectable: Bool) -> Self {
        base.isSelectable = isSelectable
        return self
    }
    
    @discardableResult
    func textContainerInset(_ textContainerInset: UIEdgeInsets) -> Self {
        base.textContainerInset = textContainerInset
        return self
    }
    
    @discardableResult
    func dataDetectorTypes(_ dataDetectorTypes: UIDataDetectorTypes) -> Self {
        base.dataDetectorTypes = dataDetectorTypes
        return self
    }
    
    @discardableResult
    func allowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> Self {
        base.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        base.keyboardType = keyboardType
        return self
    }
    
    @discardableResult
    func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        base.returnKeyType = returnKeyType
        return self
    }
    
    @discardableResult
    func typingAttributes(attributes b:[NSAttributedString.Key : Any]) -> Self {
        base.typingAttributes = b
        return self
    }
    
    @discardableResult
    func textContainerInset(containerInset c: UIEdgeInsets) -> Self {
        base.textContainerInset = c
        return self
    }
    
    @discardableResult
    func dataDetectorTypes(detectorTypes d: UIDataDetectorTypes) -> Self {
        base.dataDetectorTypes = d
        return self
    }
    
    @discardableResult
    func textPadding(insets d: UIEdgeInsets) -> Self {
        base.textPadding = d
        return self
    }
    
    @discardableResult
    func horizontalPadding(padding d: CGFloat) -> Self {
        base.horizontalPadding = d
        return self
    }
    
    @discardableResult
    func verticalPadding(padding d: CGFloat) -> Self {
        base.verticalPadding = d
        return self
    }
}

private var textPaddingKey: UInt8 = 10

extension UITextView {
    /// 自定义文本内边距（兼容左右布局）
    var textPadding: UIEdgeInsets {
        get {
            objc_getAssociatedObject(self, &textPaddingKey) as? UIEdgeInsets ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &textPaddingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updateTextPadding()
        }
    }
    
    private func updateTextPadding() {
        // 组合处理文本容器的边距
        textContainerInset = UIEdgeInsets(
            top: textPadding.top,
            left: textPadding.left - textContainer.lineFragmentPadding,
            bottom: textPadding.bottom,
            right: textPadding.right - textContainer.lineFragmentPadding
        )
        textContainer.lineFragmentPadding = 0
    }
    
    /// 快捷设置左右边距
    @IBInspectable var horizontalPadding: CGFloat {
        get { textPadding.left }
        set { textPadding = UIEdgeInsets(top: textPadding.top, left: newValue, bottom: textPadding.bottom, right: newValue) }
    }
    
    /// 快捷设置上下边距
    @IBInspectable var verticalPadding: CGFloat {
        get { textPadding.top }
        set { textPadding = UIEdgeInsets(top: newValue, left: textPadding.left, bottom: newValue, right: textPadding.right) }
    }
}
