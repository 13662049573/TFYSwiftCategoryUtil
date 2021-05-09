//
//  UIImageView+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/5/6.
//

import Foundation
import UIKit

extension TFY where Base == UIImageView {
    
    func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.tfy_gif(name: name)
            DispatchQueue.main.async {
                base.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.tfy_gif(asset: asset)
            DispatchQueue.main.async {
                base.image = image
            }
        }
    }
    
    /// 图片
    @discardableResult
    func image(_ image: UIImage?) -> Self {
        base.image = image
        return self
    }
    
    /// 图片高亮
    @discardableResult
    func highlightedImage(_ image: UIImage) -> Self {
        base.highlightedImage = image
        return self
    }
    
    ///  影子的颜色。默认为不透明的黑色。颜色创建from模式目前不支持。可以做成动画。
    @discardableResult
    func layershadowColor(_ color: UIColor?) -> Self {
        base.layer.shadowColor = color?.cgColor
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
    
    /// 圆角
    @discardableResult
    func cornerRadius(_ radius:CGFloat) -> Self {
        base.layer.cornerRadius = radius
        return self
    }
    
    /// 添加容器
    @discardableResult
    func addSubview(_ subView: UIView) -> Self {
        subView.addSubview(base)
        return self
    }
    
    /// 透明度
    @discardableResult
    func alpha(_ alpha: CGFloat) -> Self {
        base.alpha = alpha
        return self
    }
    
    /// 切园是否开启
    @discardableResult
    func clipsToBounds(_ isbool: Bool) -> Self {
        base.clipsToBounds = isbool
        return self
    }
    
    /// 背景颜色
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        base.backgroundColor = color
        return self
    }
    
    /// 高亮开关
    @discardableResult
    func highlighted(_ bool: Bool) -> Self {
        base.isHighlighted = bool
        return self
    }
    
    /// 动画数据
    @discardableResult
    func animationImages(_ animationImages: [UIImage]?) -> Self {
        base.animationImages = animationImages
        return self
    }
    
    /// 动画数组高亮
    @discardableResult
    func highlightedAnimationImages(_ highlightedAnimationImages: [UIImage]?) -> Self {
        base.highlightedAnimationImages = highlightedAnimationImages
        return self
    }
    
    /// 动画开始
    func startAnimating() -> Void {
        base.startAnimating()
    }
    
    /// 结束动画
    func stopAnimating() -> Void {
        base.stopAnimating()
    }
    
    /// 动画执行次数
    @discardableResult
    func animationRepeatCount(_ count: Int) -> Self {
        base.animationRepeatCount = count
        return self
    }
    
    /// 动画时间
    @discardableResult
    func animationDuration(_ duration: TimeInterval) -> Self {
        base.animationDuration = duration
        return self
    }
    
    /// 点击事件
    @discardableResult
    func addTarget(_ target: Any?, action: Selector) -> Self {
        let tap = UITapGestureRecognizer(target: target, action: action)
        base.addGestureRecognizer(tap)
        return self
    }
}

