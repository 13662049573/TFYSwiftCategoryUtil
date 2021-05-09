//
//  UIButton+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/5/5.
//

import Foundation
import UIKit

extension TFY where Base == UIButton {
    
    /// text: 文字内容
    @discardableResult
    func text(_ title: String?, state: UIControl.State) -> Self {
        base.setTitle(title, for: state)
        return self
    }
    
    /// 文字颜色
    @discardableResult
    func textColor(_ color: UIColor?, state: UIControl.State) -> Self {
        base.setTitleColor(color, for: state)
        return self
    }
    
    /// 背景颜色
    @discardableResult
    func backgroundColor(_ color: UIColor?) -> Self {
        base.backgroundColor = color
        return self
    }
    
    /// 圆角
    @discardableResult
    func cornerRadius(_ radius:CGFloat) -> Self {
        base.layer.cornerRadius = radius
        return self
    }
    
    /// 文字大小
    @discardableResult
    func font(_ font: UIFont!) -> Self {
        base.titleLabel?.font = font
        return self
    }
    
    /// 切园是否开启
    @discardableResult
    func clipsToBounds(_ isbool: Bool) -> Self {
        base.clipsToBounds = isbool
        return self
    }
    
    /// 透明度
    @discardableResult
    func alpha(_ alpha: CGFloat) -> Self {
        base.alpha = alpha
        return self
    }
    
    /// 文字样式对齐
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        base.titleLabel?.textAlignment = alignment
        return self
    }
    
    /// 图片
    @discardableResult
    func image(_ image: UIImage?, state: UIControl.State) -> Self {
        base.setImage(image, for: state)
        return self
    }
    
    
    /// 背景图片
    @discardableResult
    func backgroundImage(_ image: UIImage?, state: UIControl.State) -> Self {
        base.setBackgroundImage(image, for: state)
        return self
    }
    
    /// 设置富文本文字 默认为零
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString,state: UIControl.State) -> Self {
        base.setAttributedTitle(attributedText, for: state)
        return self
    }
    
    /// 允许标签自动调整大小，以适应一定的宽度，缩放因子>=最小缩放因子的字体大小,并指定当需要缩小字体时文本基线如何移动。
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSize: Bool) -> Self {
        base.titleLabel!.adjustsFontSizeToFitWidth = adjustsFontSize
        return self
    }
    
    /// system 文字大小
    @discardableResult
    func systemFont(_ ofSize: CGFloat) -> Self {
        base.titleLabel!.font = UIFont.systemFont(ofSize: ofSize)
        return self
    }
    
    /// boldSystem 加粗文字大小
    @discardableResult
    func boldFont(_ ofSize: CGFloat) -> Self {
        base.titleLabel!.font = UIFont.boldSystemFont(ofSize: ofSize)
        return self
    }
    
    /// 默认是NSLineBreakByTruncatingTail。用于单行和多行文本
    @discardableResult
    func lineBreakMode(_ breadMode: NSLineBreakMode) -> Self {
        base.titleLabel!.lineBreakMode = breadMode
        return self
    }
    
    /// layer 默认为nil(没有阴影)
    @discardableResult
    func shadowColor(_ color: UIColor?) -> Self {
        base.layer.shadowColor = color?.cgColor
        return self
    }
    
    /// layer 默认是CGSizeMake(0， -1)——一个顶部阴影
    @discardableResult
    func shadowOffset(_ size: CGSize) -> Self {
        base.layer.shadowOffset = size
        return self
    }
    
    /// layer 用于创建阴影的模糊半径。默认为3。可以做成动画。
    @discardableResult
    func shadowRadius(_ radius: CGFloat) -> Self {
        base.layer.shadowRadius = radius
        return self
    }
    
    /// 设置文字行数
    @discardableResult
    func numberOfLines(_ number: Int) -> Self {
        base.titleLabel!.numberOfLines = number
        return self
    }
    
    /// 点击事件
    @discardableResult
    func addTarget(_ target: Any?, action: Selector,controlEvents: UIControl.Event) -> Self {
        base.addTarget(target, action: action, for: controlEvents)
        return self
    }
    
    /// Vertical 文本格式对齐
    @discardableResult
    func contentVerticalAlignment(_ alignment: UIControl.ContentVerticalAlignment) -> Self {
        base.contentVerticalAlignment = alignment
        return self
    }
    
    /// Horizon 文本格式对齐
    @discardableResult
    func contentHorizontalAlignment(_ alignment: UIControl.ContentHorizontalAlignment) -> Self {
        base.contentHorizontalAlignment = alignment
        return self
    }
    
    /// 添加容器
    @discardableResult
    func addSubview(_ subView: UIView) -> Self {
        subView.addSubview(base)
        return self
    }
    
    /// 更改文字内边际
    @discardableResult
    func titleEdgeInsets(_ titleEdgeInsets: UIEdgeInsets) -> Self {
        base.titleEdgeInsets = titleEdgeInsets
        return self
    }
    
    /// 更改图片内边际
    @discardableResult
    func imageEdgeInsets(_ imageEdgeInsets: UIEdgeInsets) -> Self {
        base.imageEdgeInsets = imageEdgeInsets
        return self
    }
    
    /// 边际更改
    @discardableResult
    func contentEdgeInsets(_ contentEdgeInsets: UIEdgeInsets) -> Self {
        base.contentEdgeInsets = contentEdgeInsets
        return self
    }
    
    /// 默认是肯定的。如果是，图像在高亮(按下)时会画得更暗
    @discardableResult
    func adjustsImageWhenHighlighted(_ adjustsImageWhenHighlighted: Bool) -> Self {
        base.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted
        return self
    }
    
    /// 默认是肯定的。如果是，图像绘制较浅时，禁用
    @discardableResult
    func adjustsImageWhenDisabled(_ adjustsImageWhenDisabled: Bool) -> Self {
        base.adjustsImageWhenDisabled = adjustsImageWhenDisabled
        return self
    }
    
    /// 默认是否定的。如果是，在突出显示时显示一个简单的反馈(当前是一个辉光)
    @discardableResult
    func showsTouchWhenHighlighted(_ showsTouchWhenHighlighted: Bool) -> Self {
        base.showsTouchWhenHighlighted = showsTouchWhenHighlighted
        return self
    }
    
    /// 阴影颜色
    @discardableResult
    func titleShadowColor(_ state: UIControl.State) -> Self {
        base.titleShadowColor(for: state)
        return self
    }
}
