//
//  HasFont.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public protocol HasFont {
    
    func set(font: UIFont)
}

extension UILabel: HasFont {
    
    public func set(font: UIFont) {
        self.font = font
    }
}

extension UIButton: HasFont {
    
    public func set(font: UIFont) {
        self.titleLabel?.font = font
    }
}

extension UITextField: HasFont {
    
    public func set(font: UIFont) {
        self.font = font
    }
}

extension UITextView: HasFont {
    
    public func set(font: UIFont) {
        self.font = font
    }
}

public extension TFY where Base: HasFont {
    
    /// 设置字体特征
    @discardableResult
    func fontDescriptor(symblicTraits traits: UIFontDescriptor.SymbolicTraits) -> Self {
        if let currentFont = (base as? UILabel)?.font ?? (base as? UITextField)?.font ?? (base as? UITextView)?.font,
           let newDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
            base.set(font: newFont)
        }
        return self
    }
    
    /// 设置字体样式
    @discardableResult
    func fontStyle(_ style: UIFont.TextStyle, traits: UIFontDescriptor.SymbolicTraits? = nil) -> Self {
        let font = UIFont.preferredFont(forTextStyle: style)
        if let traits = traits,
           let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
            base.set(font: newFont)
        } else {
            base.set(font: font)
        }
        return self
    }
    
    /// 设置动态字体
    @discardableResult
    func dynamicFont(style: UIFont.TextStyle, maxSize: CGFloat? = nil) -> Self {
        let metrics = UIFontMetrics(forTextStyle: style)
        let baseFont = UIFont.preferredFont(forTextStyle: style)
        if let maxSize = maxSize {
            let scaledFont = metrics.scaledFont(for: baseFont, maximumPointSize: maxSize)
            base.set(font: scaledFont)
        } else {
            let scaledFont = metrics.scaledFont(for: baseFont)
            base.set(font: scaledFont)
        }
        return self
    }
    
    /// 设置字体
    @discardableResult
    func font(_ font: UIFont) -> Self {
        base.set(font: font)
        return self
    }
    
    /// 设置系统字体
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat) -> Self {
        base.set(font: .systemFont(ofSize: fontSize))
        return self
    }
    
    /// 设置粗体系统字体
    @discardableResult
    func boldSystemFont(ofSize fontSize: CGFloat) -> Self {
        base.set(font: .boldSystemFont(ofSize: fontSize))
        return self
    }
    
    /// 设置带权重的系统字体
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> Self {
        base.set(font: .systemFont(ofSize: fontSize, weight: weight))
        return self
    }
    
    /// 设置斜体系统字体
    @discardableResult
    func italicSystemFont(ofSize fontSize: CGFloat) -> Self {
        if let font = UIFont(name: ".SFUI-RegularItalic", size: fontSize) {
            base.set(font: font)
        }
        return self
    }
    
    /// 设置自定义字体
    @discardableResult
    func customFont(name: String, size: CGFloat) -> Self {
        if let font = UIFont(name: name, size: size) {
            base.set(font: font)
        }
        return self
    }
}
