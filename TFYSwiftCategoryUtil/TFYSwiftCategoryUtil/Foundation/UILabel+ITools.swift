//
//  UILabel+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/5/5.
//

import Foundation
import UIKit

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
    
    /// 圆角
    @discardableResult
    func cornerRadius(_ radius:CGFloat) -> Self {
        base.layer.cornerRadius = radius
        return self
    }
    
    /// 是否隐藏
    @discardableResult
    func hidden(_ hidden: Bool) -> Self {
        base.isHidden = hidden
        return self
    }
    
    /// tintColor
    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        base.tintColor = color
        return self
    }
    
    /// 透明度
    @discardableResult
    func alpha(_ alpha: CGFloat) -> Self {
        base.alpha = alpha
        return self
    }
    
    /// clipsToBounds
    @discardableResult
    func clipsToBounds(_ clips: Bool) -> Self {
        base.clipsToBounds = clips
        return self
    }
    
    /// isOpaque
    @discardableResult
    func opaque(_ opaque: Bool) -> Self {
        base.isOpaque = opaque
        return self
    }
    
    /// isUserInteractionEnabled
    @discardableResult
    func userInteractionEnabled(_ enabled: Bool) -> Self {
        base.isUserInteractionEnabled = enabled
        return self
    }
    
    /// contentMode
    @discardableResult
    func multipleTouchEnabled(_ enabled: Bool) -> Self {
        base.isMultipleTouchEnabled = enabled
        return self
    }
    
    ///
    @discardableResult
    func contentMode(_ mode: UIView.ContentMode) -> Self {
        base.contentMode = mode
        return self
    }
    
    /// transform
    @discardableResult
    func transform(_ transform: CGAffineTransform) -> Self {
        base.transform = transform
        return self
    }
    
    /// autoresizingMask
    @discardableResult
    func autoresizingMask(_ mask: UIView.AutoresizingMask) -> Self {
        base.autoresizingMask = mask
        return self
    }
    
    /// autoresizesSubviews
    @discardableResult
    func autoresizesSubviews(_ sizes: Bool) -> Self {
        base.autoresizesSubviews = sizes
        return self
    }
    
    /// 默认为没有。可以做成动画。
    @discardableResult
    func shouldRasterize(_ rasterize: Bool) -> Self {
        base.layer.shouldRasterize = rasterize
        return self
    }
    
    ///
    @discardableResult
    func opacity(_ opacity: Float) -> Self {
        base.layer.opacity = opacity
        return self
    }
    
    /// 图层的背景色。默认值为nil。颜色支持从平铺模式创建。可以做成动画。
    @discardableResult
    func backGroundColor(_ color: UIColor?) -> Self {
        base.layer.backgroundColor = color?.cgColor
        return self
    }
    
    /// 一个提示标记- drawcontext提供的图层内容:完全不透明。默认为没有。注意，这并不影响直接解释' contents'属性。
    @discardableResult
    func opaqueLayer(_ opaque: Bool) -> Self {
        base.layer.isOpaque = opaque
        return self
    }
    
    /// 图层将被栅格化的比例(当shouldRasterize属性已设置为YES)相对于图层的坐标空间。默认为1。可以做成动画。
    @discardableResult
    func rasterizationScale(_ scale: CGFloat) -> Self {
        base.layer.rasterizationScale = scale
        return self
    }
    
    /// 当为true时，将应用与图层边界匹配的隐式蒙版 图层(包括' cornerRadius'属性的效果)。如果' mask'和' masksToBounds'两个掩码都是非nil的 乘以得到实际的掩码值。默认为没有。可以做成动画。
    @discardableResult
    func masksToBounds(_ maske: Bool) -> Self {
        base.layer.masksToBounds = maske
        return self
    }
    
    /// 图层边界的宽度，从图层边界中插入。的边框是合成在层的内容和子层和 包含了' cornerRadius'属性的效果。默认为0。可以做成动画。
    @discardableResult
    func borderWidth(_ width: CGFloat) -> Self {
        base.layer.borderWidth = width
        return self
    }
    
    /// 图层边界的颜色。默认为不透明的黑色。颜色 支持从平铺模式创建。可以做成动画。
    @discardableResult
    func borderColor(_ color: UIColor?) -> Self {
        base.layer.borderColor = color?.cgColor
        return self
    }
    
    /// 在超层中，该层的锚点的位置 bounds rect对齐到。默认值为0。可以做成动画。
    @discardableResult
    func zPosition(_ point: CGPoint) -> Self {
        base.layer.position = point
        return self
    }
    
    /// 阴影的不透明。默认值为0。属性之外指定一个值 [0,1]范围将给出未定义的结果。可以做成动画。
    @discardableResult
    func shadowOpacity(_ opacity: Float) -> Self {
        base.layer.shadowOpacity = opacity
        return self
    }
    
    /// 相对于该层的锚点应用到该层的转换默认为标识转换。可以做成动画。
    @discardableResult
    func transform(_ transform: CATransform3D) -> Self {
        base.layer.transform = transform
        return self
    }
    
    /// shadowPath
    @discardableResult
    func shadowPath(_ path: CGPath?) -> Self {
        base.layer.shadowPath = path
        return self
    }
    
}

