//
//  View+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/4/21.
//

import Foundation
import UIKit

extension UIView {
    static var tfy: TFY<UIView>.Type {
        set {}
        get { TFY<UIView>.self }
    }
    
    var tfy: TFY<UIView> {
        set {}
        get { TFY(self) }
    }
}

/// MARK ---------------------------------------------------------------  VIEW ---------------------------------------------------------------
extension TFY where Base == UIView {
    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat,viewBounds:CGRect) {
        let maskPath = UIBezierPath(roundedRect: viewBounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = viewBounds
        maskLayer.path = maskPath.cgPath
        base.layer.mask = maskLayer
    }
    
    /// 加载xib
    func loadViewFromNib() -> UIView {
        let className = type(of: base)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    ///x轴坐标
    var x: CGFloat {
        get {
            return base.frame.origin.x
        }
        set {
            var tmpFrame = base.frame
            tmpFrame.origin.x = newValue
            base.frame = tmpFrame
        }
    }
    
    ///y轴坐标
    var y: CGFloat {
        get {
            return base.frame.origin.y
        }
        set {
            var tmpFrame = base.frame
            tmpFrame.origin.y = newValue
            base.frame = tmpFrame
        }
    }
    
    ///宽度
    var width: CGFloat {
        get {
            return base.frame.size.width
        }
        set {
            var tmpFrame = base.frame
            tmpFrame.size.width = newValue
            base.frame = tmpFrame
        }
    }
    
    ///高度
    var height: CGFloat {
        get {
            return base.frame.size.height
        }
        set {
            var tmpFrame = base.frame
            tmpFrame.size.height = newValue
            base.frame = tmpFrame
        }
    }
    
    /// 最右边约束x值
    var maxX: CGFloat {
        get {
            return base.frame.origin.x + base.frame.size.width
        }
        set {
            var tmpFrame = base.frame;
            tmpFrame.origin.x = newValue - tmpFrame.size.width;
            base.frame = tmpFrame;
        }
    }
    
    /// 最下边约束y值
    var maxY: CGFloat {
        get {
            return base.frame.origin.y + base.frame.size.height
        }
        set {
            var tmpFrame = base.frame;
            tmpFrame.origin.y = newValue - tmpFrame.size.height;
            base.frame = tmpFrame;
        }
    }
    
    /// 设置x轴中心点
    var centerX: CGFloat {
        get {
            return base.center.x
        }
        set {
            base.center = CGPoint(x: newValue, y: base.center.y);
        }
    }
    
    /// 设置y轴中心点
    var centerY: CGFloat {
        get {
            return base.center.y
        }
        set {
            base.center = CGPoint(x: base.center.x, y: newValue);
        }
        
    }
    
    /// 设置size
    var size: CGSize {
        get {
            return base.frame.size
        }
        set {
            base.frame = CGRect(x: base.frame.origin.x, y: base.frame.origin.y, width: newValue.width, height: newValue.height)
        }
    }
    
    /// 设置orgin
    var origin: CGPoint {
        get {
            return base.frame.origin
        }
        set {
            base.frame = CGRect(x: newValue.x, y: newValue.y, width: base.frame.size.width, height: base.frame.size.height)
        }
    }
    
    /// 设置圆角
    var cornerRadius: CGFloat {
        get {
            return base.layer.cornerRadius
        }
        set {
            base.layer.cornerRadius = newValue
            base.layer.masksToBounds = true
        }
    }
    
    /// 移除所有子视图
    func removeAllSubviews() {
        while base.subviews.count > 0 {
            base.subviews.last?.removeFromSuperview()
        }
    }
}
