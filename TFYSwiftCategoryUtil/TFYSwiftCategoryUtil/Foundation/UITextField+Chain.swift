//
//  UITextField+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit
import ObjectiveC

public extension TFY where Base: UITextField {
    
    @discardableResult
    func delegate(_ delegate: UITextFieldDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func placeholder(_ placeholder: String?) -> Self {
        base.placeholder = placeholder
        return self
    }
    
    @discardableResult
    func attributedPlaceholder(_ attributedPlaceholder: NSAttributedString?) -> Self {
        base.attributedPlaceholder = attributedPlaceholder
        return self
    }
    
    @discardableResult
    func borderStyle(_ borderStyle: UITextField.BorderStyle) -> Self {
        base.borderStyle = borderStyle
        return self
    }
    
    @discardableResult
    func defaultTextAttributes(_ defaultTextAttributes: [String: Any]) -> Self {
        #if swift(>=4.2)
        base.defaultTextAttributes = convertToNSAttributedStringKeyDictionary(defaultTextAttributes)
        #else
        base.defaultTextAttributes = defaultTextAttributes
        #endif
        return self
    }
    
    @discardableResult
    func clearsOnBeginEditing(_ clearsOnBeginEditing: Bool) -> Self {
        base.clearsOnBeginEditing = clearsOnBeginEditing
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
        base.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
    
    @discardableResult
    func minimumFontSize(_ minimumFontSize: CGFloat) -> Self {
        base.minimumFontSize = minimumFontSize
        return self
    }
    
    @discardableResult
    func allowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> Self {
        base.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func typingAttributes(_ typingAttributes: [String: Any]?) -> Self {
        #if swift(>=4.2)
        base.typingAttributes = convertToOptionalNSAttributedStringKeyDictionary(typingAttributes)
        #else
        base.typingAttributes = typingAttributes
        #endif
        return self
    }
    
    @discardableResult
    func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> Self {
        base.clearButtonMode = clearButtonMode
        return self
    }
    
    @discardableResult
    func leftView(_ leftView: UIView?) -> Self {
        base.leftView = leftView
        return self
    }
    
    @discardableResult
    func leftViewMode(_ leftViewMode: UITextField.ViewMode) -> Self {
        base.leftViewMode = leftViewMode
        return self
    }
    
    @discardableResult
    func rightView(_ rightView: UIView?) -> Self {
        base.rightView = rightView
        return self
    }
    
    @discardableResult
    func rightViewMode(_ rightViewMode: UITextField.ViewMode) -> Self {
        base.rightViewMode = rightViewMode
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
    func isSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        base.isSecureTextEntry = isSecureTextEntry
        return self
    }
    
    @discardableResult
    func textContentType(_ textContentType: UITextContentType) -> Self {
        if #available(iOS 10.0, *) {
            base.textContentType = textContentType
        }
        return self
    }
    
    @discardableResult
    func placeHolderColor(_ placeHolderColor: UIColor) -> Self {
        base.placeHolderColor = placeHolderColor
        return self
    }
    
    @discardableResult
    func textPadding(_ insets: UIEdgeInsets) -> Self {
        base.textPadding = insets
        return self
    }
}

extension UITextField {
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

private var textPaddingKey: UInt8 = 8

extension UITextField {
    // 添加内边距支持
    var textPadding: UIEdgeInsets {
        get {
            objc_getAssociatedObject(self, &textPaddingKey) as? UIEdgeInsets ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &textPaddingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            swizzleMethodsIfNeeded()
        }
    }
    
    private static var swizzled = false
    private func swizzleMethodsIfNeeded() {
        guard !Self.swizzled else { return }
        
        let originalSelectors = [
            #selector(textRect(forBounds:)),
            #selector(editingRect(forBounds:)),
            #selector(placeholderRect(forBounds:))
        ]
        
        let swizzledSelectors = [
            #selector(swizzled_textRect(forBounds:)),
            #selector(swizzled_editingRect(forBounds:)),
            #selector(swizzled_placeholderRect(forBounds:))
        ]
        
        for (original, swizzled) in zip(originalSelectors, swizzledSelectors) {
            let originalMethod = class_getInstanceMethod(Self.self, original)!
            let swizzledMethod = class_getInstanceMethod(Self.self, swizzled)!
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        Self.swizzled = true
    }
    
    @objc private func swizzled_textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    @objc private func swizzled_editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    @objc private func swizzled_placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any])
    -> [NSAttributedString.Key: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in
        (NSAttributedString.Key(rawValue: key), value)
    })
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in
        (NSAttributedString.Key(rawValue: key), value)
    })
}
