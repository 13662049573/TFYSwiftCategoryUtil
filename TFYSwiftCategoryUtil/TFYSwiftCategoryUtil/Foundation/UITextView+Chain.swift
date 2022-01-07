//
//  UITextView+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/8.
//
import UIKit

public extension TFY where Base: UITextView {
    
    @discardableResult
    func delegate(_ delegate: UITextViewDelegate?) -> TFY {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func isEditable(_ isEditable: Bool) -> TFY {
        base.isEditable = isEditable
        return self
    }
    
    @discardableResult
    func isSelectable(_ isSelectable: Bool) -> TFY {
        base.isSelectable = isSelectable
        return self
    }
    
    @discardableResult
    func textContainerInset(_ textContainerInset: UIEdgeInsets) -> TFY {
        base.textContainerInset = textContainerInset
        return self
    }
    
    @discardableResult
    func dataDetectorTypes(_ dataDetectorTypes: UIDataDetectorTypes) -> TFY {
        base.dataDetectorTypes = dataDetectorTypes
        return self
    }
    
    @discardableResult
    func allowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> TFY {
        base.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func keyboardType(_ keyboardType: UIKeyboardType) -> TFY {
        base.keyboardType = keyboardType
        return self
    }
    
    @discardableResult
    func returnKeyType(_ returnKeyType: UIReturnKeyType) -> TFY {
        base.returnKeyType = returnKeyType
        return self
    }
}
