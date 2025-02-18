//
//  HasText.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

// MARK: - 文本处理协议
public protocol HasText {
    /// 设置文本
    func set(text: String?)
    /// 设置富文本
    func set(attributedText: NSAttributedString?)
    /// 设置文本颜色
    func set(color: UIColor)
    /// 设置文本对齐方式
    func set(alignment: NSTextAlignment)
    /// 设置行数
    func set(numberOfLines: Int)
    /// 设置行间距
    func set(lineSpacing: CGFloat)
    /// 设置字间距
    func set(kern: CGFloat)
    /// 设置占位符
    func set(placeholder: String?)
}

// MARK: - UILabel扩展
extension UILabel: HasText {
    public func set(text: String?) {
        self.text = text
    }
    
    public func set(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }
    
    public func set(color: UIColor) {
        self.textColor = color
    }
    
    public func set(alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }
    
    public func set(numberOfLines: Int) {
        self.numberOfLines = numberOfLines
    }
    
    public func set(lineSpacing: CGFloat) {
        guard let text = self.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributedString = NSAttributedString(string: text, attributes: [
            .paragraphStyle: paragraphStyle
        ])
        self.attributedText = attributedString
    }
    
    public func set(kern: CGFloat) {
        guard let text = self.text else { return }
        let attributedString = NSAttributedString(string: text, attributes: [
            .kern: kern
        ])
        self.attributedText = attributedString
    }
    
    public func set(placeholder: String?) {
        // UILabel 不支持占位符
    }
}

// MARK: - UITextField扩展
extension UITextField: HasText {
    public func set(text: String?) {
        self.text = text
    }
    
    public func set(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }
    
    public func set(color: UIColor) {
        self.textColor = color
    }
    
    public func set(alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }
    
    public func set(numberOfLines: Int) {
        // UITextField 不支持多行
    }
    
    public func set(lineSpacing: CGFloat) {
        guard let text = self.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributedString = NSAttributedString(string: text, attributes: [
            .paragraphStyle: paragraphStyle
        ])
        self.attributedText = attributedString
    }
    
    public func set(kern: CGFloat) {
        guard let text = self.text else { return }
        let attributedString = NSAttributedString(string: text, attributes: [
            .kern: kern
        ])
        self.attributedText = attributedString
    }
    
    public func set(placeholder: String?) {
        self.placeholder = placeholder
    }
}

// MARK: - UITextView扩展
extension UITextView: HasText {
    public func set(text: String?) {
        self.text = text
    }
    
    public func set(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }
    
    public func set(color: UIColor) {
        self.textColor = color
    }
    
    public func set(alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }
    
    public func set(numberOfLines: Int) {
        // UITextView 默认支持多行
    }
    
    public func set(lineSpacing: CGFloat) {
        guard let text = self.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributedString = NSAttributedString(string: text, attributes: [
            .paragraphStyle: paragraphStyle
        ])
        self.attributedText = attributedString
    }
    
    public func set(kern: CGFloat) {
        guard let text = self.text else { return }
        let attributedString = NSAttributedString(string: text, attributes: [
            .kern: kern
        ])
        self.attributedText = attributedString
    }
    
    public func set(placeholder: String?) {
        // UITextView 不直接支持占位符，需要自定义实现
    }
}

// MARK: - 链式扩展
public extension TFY where Base: HasText {
    /// 设置文本
    @discardableResult
    func text(_ text: String?) -> Self {
        base.set(text: text)
        return self
    }
    
    /// 设置富文本
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString?) -> Self {
        base.set(attributedText: attributedText)
        return self
    }
    
    /// 设置文本颜色
    @discardableResult
    func textColor(_ textColor: UIColor) -> Self {
        base.set(color: textColor)
        return self
    }
    
    /// 设置文本对齐方式
    @discardableResult
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        base.set(alignment: textAlignment)
        return self
    }
    
    /// 设置行数
    @discardableResult
    func numberOfLines(_ number: Int) -> Self {
        base.set(numberOfLines: number)
        return self
    }
    
    /// 设置行间距
    @discardableResult
    func lineSpacing(_ spacing: CGFloat) -> Self {
        base.set(lineSpacing: spacing)
        return self
    }
    
    /// 设置字间距
    @discardableResult
    func kern(_ kern: CGFloat) -> Self {
        base.set(kern: kern)
        return self
    }
    
    /// 设置占位符
    @discardableResult
    func placeholder(_ text: String?) -> Self {
        base.set(placeholder: text)
        return self
    }
    
    /// 设置富文本属性
    @discardableResult
    func attributes(_ attributes: [NSAttributedString.Key: Any]) -> Self {
        if let text = (base as? UILabel)?.text ?? (base as? UITextField)?.text ?? (base as? UITextView)?.text {
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            base.set(attributedText: attributedString)
        }
        return self
    }
}

