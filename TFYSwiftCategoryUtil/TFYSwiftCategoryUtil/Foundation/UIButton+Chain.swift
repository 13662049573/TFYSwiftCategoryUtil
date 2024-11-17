//
//  UIButton+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

/// 按钮链式编程扩展
public extension TFY where Base: UIButton {
    
    /// 设置按钮标题
    @discardableResult
    func title(_ title: String?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setTitle(title, for: $0) }
        return self
    }
    
    /// 设置按钮标题颜色
    @discardableResult
    func titleColor(_ color: UIColor?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setTitleColor(color, for: $0) }
        return self
    }
    
    /// 设置按钮图片
    @discardableResult
    func image(_ image: UIImage?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setImage(image, for: $0) }
        return self
    }
    
    /// 设置按钮背景图片
    @discardableResult
    func backgroundImage(_ image: UIImage?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setBackgroundImage(image, for: $0) }
        return self
    }
    
    /// 设置按钮富文本标题
    @discardableResult
    func attributedTitle(_ attributedTitle: NSAttributedString?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setAttributedTitle(attributedTitle, for: $0) }
        return self
    }
    
    /// 设置标题内边距
    @discardableResult
    func titleEdgeInsets(_ edgeInsets: UIEdgeInsets) -> TFY {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: edgeInsets.top,
                leading: edgeInsets.left,
                bottom: edgeInsets.bottom,
                trailing: edgeInsets.right
            )
            configuration.titlePadding = edgeInsets.left
            base.configuration = configuration
        } else {
            base.titleEdgeInsets = edgeInsets
        }
        return self
    }
    
    /// 设置标题内边距（分开设置）
    @discardableResult
    func titleEdgeInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> TFY {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: top,
                leading: left,
                bottom: bottom,
                trailing: right
            )
            configuration.titlePadding = left
            base.configuration = configuration
        } else {
            base.titleEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        return self
    }
    
    /// 设置图片内边距
    @discardableResult
    func imageEdgeInsets(_ edgeInsets: UIEdgeInsets) -> TFY {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: edgeInsets.top,
                leading: edgeInsets.left,
                bottom: edgeInsets.bottom,
                trailing: edgeInsets.right
            )
            configuration.imagePadding = edgeInsets.left
            base.configuration = configuration
        } else {
            base.imageEdgeInsets = edgeInsets
        }
        return self
    }
    
    /// 设置图片内边距（分开设置）
    @discardableResult
    func imageEdgeInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> TFY {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: top,
                leading: left,
                bottom: bottom,
                trailing: right
            )
            configuration.imagePadding = left
            base.configuration = configuration
        } else {
            base.imageEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        return self
    }
    
    /// 设置内容水平对齐方式
    @discardableResult
    func contentHorizontalAlignment(_ alignment: UIControl.ContentHorizontalAlignment) -> TFY {
        base.contentHorizontalAlignment = alignment
        return self
    }
    
    /// 设置是否将自动调整大小掩码转换为约束
    @discardableResult
    func translatesAutoresizingMaskIntoConstraints(_ transl: Bool) -> TFY {
        base.translatesAutoresizingMaskIntoConstraints = transl
        return self
    }
    
    /// 设置标题是否自适应字体大小
    @discardableResult
    func adjustsFontSizeToFitWidth(_ fontbool: Bool) -> TFY {
        base.titleLabel?.adjustsFontSizeToFitWidth = fontbool
        return self
    }
    
    /// 设置图片方向和间距
    @discardableResult
    func imageDirection(_ direction: UIButton.ButtonImageDirection, _ space: CGFloat) -> TFY {
        base.imageDirection(direction, space)
        return self
    }
    
    /// 设置不同状态下的背景色
    @discardableResult
    func backgroundStateColor(_ color: UIColor, for state: UIControl.State...) -> TFY {
        state.forEach { base.setBackgroundColor(color, for: $0) }
        return self
    }
}

// MARK: - 按钮图片方向枚举
extension UIButton {
    /// 按钮图片方向枚举
    public enum ButtonImageDirection: Int {
        /// 内容居中: 图片在上，文字在下
        case centerImageTop = 1
        /// 内容居中: 图片在左，文字在右
        case centerImageLeft = 2
        /// 内容居中: 图片在右，文字在左
        case centerImageRight = 3
        /// 内容居中: 图片在下，文字在上
        case centerImageBottom = 4
        /// 内容居左: 图片在左，文字在右
        case leftImageLeft = 5
        /// 内容居左: 图片在右，文字在左
        case leftImageRight = 6
        /// 内容居右: 图片在左，文字在右
        case rightImageLeft = 7
        /// 内容居右: 图片在右，文字在左
        case rightImageRight = 8
    }
    
    /// 设置按钮的图片和文字位置关系
    /// - Parameters:
    ///   - type: 图片位置类型
    ///   - space: 图片和文字之间的间距
    public func imageDirection(_ type: UIButton.ButtonImageDirection, _ space: CGFloat) {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            
            // 设置基础配置
            configuration.imagePadding = space
            
            // 根据类型设置不同的布局
            switch type {
            case .centerImageTop:
                configuration.imagePlacement = .top
                configuration.titleAlignment = .center
            case .centerImageLeft:
                configuration.imagePlacement = .leading
                configuration.titleAlignment = .center
            case .centerImageRight:
                configuration.imagePlacement = .trailing
                configuration.titleAlignment = .center
            case .centerImageBottom:
                configuration.imagePlacement = .bottom
                configuration.titleAlignment = .center
            case .leftImageLeft:
                configuration.imagePlacement = .leading
                configuration.titleAlignment = .leading
            case .leftImageRight:
                configuration.imagePlacement = .trailing
                configuration.titleAlignment = .leading
            case .rightImageLeft:
                configuration.imagePlacement = .leading
                configuration.titleAlignment = .trailing
            case .rightImageRight:
                configuration.imagePlacement = .trailing
                configuration.titleAlignment = .trailing
            }
            
            self.configuration = configuration
        } else {
            // 获取图片宽高
            let imageWidth: CGFloat = currentImage?.size.width ?? 0.0
            let imageHeight: CGFloat = currentImage?.size.height ?? 0.0
            
            // 获取文字宽高
            titleLabel?.sizeToFit()
            let textWidth: CGFloat = titleLabel?.frame.size.width ?? 0.0
            let textHeight: CGFloat = titleLabel?.frame.size.height ?? 0.0
            
            // 初始化变量
            var x: CGFloat = 0.0
            var y: CGFloat = 0.0
            let spaceValue: CGFloat = space/2
            
            // 根据不同类型设置不同的位置关系
            switch type {
            case .centerImageTop:
                x = textHeight / 2 + spaceValue
                y = textWidth / 2
                imageEdgeInsets = UIEdgeInsets(top: -x, left: y, bottom: x, right: -y)
                x = imageHeight / 2 + spaceValue
                y = imageWidth / 2
                titleEdgeInsets = UIEdgeInsets(top: x, left: -y, bottom: -x, right: y)
                
            case .centerImageLeft:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: -spaceValue, bottom: 0, right: spaceValue)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: spaceValue, bottom: 0, right: -spaceValue)
                
            case .centerImageRight:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: spaceValue + textWidth, bottom: 0, right: -(spaceValue + textWidth))
                titleEdgeInsets = UIEdgeInsets(top: 0, left: -(spaceValue + imageWidth), bottom: 0, right: (spaceValue + imageWidth))
                
            case .centerImageBottom:
                x = textHeight / 2 + spaceValue
                y = textWidth / 2
                imageEdgeInsets = UIEdgeInsets(top: x, left: y, bottom: -x, right: -y)
                x = imageHeight / 2 + spaceValue
                y = imageWidth / 2
                titleEdgeInsets = UIEdgeInsets(top: -x, left: -y, bottom: x, right: y)
                
            case .leftImageLeft:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: spaceValue, bottom: 0, right: 0)
                contentHorizontalAlignment = .left
                
            case .leftImageRight:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: textWidth + spaceValue, bottom: 0, right: 0)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: 0, right: 0)
                contentHorizontalAlignment = .left
                
            case .rightImageLeft:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spaceValue)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                contentHorizontalAlignment = .right
                
            case .rightImageRight:
                imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -textWidth)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: spaceValue, bottom: 0, right: imageWidth + spaceValue)
                contentHorizontalAlignment = .right
            }
        }
    }
}

// MARK: - 活动指示器相关扩展
extension UIButton {
    /// 关联键
    private struct AssociatedKeys {
        static var activityIndicatorViewKey = UnsafeRawPointer(bitPattern: "activityIndicatorViewKey".hashValue)!
        static var activityIndicatorEnabledKey = UnsafeRawPointer(bitPattern: "activityIndicatorEnabledKey".hashValue)!
        static var activityIndicatorColorKey = UnsafeRawPointer(bitPattern: "activityIndicatorColorKey".hashValue)!
    }
    
    /// 活动指示器视图
    private(set) var activityIndicatorView: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.activityIndicatorViewKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.activityIndicatorViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// 活动指示器启用状态
    var activityIndicatorEnabled: Bool {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.activityIndicatorEnabledKey) as? Bool ?? false
        }
        set {
            ensureActivityIndicator()
            objc_setAssociatedObject(self, AssociatedKeys.activityIndicatorEnabledKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            toggleActivityIndicator()
        }
    }
    
    /// 活动指示器颜色
    @objc dynamic var activityIndicatorColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.activityIndicatorColorKey) as? UIColor ?? titleColor(for: .normal)
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.activityIndicatorColorKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if activityIndicatorEnabled {
                activityIndicatorView?.color = newValue
            }
        }
    }
    
    /// 确保活动指示器已创建
    private func ensureActivityIndicator() {
        guard activityIndicatorView == nil else { return }
        
        let activityIndicatorView: UIActivityIndicatorView
        if #available(iOS 13, *) {
            activityIndicatorView = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicatorView = UIActivityIndicatorView(style: .white)
        }
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        self.activityIndicatorView = activityIndicatorView
    }
    
    /// 切换活动指示器状态
    private func toggleActivityIndicator() {
        DispatchQueue.main.async {
            self.isUserInteractionEnabled = !self.activityIndicatorEnabled
            
            if !self.activityIndicatorEnabled {
                self.activityIndicatorView?.stopAnimating()
            } else {
                self.activityIndicatorView?.color = self.activityIndicatorColor
            }
            
            UIView.animate(withDuration: 0.26, delay: 0, options: .curveEaseInOut, animations: {
                self.titleLabel?.alpha = self.activityIndicatorEnabled ? 0.0 : 1.0
            }, completion: { _ in
                if self.activityIndicatorEnabled {
                    self.activityIndicatorView?.startAnimating()
                }
            })
        }
    }
}

// MARK: - 背景色相关扩展
extension UIButton {
    /// 普通状态背景色
    @IBInspectable var normalStateBackgroundColor: UIColor? {
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .normal)
            }
        }
    }
    
    /// 禁用状态背景色
    @IBInspectable var disabledStateBackgroundColor: UIColor? {
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .disabled)
            }
        }
    }
    
    /// 高亮状态背景色
    @IBInspectable var highlightedStateBackgroundColor: UIColor? {
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .highlighted)
            }
        }
    }
    
    /// 选中状态背景色
    @IBInspectable var selectedStateBackgroundColor: UIColor? {
        get { return nil }
        set {
            if let color = newValue {
                setBackgroundColor(color, for: .selected)
            }
        }
    }
    
    /// 设置指定状态的背景色
    /// - Parameters:
    ///   - color: 背景颜色
    ///   - state: 按钮状态
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        if let image = UIImage.image(withPureColor: color, for: rect, rounded: false) {
            setBackgroundImage(image, for: state)
        }
    }
}

// MARK: - 实用工具扩展
extension UIButton {
    /// 标题图片位置是否反转
    var isTitleImagePositionReversed: Bool {
        get {
            return transform == .identity
        }
        set {
            let reversingTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = reversingTransform
            titleLabel?.transform = reversingTransform
            imageView?.transform = reversingTransform
        }
    }
    
    /// 背景图片视图
    var backgroundImageView: UIImageView? {
        return subviews.first {
            if let backgroundImageView = $0 as? UIImageView, backgroundImageView != imageView {
                return true
            }
            return false
        } as? UIImageView
    }
    
    /// 闭包包装器
    private class ButtonClosureWrapper {
        let closure: () -> Void
        
        init (_ closure: @escaping () -> Void) {
            self.closure = closure
        }
        
        @objc func invoke() {
            closure()
        }
    }
    
    /// 添加按钮事件
    /// - Parameters:
    ///   - controlEvent: 控制事件
    ///   - closure: 闭包回调
    func addAction(for controlEvent: UIControl.Event, closure: @escaping () -> Void) {
        let wrapper = ButtonClosureWrapper(closure)
        addTarget(wrapper, action: #selector(ButtonClosureWrapper.invoke), for: controlEvent)
        
        var possibleKey = "hessekit_ClosureWrapper_\(arc4random())"
        while objc_getAssociatedObject(self, (possibleKey)) != nil {
            possibleKey = "hessekit_ClosureWrapper_\(arc4random())"
        }
        
        objc_setAssociatedObject(self, (possibleKey), wrapper, .OBJC_ASSOCIATION_RETAIN)
    }
    
    /// 验证码倒计时显示
    /// - Parameter interval: 倒计时时间（秒）
    func timerStart(_ interval: Int = 60) {
        var time = interval
        let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
        codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
        codeTimer.setEventHandler {
            time -= 1
            DispatchQueue.main.async {
                self.isEnabled = time <= 0
                if time > 0 {
                    self.setTitle("剩余\(time)s", for: .normal)
                    return
                }
                codeTimer.cancel()
                self.setTitle("发送验证码", for: .normal)
            }
        }
        codeTimer.resume()
    }
}
