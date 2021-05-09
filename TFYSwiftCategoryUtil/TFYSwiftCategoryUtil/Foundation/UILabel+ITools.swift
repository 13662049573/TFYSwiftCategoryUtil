//
//  UILabel+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/5/5.
//

import Foundation
import UIKit

extension UILabel: TFYCompatible {}

// MARK: 链式编程
extension TFY where Base == UILabel {
    
    /// text: 文字内容
    @discardableResult
    func text(_ text: String?) -> Self {
        base.text = text
        return self
    }
    
    /// 设置文字行数
    @discardableResult
    func numberOfLines(_ number: Int) -> Self {
        base.numberOfLines = number
        return self
    }
    
    /// 文字颜色
    @discardableResult
    func textColor(_ color: UIColor!) -> Self {
        base.textColor = color
        return self
    }
    
    /// 文字带下
    @discardableResult
    func font(_ font: UIFont!) -> Self {
        base.font = font
        return self
    }
    
    /// 文字对齐方式
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        base.textAlignment = alignment
        return self
    }
    
    /// 设置富文本文字 默认为零
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString) -> Self {
        base.attributedText = attributedText
        return self
    }
    
    ///  影子的颜色。默认为不透明的黑色。颜色创建from模式目前不支持。可以做成动画。
    @discardableResult
    func layershadowColor(_ color: UIColor?) -> Self {
        base.layer.shadowColor = color?.cgColor
        return self
    }
    
    /// 默认为nil(没有阴影)
    @discardableResult
    func shadowColor(_ color: UIColor?) -> Self {
        base.shadowColor = color
        return self
    }
    
    /// layer 影子偏移量。默认为(0，-3)。可以做成动画。
    @discardableResult
    func layershadowOffset(_ size: CGSize) -> Self {
        base.layer.shadowOffset = size
        return self
    }
    
    /// 默认是CGSizeMake(0， -1)——一个顶部阴影
    @discardableResult
    func shadowOffset(_ size: CGSize) -> Self {
        base.shadowOffset = size
        return self
    }
    
    /// layer 用于创建阴影的模糊半径。默认为3。可以做成动画。
    @discardableResult
    func shadowRadius(_ radius: CGFloat) -> Self {
        base.layer.shadowRadius = radius
        return self
    }
    
    /// 默认是NSLineBreakByTruncatingTail。用于单行和多行文本
    @discardableResult
    func lineBreakMode(_ breadMode: NSLineBreakMode) -> Self {
        base.lineBreakMode = breadMode
        return self
    }
    
    /// “highlight”属性被子类用于按下状态这样的事情。将其作为用户属性作为基类的一部分是很有用的
    @discardableResult
    func highlightedTextColor(_ color: UIColor?) -> Self {
        base.highlightedTextColor = color
        return self
    }
    
    /// 允许标签自动调整大小，以适应一定的宽度，缩放因子>=最小缩放因子的字体大小,并指定当需要缩小字体时文本基线如何移动。
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSize: Bool) -> Self {
        base.adjustsFontSizeToFitWidth = adjustsFontSize
        return self
    }
    
    /// system 文字大小
    @discardableResult
    func systemFont(_ ofSize: CGFloat) -> Self {
        base.font = UIFont.systemFont(ofSize: ofSize)
        return self
    }
    
    /// boldSystem 加粗文字大小
    @discardableResult
    func boldFont(_ ofSize: CGFloat) -> Self {
        base.font = UIFont.boldSystemFont(ofSize: ofSize)
        return self
    }
    
    /// 背景颜色
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        base.backgroundColor = color
        return self
    }
    
    /// 添加容器
    @discardableResult
    func addSubview(_ subView: UIView) -> Self {
        subView.addSubview(base)
        return self
    }
    
}

