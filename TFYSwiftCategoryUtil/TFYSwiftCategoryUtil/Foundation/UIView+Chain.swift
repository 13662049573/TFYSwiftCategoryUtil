//
//  UIView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public func adaptWidth(designWidth: CGFloat = 375.0, _ vaule: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.size.width / designWidth * vaule
}

extension CGColor {
    var uiColor:UIColor { return UIColor(cgColor: self) }
}

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
    
    /// 屏幕适配
    func adaptSubViews() {
        // 约束
        for cons in constraints {
            cons.constant = adaptWidth(cons.constant)
        }
        // 圆角
        layer.cornerRadius = adaptWidth(layer.cornerRadius)

        // 字体大小
        if isKind(of: UILabel.self) == true {
            let lbl = self as! UILabel
            lbl.font = UIFont(name: lbl.font.fontName, size: adaptWidth(lbl.font.pointSize))
        }
        if isKind(of: UITextField.self) == true {
            let tf = self as! UITextField
            guard let f = tf.font else {
                return
            }
            tf.font = UIFont(name: f.fontName, size: adaptWidth(f.pointSize))
        }

        if isKind(of: UITextView.self) == true {
            let tf = self as! UITextView
            guard let f = tf.font else {
                return
            }
            tf.font = UIFont(name: f.fontName, size: adaptWidth(f.pointSize))
        }

        if isKind(of: UIButton.self) == true {
            let btn = self as! UIButton
            if let f = btn.titleLabel?.font {
                btn.titleLabel?.font = UIFont(name: f.fontName, size: adaptWidth(f.pointSize))
            }
        }

        for v in subviews {
            v.adaptSubViews()
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// 添加圆角
    func cornerCut(radius:CGFloat,corner:UIRectCorner){
        let maskPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize.init(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue > 0 ? newValue : 0
        }
    }

    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @objc @IBInspectable var shadowOffset:CGSize {
        set { layer.shadowOffset = newValue }
        get { return layer.shadowOffset }
    }
    
    @objc @IBInspectable var shadowColor:UIColor? {
        set { layer.shadowColor = newValue?.cgColor }
        get { return layer.shadowColor?.uiColor }
    }
    
    @objc @IBInspectable var shadowRadius:CGFloat {
        set { layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    @objc @IBInspectable var shadowOpacity:Float {
        set { layer.shadowOpacity = newValue }
        get { return layer.shadowOpacity }
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
        base.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    func borderWidth(_ borderWidth: CGFloat) -> TFY {
        base.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    func borderColor(_ borderColor: UIColor) -> TFY {
        base.borderColor = borderColor
        return self
    }
    
    @discardableResult
    func shadowColor(_ shadowColor: UIColor?) -> TFY {
        base.shadowColor = shadowColor
        return self
    }
    
    @discardableResult
    func shadowOpacity(_ shadowOpacity: Float) -> TFY {
        base.shadowOpacity = shadowOpacity
        return self
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset: CGSize) -> TFY {
        base.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func shadowRadius(_ shadowRadius: CGFloat) -> TFY {
        base.shadowRadius = shadowRadius
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
    
    @discardableResult
    func addRadius(direction: UIRectCorner = .allCorners, vaule: CGFloat) -> TFY {
        base.cornerCut(radius: vaule, corner: direction)
        return self
    }
    
}
