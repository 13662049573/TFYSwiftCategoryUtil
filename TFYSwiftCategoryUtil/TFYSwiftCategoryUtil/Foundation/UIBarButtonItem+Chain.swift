//
//  UIBarButtonItem+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit
import Foundation

public extension TFY where Base: UIBarButtonItem {
    
    @discardableResult
    func width(_ width: CGFloat) -> TFY {
        base.width = width
        return self
    }
    
    @discardableResult
    func tintColor(_ tintColor: UIColor?) -> TFY {
        base.tintColor = tintColor
        return self
    }
}

@objc public extension UIBarButtonItem {
    
    private struct AssociateKeys {
        static var systemType = "UIBarButtonItem" + "systemType"
        static var closure = "UIBarButtonItem" + "closure"
    }
    
    var systemType: UIBarButtonItem.SystemItem {
        get {
            if let obj = objc_getAssociatedObject(self, (AssociateKeys.systemType)) as? UIBarButtonItem.SystemItem {
                return obj
            }
            return .done
        }
        set {
            objc_setAssociatedObject(self,(AssociateKeys.systemType), newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// UIBarButtonItem 回调
    func addAction(_ closure: @escaping ((UIBarButtonItem) -> Void)) {
        objc_setAssociatedObject(self,(AssociateKeys.closure), closure, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        target = self
        action = #selector(p_invoke)
    }

    private func p_invoke() {
        if let closure = objc_getAssociatedObject(self,(AssociateKeys.closure)) as? ((UIBarButtonItem) -> Void) {
            closure(self)
        }
    }
    
    convenience init(obj: String, style: UIBarButtonItem.Style = .plain, tag: Int = 0, target: Any? = nil, action: Selector? = nil) {
        if let image = UIImage(named: obj) {
            self.init(image: image, style: style, target: target, action: action)
        } else {
            self.init(title: obj, style: style, target: target, action: action)
        }
        self.tag = tag
    }
    
    convenience init(obj: String, style: UIBarButtonItem.Style = .plain, tag: Int = 0, action: @escaping ((UIBarButtonItem) -> Void)) {
        self.init(obj: obj, style: style, tag: tag, target: nil, action: nil)
        self.addAction(action)
    }
    
    convenience init(systemItem: UIBarButtonItem.SystemItem, tag: Int = 0, action: @escaping ((UIBarButtonItem) -> Void)) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        self.tag = tag
        self.systemType = systemItem
        self.addAction(action)
    }
    
    func addTargetForAction(_ target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
    
    @discardableResult
    func setTitleColor(_ textColor: UIColor, for state: UIControl.State) -> Self {
        guard var attributes = titleTextAttributes(for: state) else {
            setTitleTextAttributes([NSAttributedString.Key.foregroundColor: textColor], for: state)
            return self }
        attributes[.foregroundColor] = textColor
        setTitleTextAttributes(attributes, for: state)
        return self
    }
    
    @discardableResult
    func setTitleFont(_ font: UIFont, for state: UIControl.State) -> Self {
        guard var attributes = titleTextAttributes(for: state) else {
            setTitleTextAttributes([NSAttributedString.Key.font: font], for: state)
            return self }
        attributes[.font] = font
        setTitleTextAttributes(attributes, for: state)
        return self
    }

    /// Creates a fixed space UIBarButtonItem with a specific width.
    static func fixedSpace(width: CGFloat, target: Any? = nil, action: Selector? = nil) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: target, action: action)
        barButtonItem.width = width
        return barButtonItem
    }
    
    /// Creates a flexibleSpace space UIBarButtonItem with a specific width.
    static func flexibleSpace(_ target: Any? = nil, action: Selector? = nil) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: target, action: action)
    }
}

public extension UIBarButtonItem{
    
    static func space(_ width: CGFloat? = nil, target: Any? = nil, action: Selector? = nil) -> UIBarButtonItem {
        if let width = width {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            barButtonItem.width = width
            return barButtonItem
        }
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}
