//
//  UIAlertController+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/22.
//

import Foundation
import UIKit

/// UIAlertController标题富文本key
public let kAlertTitle = "attributedTitle"
/// UIAlertController信息富文本key
public let kAlertMessage = "attributedMessage"
/// UIAlertController信息富文本key
public let kAlertContentViewController = "contentViewController"
/// UIAlertController按钮颜色key
public let kAlertActionColor = "titleTextColor"
/// UIAlertController按钮颜色image
public let kAlertActionImage = "image"
/// UIAlertController按钮颜色imageTintColor
public let kAlertActionImageTintColor = "imageTintColor"
/// UIAlertController按钮 checkmark
public let kAlertActionChecked = "checked"

public extension UIAlertController {
    @discardableResult
    static func tfy_init(title: String? = nil, message: String? = nil, style : UIAlertController.Style = .alert) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: style)
    }
    
    private var subView5: UIView? {
        guard let subView1: UIView = self.view.subviews.first,
              let subView2: UIView = subView1.subviews.first,
              let subView3: UIView = subView2.subviews.first,
              let subView4: UIView = subView3.subviews.first,
              let subView5: UIView = subView4.subviews.first
              else { return nil }
        return subView5
    }
    
    var titleLabel: UILabel? {
        guard let _ = self.title,
              let subView5 = subView5,
              subView5.subviews.count > 2,
              let label = subView5.subviews[1] as? UILabel
              else { return nil }
        return label
    }
    
    var messageLabel: UILabel? {
        guard let subView5 = subView5
              else { return nil }
        let messageLabelIndex = self.title == nil ? 1 : 2
        if subView5.subviews.count > messageLabelIndex,
           let label = subView5.subviews[messageLabelIndex] as? UILabel
           {
            return label
        }
        return nil
    }
    
    /// 创建系统sheetView
    static func createSheet(_ title: String?,
                            message: String? = nil,
                            items: [String]? = nil,
                            handler: ((UIAlertController, UIAlertAction) -> Void)? = nil) -> Self {
        let alertVC = self.init(title: title, message: message, preferredStyle: .actionSheet)
        
        items?.forEach({ (title) in
            let style: UIAlertAction.Style = title == "取消" ? .cancel : .default
            alertVC.addAction(UIAlertAction(title: title, style: style, handler: { (action) in
                alertVC.actions.forEach {
                    if action.title != "取消" {
                        let number = NSNumber(booleanLiteral: ($0 == action))
                        $0.setValue(number, forKey: kAlertActionChecked)
                    }
                }
                alertVC.dismiss(animated: true, completion: nil)
                handler?(alertVC, action)
            }))
        })
        return alertVC
    }
    
    /// 展示提示框
    static func showSheet(_ title: String?,
                          message: String? = nil,
                          items: [String]? = nil,
                          handler: ((UIAlertController, UIAlertAction) -> Void)? = nil) {
        UIAlertController.createSheet(title, message:message, items: items, handler: handler)
            .present()
    }

    
    /// [便利方法]提示信息
    static func showAlert(_ title: String? = "提示",
                          message: String?,
                          actionTitles: [String]? = ["确定"],
                          block: ((NSMutableParagraphStyle) -> Void)? = nil,
                          handler: ((UIAlertController, UIAlertAction) -> Void)? = nil){
        //富文本效果
        let paraStyle = NSMutableParagraphStyle()
            .tfy
            .lineBreakModeChain(.byCharWrapping)
            .lineSpacingChain(5)
            .alignmentChain(.center)
            .build
        block?(paraStyle)
        
        UIAlertController(title: title, message: message, preferredStyle: .alert)
            .addActionTitles(actionTitles, handler: handler)
            .setMessageParaStyle(paraStyle)
            .present()
    }
    
    /// [便利方法1]提示信息(兼容 OC)
    static func showAlert(_ title: String? = "提示", message: String?) {
        //富文本效果
        UIAlertController(title: title, message: message, preferredStyle: .alert)
            .addActionTitles(["确定"], handler: nil)
            .present()
    }

    ///根据 fmt 进行相隔时间展示
    static func canShow(_ interval: Int = Int(604800)) -> Bool {
        let nowTimestamp = Date().timeIntervalSince1970
        
        if let lastTimestamp = UserDefaults.standard.integer(forKey: "lastShowAlert") as Int?,
           (Int(nowTimestamp) - lastTimestamp) < Int(interval) {
            print("一个 fmt 只能提醒一次")
            return false
        }
        UserDefaults.standard.set(nowTimestamp, forKey: "lastShowAlert")
        UserDefaults.standard.synchronize()
        return true
    }
    
    ///添加多个 UIAlertAction
    @discardableResult
    func addActionTitles(_ titles: [String]? = ["取消","确定"], handler: ((UIAlertController, UIAlertAction) -> Void)? = nil) -> Self {
        titles?.forEach({ (string) in
            let style: UIAlertAction.Style = string == "取消" ? .cancel : .default
            self.addAction(UIAlertAction(title: string, style: style, handler: { (action) in
                handler?(self, action)
            }))
        })
        return self
    }
    ///添加多个 textField
    @discardableResult
    func addTextFieldPlaceholders(_ placeholders: [String]?, handler: ((UITextField) -> Void)? = nil) -> Self {
        if self.preferredStyle != .alert {
            return self
        }
        placeholders?.forEach({ (string) in
            self.addTextField { (textField: UITextField) in
                textField.placeholder = string
                handler?(textField)
            }
        })
        return self
    }
        
    /// 设置标题颜色
    @discardableResult
    func setTitleColor(_ color: UIColor = .white) -> Self {
        guard let title = title else {
            return self
        }
        
        let attrTitle = NSMutableAttributedString(string: title)
        attrTitle.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange(location: 0, length: title.count))
        setValue(attrTitle, forKey: kAlertTitle)
        return self
    }
    
    /// 设置Message文本换行,对齐方式
    @discardableResult
    func setMessageParaStyle(_ paraStyle: NSMutableParagraphStyle) -> Self {
        guard let message = message else {
            return self
        }

        let attrMsg = NSMutableAttributedString(string: message)
        let attDic = [NSAttributedString.Key.paragraphStyle: paraStyle,
                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),]
        attrMsg.addAttributes(attDic, range: NSRange(location: 0, length: message.count))
        setValue(attrMsg, forKey: kAlertMessage)
        return self
    }
    
    ///设置 Message 样式
    @discardableResult
    func setMessageStyle(_ font: UIFont,
                         textColor: UIColor,
                         alignment: NSTextAlignment = .left,
                         lineBreakMode: NSLineBreakMode = .byCharWrapping,
                         lineSpacing: CGFloat = 5.0) -> Self {
        let paraStyle = NSMutableParagraphStyle()
            .tfy
            .lineBreakModeChain(lineBreakMode)
            .lineSpacingChain(lineSpacing)
            .alignmentChain(alignment)
            .build
        
        return setMessageParaStyle(paraStyle)
    }
    
    @discardableResult
    func setContent(vc: UIViewController, height: CGFloat) -> Self {
        setValue(vc, forKey: kAlertContentViewController)
        vc.preferredContentSize.height = height
        preferredContentSize.height = height
        return self
    }
    
    /// 改变宽度
    @discardableResult
    func changeWidth(_ newWidth: CGFloat = UIScreen.main.bounds.width * 0.8) -> Self {
        if preferredStyle != .alert {
            return self
        }
        let widthConstraints = view.constraints.filter({ return $0.firstAttribute == .width})
        view.removeConstraints(widthConstraints)
        // Here you can enter any width that you want
//        let newWidth = UIScreen.main.bounds.width * 0.90
        // Adding constraint for alert base view
        let widthConstraint = NSLayoutConstraint(item: view as Any,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: newWidth)
        view.addConstraint(widthConstraint)
        let firstContainer = view.subviews[0]
        // Finding first child width constraint
        let constraint = firstContainer.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        firstContainer.removeConstraints(constraint)
        // And replacing with new constraint equal to view width constraint that we setup earlier
        view.addConstraint(NSLayoutConstraint(item: firstContainer,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .width,
                                                    multiplier: 1.0,
                                                    constant: 0))
        // Same for the second child with width constraint with 998 priority
        let innerBackground = firstContainer.subviews[0]
        let innerConstraints = innerBackground.constraints.filter({ return $0.firstAttribute == .width && $0.secondItem == nil })
        innerBackground.removeConstraints(innerConstraints)
        firstContainer.addConstraint(NSLayoutConstraint(item: innerBackground,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: firstContainer,
                                                        attribute: .width,
                                                        multiplier: 1.0,
                                                        constant: 0))
        return self
    }
}

public extension TFY where Base: UIAlertController {
    
    @discardableResult
    func show(_ vc:UIViewController?, block:(()->Void)? = nil) -> TFY {
        if base.title == nil && base.message == nil && base.actions.count == 0 {
            assertionFailure("👻💀大哥！你别什么东西都不放💀👻")
            return self
        }
        vc?.present(base, animated: true, completion: block)
        return self
    }
    
    @discardableResult
    func hidden(_ time:TimeInterval, block:(()->Void)? = nil) -> TFY {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) { [weak base] in
            base?.dismiss(animated: true, completion: block)
        }
        return self
    }
    
    @discardableResult
    func title(_ a:String) -> TFY {
        base.title = a
        return self
    }
    @discardableResult
    func title(_ font:UIFont) -> TFY {
        let attributed:NSAttributedString = base.value(forKey: kAlertTitle) as? NSAttributedString ?? NSMutableAttributedString(string: base.title ?? "")
        let attributedM = NSMutableAttributedString(attributedString: attributed)
        attributedM.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedM.length))
        base.setValue(attributedM, forKey: kAlertTitle)
        return self
    }
    @discardableResult
    func title(_ color:UIColor) -> TFY {
        let attributed:NSAttributedString = base.value(forKey: kAlertTitle) as? NSAttributedString ?? NSMutableAttributedString(string: base.title ?? "")
        let attributedM = NSMutableAttributedString(attributedString: attributed)
        attributedM.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, attributedM.length))
        base.setValue(attributedM, forKey: kAlertTitle)
        return self
    }
    @discardableResult
    func title(_ attributed:NSAttributedString) -> TFY {
        base.setValue(attributed, forKey: kAlertTitle)
        return self
    }
    @discardableResult
    func message(_ a:String) -> TFY {
        base.message = a
        return self
    }
    @discardableResult
    func message(_ font:UIFont) -> TFY {
        let attributed:NSAttributedString = base.value(forKey: kAlertMessage) as? NSAttributedString ?? NSMutableAttributedString(string: base.message ?? "")
        let attributedM = NSMutableAttributedString(attributedString: attributed)
        attributedM.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedM.length))
        base.setValue(attributedM, forKey: kAlertMessage)
        return self
    }
    @discardableResult
    func message(_ color:UIColor) -> TFY {
        let attributed:NSAttributedString = base.value(forKey: kAlertMessage) as? NSAttributedString ?? NSMutableAttributedString(string: base.message ?? "")
        let attributedM = NSMutableAttributedString(attributedString: attributed)
        attributedM.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, attributedM.length))
        base.setValue(attributedM, forKey: kAlertMessage)
        return self
    }
    @discardableResult
    func message(_ attributed:NSAttributedString) -> TFY {
        base.setValue(attributed, forKey: kAlertMessage)
        return self
    }
    
    @discardableResult
    func action(_ title:String,
                style:UIAlertAction.Style = .default,
                custom:((_ action:UIAlertAction) -> Void)? = nil,
                handler:((_ action:UIAlertAction) -> Void)?) -> TFY {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        custom?(action)
        base.addAction(action)
        return self
    }
}

public extension TFY where Base: UIAlertAction {
    @discardableResult
    func title(_ a:String) -> TFY {
        base.setValue(a, forKey: "title")
        return self
    }
    @discardableResult
    func titleColor(_ color:UIColor) -> TFY {
        base.setValue(color, forKey: kAlertActionColor)
        return self
    }
    @discardableResult
    func style(_ a:UIAlertAction.Style) -> TFY {
        base.setValue(a, forKey: "style")
        return self
    }
    @discardableResult
    func handler(_ a:((UIAlertAction) -> Void)? = nil) -> TFY {
        base.setValue(a, forKey: "handler")
        return self
    }
}


