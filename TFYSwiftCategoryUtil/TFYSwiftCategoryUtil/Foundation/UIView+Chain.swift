//
//  UIView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension UIView {
    /// 加载xib
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    ///x轴坐标
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var tmpFrame = self.frame
            tmpFrame.origin.x = newValue
            self.frame = tmpFrame
        }
    }
    
    ///y轴坐标
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var tmpFrame = self.frame
            tmpFrame.origin.y = newValue
            self.frame = tmpFrame
        }
    }
    
    ///宽度
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var tmpFrame = self.frame
            tmpFrame.size.width = newValue
            self.frame = tmpFrame
        }
    }
    
    ///高度
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var tmpFrame = self.frame
            tmpFrame.size.height = newValue
            self.frame = tmpFrame
        }
    }
    
    /// 最右边约束x值
    var maxX: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            var tmpFrame = self.frame;
            tmpFrame.origin.x = newValue - tmpFrame.size.width;
            self.frame = tmpFrame;
        }
    }
    
    /// 最下边约束y值
    var maxY: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var tmpFrame = self.frame;
            tmpFrame.origin.y = newValue - tmpFrame.size.height;
            self.frame = tmpFrame;
        }
    }
    
    /// 设置x轴中心点
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y);
        }
    }
    
    /// 设置y轴中心点
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue);
        }
        
    }
    
    /// 设置size
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newValue.width, height: newValue.height)
        }
    }
    
    /// 设置orgin
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame = CGRect(x: newValue.x, y: newValue.y, width: self.frame.size.width, height: self.frame.size.height)
        }
    }

    /// 移除所有子视图
    func removeAllSubviews() {
        while self.subviews.count > 0 {
            self.subviews.last?.removeFromSuperview()
        }
    }
    
}


public extension TFY where Base: UIView {
    
    @discardableResult
    func tag(_ tag: Int) -> TFY {
        base.tag = tag
        return self
    }
    
    @discardableResult
    func frame(_ frame: CGRect) -> TFY {
        base.frame = frame
        return self
    }
    
    @discardableResult
    func frame(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> TFY {
        base.frame = CGRect(x: x, y: y, width: width, height: height)
        return self
    }
    
    @discardableResult
    func bounds(_ bounds: CGRect) -> TFY {
        base.bounds = bounds
        return self
    }
    
    @discardableResult
    func center(_ center: CGPoint) -> TFY {
        base.center = center
        return self
    }
    
    @discardableResult
    func center(x: CGFloat, y: CGFloat) -> TFY {
        base.center = CGPoint(x: x, y: y)
        return self
    }
    
    @discardableResult
    func backgroundColor(_ backgroundColor: UIColor) -> TFY {
        base.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    func contentMode(_ contentMode: UIView.ContentMode) -> TFY {
        base.contentMode = contentMode
        return self
    }
    
    @discardableResult
    func clipsToBounds(_ clipsToBounds: Bool) -> TFY {
        base.clipsToBounds = clipsToBounds
        return self
    }
    
    @discardableResult
    func alpha(_ alpha: CGFloat) -> TFY {
        base.alpha = alpha
        return self
    }
    
    @discardableResult
    func isHidden(_ isHidden: Bool) -> TFY {
        base.isHidden = isHidden
        return self
    }
    
    @discardableResult
    func isOpaque(_ isOpaque: Bool) -> TFY {
        base.isOpaque = isOpaque
        return self
    }
    
    @discardableResult
    func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> TFY {
        base.isUserInteractionEnabled = isUserInteractionEnabled
        return self
    }
    
    @discardableResult
    func tintColor(_ tintColor: UIColor) -> TFY {
        base.tintColor = tintColor
        return self
    }
    
    @discardableResult
    func cornerRadius(_ cornerRadius: CGFloat) -> TFY {
        base.layer.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    func masksToBounds(_ masksToBounds: Bool) -> TFY {
        base.layer.masksToBounds = masksToBounds
        return self
    }
    
    @discardableResult
    func borderWidth(_ borderWidth: CGFloat) -> TFY {
        base.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    func borderColor(_ borderColor: UIColor) -> TFY {
        base.layer.borderColor = borderColor.cgColor
        return self
    }
    
    @discardableResult
    func shadowColor(_ shadowColor: UIColor?) -> TFY {
        base.layer.shadowColor = shadowColor?.cgColor
        return self
    }
    
    @discardableResult
    func shadowOpacity(_ shadowOpacity: Float) -> TFY {
        base.layer.shadowOpacity = shadowOpacity
        return self
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset: CGSize) -> TFY {
        base.layer.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func shadowRadius(_ shadowRadius: CGFloat) -> TFY {
        base.layer.shadowRadius = shadowRadius
        return self
    }
    
    @discardableResult
    func shadowPath(_ shadowPath: CGPath?) -> TFY {
        base.layer.shadowPath = shadowPath
        return self
    }
    
    @discardableResult
    func addToSuperView(_ view: UIView) -> TFY {
        view.addSubview(base)
        return self
    }
    
    @discardableResult
    func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) -> TFY {
        base.addGestureRecognizer(gestureRecognizer)
        return self
    }
    
    @discardableResult
    func addConstraint(_ constraint: NSLayoutConstraint) -> TFY {
        base.addConstraint(constraint)
        return self
    }
    
    @discardableResult
    func addConstraints(_ constraints: [NSLayoutConstraint]) -> TFY {
        base.addConstraints(constraints)
        return self
    }
}
