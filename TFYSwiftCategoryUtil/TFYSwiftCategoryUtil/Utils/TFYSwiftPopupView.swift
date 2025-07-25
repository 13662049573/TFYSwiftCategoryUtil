//
//  TFYSwiftPopupView.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/6/6.
//  用途：通用弹窗视图，支持多种动画、手势、键盘适配、配置灵活。
//

import UIKit

// MARK: - Configuration Types
public struct KeyboardConfiguration {
    public var isEnabled: Bool = false
    public var avoidingMode: KeyboardAvoidingMode = .transform
    public var additionalOffset: CGFloat = 10
    
    public enum KeyboardAvoidingMode {
        case transform  // 使用变换来避开键盘
        case constraint // 使用约束来避开键盘
        case resize    // 调整大小来避开键盘
    }
    
    public init() {}
}

public struct ContainerConfiguration {
    public var width: ContainerDimension = .fixed(280)
    public var height: ContainerDimension = .automatic
    public var maxWidth: CGFloat?
    public var maxHeight: CGFloat?
    public var minWidth: CGFloat?
    public var minHeight: CGFloat?
    public var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    public enum ContainerDimension {
        case fixed(CGFloat)
        case automatic
        case ratio(CGFloat) // 相对于屏幕宽度/高度的比例
        case custom((UIView) -> CGFloat)
    }
    
    public init() {}
}

// MARK: - Configuration
public struct TFYSwiftPopupViewConfiguration {
    public var isDismissible: Bool = false
    public var isInteractive: Bool = true
    public var isPenetrable: Bool = false
    public var backgroundStyle: TFYSwiftPopupView.BackgroundView.BackgroundStyle = .solidColor
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    public var blurStyle: UIBlurEffect.Style = .dark
    public var animationDuration: TimeInterval = 0.25
    public var respectsSafeArea: Bool = true
    public var safeAreaInsets: UIEdgeInsets = .zero
    public var enableDragToDismiss: Bool = false
    public var dragDismissThreshold: CGFloat = 0.3
    
    public var keyboardConfiguration: KeyboardConfiguration = KeyboardConfiguration()
    public var cornerRadius: CGFloat = 0
    public var shadowConfiguration = ShadowConfiguration()
    public var tapOutsideToDismiss = true
    public var swipeToDismiss = true
    public var dismissOnBackgroundTap = true
    public var dismissWhenAppGoesToBackground = true
    
    public var containerConfiguration = ContainerConfiguration()
    
    public init() {}
    
    public struct ShadowConfiguration {
        public var isEnabled: Bool = false
        public var color: UIColor = .black
        public var opacity: Float = 0.3
        public var radius: CGFloat = 5
        public var offset: CGSize = .zero
        
        public init() {}
    }
}

// MARK: - Protocols
public protocol TFYSwiftPopupViewAnimator {
    /// 初始化配置动画驱动器
    ///
    /// - Parameters:
    ///   - popupView: TFYSwiftPopupView
    ///   - contentView: 自定义的弹框视图
    ///   - backgroundView: 背景视图
    /// - Returns: void
    func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView)


    /// 横竖屏切换的时候，刷新布局
    /// - Parameters:
    ///   - popupView: TFYSwiftPopupView
    ///   - contentView: 自定义的弹框视图
    func refreshLayout(popupView: TFYSwiftPopupView, contentView: UIView)

    /// 处理展示动画
    ///
    /// - Parameters:
    ///   - contentView: 自定义的弹框视图
    ///   - backgroundView: 背景视图
    ///   - animated: 是否需要动画
    ///   - completion: 动画完成后的回调
    /// - Returns: void
    func display(contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView, animated: Bool, completion: @escaping ()->())

    /// 处理消失动画
    ///
    /// - Parameters:
    ///   - contentView: 自定义的弹框视图
    ///   - backgroundView: 背景视图
    ///   - animated: 是否需要动画
    ///   - completion: 动画完成后的回调
    func dismiss(contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView, animated: Bool, completion: @escaping ()->())
}

public protocol TFYSwiftPopupViewDelegate: AnyObject {
    func popupViewWillAppear(_ popupView: TFYSwiftPopupView)
    func popupViewDidAppear(_ popupView: TFYSwiftPopupView)
    func popupViewWillDisappear(_ popupView: TFYSwiftPopupView)
    func popupViewDidDisappear(_ popupView: TFYSwiftPopupView)
    func popupViewDidReceiveMemoryWarning(_ popupView: TFYSwiftPopupView)
}

// MARK: - Main PopupView Class
public class TFYSwiftPopupView: UIView {

    // MARK: - Public Properties
    public var isDismissible: Bool {
        didSet { backgroundView.isUserInteractionEnabled = isDismissible }
    }
    public var isInteractive: Bool
    public var isPenetrable: Bool
    public private(set) var isPresenting: Bool
    public let backgroundView: BackgroundView
    
    // MARK: - Callbacks
    public var willDisplayCallback: (()->())?
    public var didDisplayCallback: (()->())?
    public var willDismissCallback: (()->())?
    public var didDismissCallback: (()->())?

    // MARK: - Private Properties
    private unowned let containerView: UIView
    private let contentView: UIView
    private let animator: TFYSwiftPopupViewAnimator
    private var isAnimating = false
    private var configuration: TFYSwiftPopupViewConfiguration
    
    private var keyboardAdjustmentConstraint: NSLayoutConstraint?
    
    private var containerConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Static Properties
    private static var currentPopupViews: [TFYSwiftPopupView] = []
    
    // MARK: - Initialization
    public init(containerView: UIView, 
               contentView: UIView, 
               animator: TFYSwiftPopupViewAnimator = TFYSwiftFadeInOutAnimator(),
               configuration: TFYSwiftPopupViewConfiguration = TFYSwiftPopupViewConfiguration()) {
        assert(contentView.superview == nil, "TFYSwiftPopupView: contentView 已经被添加到其他视图")
        if contentView.superview != nil {
            print("TFYSwiftPopupView: contentView 已经被添加到其他视图，可能导致布局异常")
        }
        self.containerView = containerView
        self.contentView = contentView
        self.animator = animator
        self.backgroundView = BackgroundView(frame: containerView.bounds)
        self.configuration = configuration
        self.isDismissible = configuration.isDismissible
        self.isInteractive = configuration.isInteractive
        self.isPenetrable = configuration.isPenetrable
        self.isPresenting = false
        
        super.init(frame: containerView.bounds)

        setupView()
        setupGestures()
        setupAccessibility()
        setupKeyboardHandling()
        setupContainerConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundView.isUserInteractionEnabled = isDismissible
        backgroundView.addTarget(self, action: #selector(backgroundViewClicked), for: .touchUpInside)
        addSubview(backgroundView)
        addSubview(contentView)

        animator.setup(popupView: self, contentView: contentView, backgroundView: backgroundView)
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        animator.refreshLayout(popupView: self, contentView: contentView)
    }

    // MARK: - Hit Testing
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointInContent = convert(point, to: contentView)
        let isPointInContent = contentView.bounds.contains(pointInContent)
        
        if isPointInContent {
            return isInteractive ? super.hitTest(point, with: event) : nil
        } else {
            return isPenetrable ? nil : super.hitTest(point, with: event)
        }
    }
    
    // MARK: - Public Methods
    @discardableResult
    public func configure(with configuration: TFYSwiftPopupViewConfiguration) -> Self {
        self.configuration = configuration
        isDismissible = configuration.isDismissible
        isInteractive = configuration.isInteractive
        isPenetrable = configuration.isPenetrable
        configureBackground(
            style: configuration.backgroundStyle,
            color: configuration.backgroundColor,
            blurStyle: configuration.blurStyle
        )
        setupContainerConstraints()
        return self
    }
    
    @discardableResult
    public func configureBackground(style: BackgroundView.BackgroundStyle = .solidColor,
                                  color: UIColor = UIColor.black.withAlphaComponent(0.3),
                                  blurStyle: UIBlurEffect.Style = .dark) -> Self {
        backgroundView.style = style
        backgroundView.color = color
        backgroundView.blurEffectStyle = blurStyle
        return self
    }
    
    public func display(animated: Bool, completion: (() -> Void)? = nil) {
        performDisplay(animated: animated, completion: completion)
    }
    
    public func dismiss(animated: Bool, completion: (()->())? = nil) {
        guard !isAnimating else { return }
        
        isAnimating = true
        willDismissCallback?()
        
        // 从当前显示的弹窗数组中移除
        TFYSwiftPopupView.currentPopupViews.removeAll { $0 === self }
        
        animator.dismiss(contentView: contentView, 
                        backgroundView: backgroundView, 
                        animated: animated) { [weak self] in
            guard let self = self else { return }
            self.isPresenting = false
            self.cleanup()
            completion?()
            self.isAnimating = false
            self.didDismissCallback?()
        }
    }
    
    // MARK: - Private Methods
    private func setupConstraints() {
        containerView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    private func cleanup() {
        contentView.removeFromSuperview()
        removeFromSuperview()
    }
    
    @objc private func backgroundViewClicked() {
        dismiss(animated: true)
    }
    
    private func setupKeyboardHandling() {
        guard configuration.keyboardConfiguration.isEnabled else { return }
        
        // 创建键盘调整约束
        keyboardAdjustmentConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        keyboardAdjustmentConstraint?.isActive = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let contentFrame = contentView.convert(contentView.bounds, to: nil)
        let overlap = contentFrame.maxY - (bounds.height - keyboardHeight)
        
        if overlap > 0 {
            let offset = overlap + configuration.keyboardConfiguration.additionalOffset
            
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve)) {
                switch self.configuration.keyboardConfiguration.avoidingMode {
                case .transform:
                    self.contentView.transform = CGAffineTransform(translationX: 0, y: -offset)
                case .constraint:
                    // 更新约束
                    self.keyboardAdjustmentConstraint?.constant = -offset
                    self.layoutIfNeeded()
                case .resize:
                    self.frame.size.height = self.bounds.height - keyboardHeight
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve)) {
            switch self.configuration.keyboardConfiguration.avoidingMode {
            case .transform:
                self.contentView.transform = .identity
            case .constraint:
                self.keyboardAdjustmentConstraint?.constant = 0
                self.layoutIfNeeded()
            case .resize:
                self.frame.size = self.bounds.size
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupContainerConstraints() {
        // 检查是否为底部弹出框动画器，如果是则跳过容器约束设置
        if animator is TFYSwiftBottomSheetAnimator {
            return // 底部弹出框使用自己的约束系统
        }
        
        // 移除旧的约束
        NSLayoutConstraint.deactivate(containerConstraints)
        containerConstraints.removeAll()
        
        let config = configuration.containerConfiguration
        
        // 确保 contentView 已经添加到视图层级中
        guard contentView.superview != nil else { return }
        
        // 设置宽度约束
        switch config.width {
        case .fixed(let width):
            containerConstraints.append(
                contentView.widthAnchor.constraint(equalToConstant: width)
            )
        case .automatic:
            if let maxWidth = config.maxWidth {
                containerConstraints.append(
                    contentView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth)
                )
            }
        case .ratio(let ratio):
            containerConstraints.append(
                contentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio)
            )
        case .custom(let handler):
            containerConstraints.append(
                contentView.widthAnchor.constraint(equalToConstant: handler(contentView))
            )
        }
        
        // 设置高度约束
        switch config.height {
        case .fixed(let height):
            containerConstraints.append(
                contentView.heightAnchor.constraint(equalToConstant: height)
            )
        case .automatic:
            if let maxHeight = config.maxHeight {
                containerConstraints.append(
                    contentView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight)
                )
            }
        case .ratio(let ratio):
            containerConstraints.append(
                contentView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio)
            )
        case .custom(let handler):
            containerConstraints.append(
                contentView.heightAnchor.constraint(equalToConstant: handler(contentView))
            )
        }
        
        // 设置最小尺寸约束
        if let minWidth = config.minWidth {
            containerConstraints.append(
                contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth)
            )
        }
        if let minHeight = config.minHeight {
            containerConstraints.append(
                contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
            )
        }
        
        // 激活所有约束
        NSLayoutConstraint.activate(containerConstraints)
    }
}

// MARK: - Convenience Methods
public extension TFYSwiftPopupView {
    static func show(contentView: UIView,
                    configuration: TFYSwiftPopupViewConfiguration = TFYSwiftPopupViewConfiguration(),
                    animator: TFYSwiftPopupViewAnimator = TFYSwiftFadeInOutAnimator(),
                    animated: Bool = true,
                    completion: (() -> Void)? = nil) -> TFYSwiftPopupView {
        // 获取当前窗口（兼容 iOS 15 及以上版本）
        let window: UIWindow? = {
            if #available(iOS 15.0, *) {
                return UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }
            } else {
                return UIApplication.shared.windows.first { $0.isKeyWindow }
            }
        }()
        
        guard let window = window else {
            return TFYSwiftPopupView(containerView: UIView(), contentView: contentView)
        }
        
        // 创建弹窗
        let popupView = TFYSwiftPopupView(
            containerView: window,
            contentView: contentView,
            animator: animator,
            configuration: configuration
        )
        
        // 设置frame和autoresizing
        popupView.frame = window.bounds
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 添加到窗口
        window.addSubview(popupView)
        
        // 添加到当前显示的弹窗数组
        currentPopupViews.append(popupView)
        
        // 显示弹窗
        popupView.display(animated: animated) {
            completion?()
        }
        
        return popupView
    }
    
    static func dismissAll(animated: Bool = true, completion: (() -> Void)? = nil) {
        let popups = currentPopupViews
        currentPopupViews.removeAll()
        
        guard !popups.isEmpty else {
            completion?()
            return
        }
        
        let group = DispatchGroup()
        
        for popup in popups {
            group.enter()
            popup.dismiss(animated: animated) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion?()
        }
    }
}

// MARK: - Private Methods
private extension TFYSwiftPopupView {
    func setupInitialLayout() {
        // 检查是否为底部弹出框动画器，如果是则跳过center约束设置
        if animator is TFYSwiftBottomSheetAnimator {
            return // 底部弹出框使用自己的约束系统
        }
        
        // 设置内容视图的中心约束（仅用于非底部弹出框）
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func performDisplay(animated: Bool, completion: (() -> Void)? = nil) {
        guard !isAnimating else { return }
        
        isPresenting = true
        isAnimating = true
        
        // 确保视图已添加到容器中
        if superview == nil {
            containerView.addSubview(self)
            frame = containerView.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        // 设置约束
        setupInitialLayout()
        setupContainerConstraints()
        
        // 调用显示回调
        willDisplayCallback?()
        
        // 执行动画
        animator.display(contentView: contentView,
                        backgroundView: backgroundView,
                        animated: animated) { [weak self] in
            guard let self = self else { return }
            completion?()
            self.isAnimating = false
            self.didDisplayCallback?()
    }
    }
}

// MARK: - BackgroundView
extension TFYSwiftPopupView {
    public class BackgroundView: UIControl {
        public enum BackgroundStyle {
            case solidColor
            case blur
            case gradient
            case custom((BackgroundView) -> Void)
        }
        
        public enum BackgroundEffect {
            case none
            case blur(style: UIBlurEffect.Style)
            case gradient(colors: [UIColor], locations: [NSNumber]?)
            case dimmed(color: UIColor, alpha: CGFloat)
            case custom((BackgroundView) -> Void)
        }
        
        // MARK: - Properties
        public var style: BackgroundStyle = .solidColor {
            didSet { refreshBackgroundStyle() }
        }
        
        public var color: UIColor = UIColor.black.withAlphaComponent(0.3) {
            didSet { backgroundColor = color }
        }
        
        public var blurEffectStyle: UIBlurEffect.Style = .dark {
            didSet { refreshBackgroundStyle() }
        }
        
        public var gradientColors: [UIColor] = [
            UIColor.black.withAlphaComponent(0.5),
            UIColor.black.withAlphaComponent(0.3)
        ] {
            didSet { refreshBackgroundStyle() }
        }
        
        public var gradientLocations: [NSNumber]? = [0.0, 1.0] {
            didSet { refreshBackgroundStyle() }
        }
        
        public var gradientStartPoint: CGPoint = CGPoint(x: 0.5, y: 0) {
            didSet { refreshBackgroundStyle() }
        }
        
        public var gradientEndPoint: CGPoint = CGPoint(x: 0.5, y: 1) {
            didSet { refreshBackgroundStyle() }
        }
        
        // MARK: - Private Properties
        private var effectView: UIVisualEffectView?
        private var gradientLayer: CAGradientLayer?
        
        // MARK: - Initialization
        public override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private Methods
        private func setupView() {
            backgroundColor = color
            layer.allowsGroupOpacity = false
            refreshBackgroundStyle()
        }
        
        private func refreshBackgroundStyle() {
            // 清除现有效果
                effectView?.removeFromSuperview()
                effectView = nil
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
            
            switch style {
            case .solidColor:
                backgroundColor = color
                
            case .blur:
                effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffectStyle))
                effectView?.frame = bounds
                insertSubview(effectView!, at: 0)
                
            case .gradient:
                gradientLayer = CAGradientLayer()
                gradientLayer?.frame = bounds
                gradientLayer?.colors = gradientColors.map { $0.cgColor }
                gradientLayer?.locations = gradientLocations
                gradientLayer?.startPoint = gradientStartPoint
                gradientLayer?.endPoint = gradientEndPoint
                layer.insertSublayer(gradientLayer!, at: 0)
                
            case .custom(let customization):
                customization(self)
            }
        }
        
        // MARK: - Layout
        public override func layoutSubviews() {
            super.layoutSubviews()
            effectView?.frame = bounds
            gradientLayer?.frame = bounds
        }
        
        public func applyEffect(_ effect: BackgroundEffect) {
            switch effect {
            case .none:
                backgroundColor = .clear
                
            case .blur(let style):
                let blurEffect = UIBlurEffect(style: style)
                let blurView = UIVisualEffectView(effect: blurEffect)
                blurView.frame = bounds
                addSubview(blurView)
                
            case .gradient(let colors, let locations):
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = bounds
                gradientLayer.colors = colors.map { $0.cgColor }
                gradientLayer.locations = locations
                layer.addSublayer(gradientLayer)
                
            case .dimmed(let color, let alpha):
                backgroundColor = color.withAlphaComponent(alpha)
                
            case .custom(let customization):
                customization(self)
            }
        }
    }
}

public extension UIView {
    func popupView() -> TFYSwiftPopupView? {
        if self.superview?.isKind(of: TFYSwiftPopupView.self) == true {
            return self.superview as? TFYSwiftPopupView
        }
        return nil
    }
}

// MARK: - Base Animator
open class TFYSwiftBaseAnimator: TFYSwiftPopupViewAnimator {
    // MARK: - Public Properties
    open var layout: Layout
    open var displayDuration: TimeInterval = 0.25
    open var displayAnimationOptions: UIView.AnimationOptions = .curveEaseInOut
    open var displaySpringDampingRatio: CGFloat?
    open var displaySpringVelocity: CGFloat?
    open var displayAnimationBlock: (()->())?

    open var dismissDuration: TimeInterval = 0.25
    open var dismissAnimationOptions: UIView.AnimationOptions = .curveEaseInOut
    open var dismissSpringDampingRatio: CGFloat?
    open var dismissSpringVelocity: CGFloat?
    open var dismissAnimationBlock: (()->())?

    // MARK: - Initialization
    public init(layout: Layout = .center(.init())) {
        self.layout = layout
    }
    
    // MARK: - TFYSwiftPopupViewAnimator
    open func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        setupLayout(popupView: popupView, contentView: contentView)
    }
    
    open func refreshLayout(popupView: TFYSwiftPopupView, contentView: UIView) {
        if case .frame(let frame) = layout {
            contentView.frame = frame
        }
    }
    
    open func display(contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView, animated: Bool, completion: @escaping () -> ()) {
        if animated {
            if let dampingRatio = displaySpringDampingRatio,
               let velocity = displaySpringVelocity {
                UIView.animate(
                    withDuration: displayDuration,
                    delay: 0,
                    usingSpringWithDamping: dampingRatio,
                    initialSpringVelocity: velocity,
                    options: displayAnimationOptions,
                    animations: { self.displayAnimationBlock?() },
                    completion: { _ in completion() }
                )
            } else {
                UIView.animate(
                    withDuration: displayDuration,
                    delay: 0,
                    options: displayAnimationOptions,
                    animations: { self.displayAnimationBlock?() },
                    completion: { _ in completion() }
                )
            }
        } else {
            displayAnimationBlock?()
            completion()
        }
    }
    
    open func dismiss(contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView, animated: Bool, completion: @escaping () -> ()) {
        if animated {
            if let dampingRatio = dismissSpringDampingRatio,
               let velocity = dismissSpringVelocity {
                UIView.animate(
                    withDuration: dismissDuration,
                    delay: 0,
                    usingSpringWithDamping: dampingRatio,
                    initialSpringVelocity: velocity,
                    options: dismissAnimationOptions,
                    animations: { self.dismissAnimationBlock?() },
                    completion: { _ in completion() }
                )
            } else {
                UIView.animate(
                    withDuration: dismissDuration,
                    delay: 0,
                    options: dismissAnimationOptions,
                    animations: { self.dismissAnimationBlock?() },
                    completion: { _ in completion() }
                )
            }
        } else {
            dismissAnimationBlock?()
            completion()
        }
    }
    
    // MARK: - Private Methods
    private func setupLayout(popupView: TFYSwiftPopupView, contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        switch layout {
        case .center(let center):
            setupCenterLayout(popupView: popupView, contentView: contentView, center: center)
        case .top(let top):
            setupTopLayout(popupView: popupView, contentView: contentView, top: top)
        case .bottom(let bottom):
            setupBottomLayout(popupView: popupView, contentView: contentView, bottom: bottom)
        case .leading(let leading):
            setupLeadingLayout(popupView: popupView, contentView: contentView, leading: leading)
        case .trailing(let trailing):
            setupTrailingLayout(popupView: popupView, contentView: contentView, trailing: trailing)
        case .frame(let frame):
            contentView.frame = frame
            contentView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    private func setupCenterLayout(popupView: TFYSwiftPopupView, contentView: UIView, center: Layout.Center) {
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor, constant: center.offsetX),
            contentView.centerYAnchor.constraint(equalTo: popupView.centerYAnchor, constant: center.offsetY)
        ])
        
        if let width = center.width {
            contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = center.height {
            contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    private func setupTopLayout(popupView: TFYSwiftPopupView, contentView: UIView, top: Layout.Top) {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: top.topMargin),
            contentView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor, constant: top.offsetX)
        ])
        
        if let width = top.width {
            contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = top.height {
            contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    private func setupBottomLayout(popupView: TFYSwiftPopupView, contentView: UIView, bottom: Layout.Bottom) {
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -bottom.bottomMargin),
            contentView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor, constant: bottom.offsetX)
        ])
        
        if let width = bottom.width {
            contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = bottom.height {
            contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    private func setupLeadingLayout(popupView: TFYSwiftPopupView, contentView: UIView, leading: Layout.Leading) {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: leading.leadingMargin),
            contentView.centerYAnchor.constraint(equalTo: popupView.centerYAnchor, constant: leading.offsetY)
        ])
        
        if let width = leading.width {
            contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = leading.height {
            contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    private func setupTrailingLayout(popupView: TFYSwiftPopupView, contentView: UIView, trailing: Layout.Trailing) {
        NSLayoutConstraint.activate([
            contentView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -trailing.trailingMargin),
            contentView.centerYAnchor.constraint(equalTo: popupView.centerYAnchor, constant: trailing.offsetY)
        ])
        
        if let width = trailing.width {
            contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = trailing.height {
            contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    private func getSafeAreaInsets(for popupView: TFYSwiftPopupView) -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return popupView.safeAreaInsets
        }
        return .zero
    }
    
    private func adjustForSafeArea(_ constant: CGFloat, edge: UIRectEdge, popupView: TFYSwiftPopupView) -> CGFloat {
        let safeAreaInsets = getSafeAreaInsets(for: popupView)
        switch edge {
        case .top: return constant + safeAreaInsets.top
        case .bottom: return constant + safeAreaInsets.bottom
        case .left: return constant + safeAreaInsets.left
        case .right: return constant + safeAreaInsets.right
        default: return constant
        }
    }
}

// MARK: - Layout Types
extension TFYSwiftBaseAnimator {
    public enum Layout {
        case center(Center)
        case top(Top)
        case bottom(Bottom)
        case leading(Leading)
        case trailing(Trailing)
        case frame(CGRect)

        func offsetX() -> CGFloat {
            switch self {
            case .center(let center): return center.offsetX
            case .top(let top): return top.offsetX
            case .bottom(let bottom): return bottom.offsetX
            case .leading(_), .trailing(_), .frame(_): return 0
            }
        }

        func offsetY() -> CGFloat {
            switch self {
            case .center(let center): return center.offsetY
            case .leading(let leading): return leading.offsetY
            case .trailing(let trailing): return trailing.offsetY
            case .top(_), .bottom(_), .frame(_): return 0
            }
        }
        
        // Layout structs...
        public struct Center {
            public var offsetY: CGFloat
            public var offsetX: CGFloat
            public var width: CGFloat?
            public var height: CGFloat?

            public init(offsetY: CGFloat = 0, offsetX: CGFloat = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
                self.offsetY = offsetY
                self.offsetX = offsetX
                self.width = width
                self.height = height
            }
        }

        public struct Top {
            public var topMargin: CGFloat
            public var offsetX: CGFloat
            public var width: CGFloat?
            public var height: CGFloat?

            public init(topMargin: CGFloat = 0, offsetX: CGFloat = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
                self.topMargin = topMargin
                self.offsetX = offsetX
                self.width = width
                self.height = height
            }
        }

        public struct Bottom {
            public var bottomMargin: CGFloat
            public var offsetX: CGFloat
            public var width: CGFloat?
            public var height: CGFloat?

            public init(bottomMargin: CGFloat = 0, offsetX: CGFloat = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
                self.bottomMargin = bottomMargin
                self.offsetX = offsetX
                self.width = width
                self.height = height
            }
        }

        public struct Leading {
            public var leadingMargin: CGFloat
            public var offsetY: CGFloat
            public var width: CGFloat?
            public var height: CGFloat?

            public init(leadingMargin: CGFloat = 0, offsetY: CGFloat = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
                self.leadingMargin = leadingMargin
                self.offsetY = offsetY
                self.width = width
                self.height = height
            }
        }

        public struct Trailing {
            public var trailingMargin: CGFloat
            public var offsetY: CGFloat
            public var width: CGFloat?
            public var height: CGFloat?

            public init(trailingMargin: CGFloat = 0, offsetY: CGFloat = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
                self.trailingMargin = trailingMargin
                self.offsetY = offsetY
                self.width = width
                self.height = height
            }
        }
    }
}

// MARK: - Specific Animators
open class TFYSwiftFadeInOutAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        contentView.alpha = 0
        backgroundView.alpha = 0
        
        displayAnimationBlock = {
            contentView.alpha = 1
            backgroundView.alpha = 1
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            backgroundView.alpha = 0
        }
    }
}

open class TFYSwiftZoomInOutAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        contentView.alpha = 0
        backgroundView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        displayAnimationBlock = {
            contentView.alpha = 1
            contentView.transform = .identity
            backgroundView.alpha = 1
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            backgroundView.alpha = 0
        }
    }
}

open class TFYSwift3DFlipAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        contentView.alpha = 0
        backgroundView.alpha = 0
        contentView.layer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
        
        displayAnimationBlock = {
            contentView.alpha = 1
            contentView.layer.transform = CATransform3DIdentity
            backgroundView.alpha = 1
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.layer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
            backgroundView.alpha = 0
        }
    }
}

// MARK: - Directional Animators
open class TFYSwiftDirectionalAnimator: TFYSwiftBaseAnimator {
    func getInitialTransform(for popupView: TFYSwiftPopupView, contentView: UIView) -> CGAffineTransform {
        .identity
    }
    
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        let initialTransform = getInitialTransform(for: popupView, contentView: contentView)
        contentView.transform = initialTransform
        contentView.alpha = 0
        backgroundView.alpha = 0
        
        displayAnimationBlock = {
            contentView.transform = .identity
            contentView.alpha = 1
            backgroundView.alpha = 1
        }
        
        dismissAnimationBlock = {
            contentView.transform = initialTransform
            contentView.alpha = 0
            backgroundView.alpha = 0
        }
    }
}

open class TFYSwiftUpwardAnimator: TFYSwiftDirectionalAnimator {
    override func getInitialTransform(for popupView: TFYSwiftPopupView, contentView: UIView) -> CGAffineTransform {
        return CGAffineTransform(translationX: 0, y: popupView.bounds.height)
    }
}

open class TFYSwiftDownwardAnimator: TFYSwiftDirectionalAnimator {
    override func getInitialTransform(for popupView: TFYSwiftPopupView, contentView: UIView) -> CGAffineTransform {
        return CGAffineTransform(translationX: 0, y: -popupView.bounds.height)
    }
}

open class TFYSwiftLeftwardAnimator: TFYSwiftDirectionalAnimator {
    override func getInitialTransform(for popupView: TFYSwiftPopupView, contentView: UIView) -> CGAffineTransform {
        return CGAffineTransform(translationX: popupView.bounds.width, y: 0)
    }
}

open class TFYSwiftRightwardAnimator: TFYSwiftDirectionalAnimator {
    override func getInitialTransform(for popupView: TFYSwiftPopupView, contentView: UIView) -> CGAffineTransform {
        return CGAffineTransform(translationX: -popupView.bounds.width, y: 0)
    }
}

// MARK: - Bottom Sheet Animator

public class TFYSwiftBottomSheetAnimator: TFYSwiftPopupViewAnimator {
    public struct Configuration {
        public var defaultHeight: CGFloat = 300
        public var minimumHeight: CGFloat = 100
        public var maximumHeight: CGFloat = UIScreen.main.bounds.height
        public var allowsFullScreen: Bool = true
        public var snapToDefaultThreshold: CGFloat = 80
        public var springDamping: CGFloat = 0.8
        public var springVelocity: CGFloat = 0.4
        public var animationDuration: TimeInterval = 0.35
        public var dismissThreshold: CGFloat = 60
        public init() {}
    }
    
    public let configuration: Configuration
    private weak var popupView: TFYSwiftPopupView?
    private weak var contentView: UIView?
    private weak var backgroundView: TFYSwiftPopupView.BackgroundView?
    private var panGesture: UIPanGestureRecognizer?
    private var currentHeight: CGFloat = 0
    private var isDragging = false
    private var initialTouchPoint: CGPoint = .zero
    private var initialFrame: CGRect = .zero
    
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    public func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        self.popupView = popupView
        self.contentView = contentView
        self.backgroundView = backgroundView
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        setupLayout(popupView: popupView, contentView: contentView)
        addPanGesture(to: contentView)
    }
    
    public func refreshLayout(popupView: TFYSwiftPopupView, contentView: UIView) {
        // 可根据需要刷新布局
    }
    
    public func display(contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView, animated: Bool, completion: @escaping () -> ()) {
        guard let popupView = popupView else { completion(); return }
        let height = configuration.defaultHeight
        let y = popupView.bounds.height
        contentView.frame = CGRect(x: 0, y: y, width: popupView.bounds.width, height: height)
        backgroundView.alpha = 0
        UIView.animate(withDuration: configuration.animationDuration, delay: 0, usingSpringWithDamping: configuration.springDamping, initialSpringVelocity: configuration.springVelocity, options: .curveEaseOut) {
            contentView.frame = CGRect(x: 0, y: popupView.bounds.height - height, width: popupView.bounds.width, height: height)
            backgroundView.alpha = 1
        } completion: { _ in
            completion()
        }
    }
    
    public func dismiss(contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView, animated: Bool, completion: @escaping () -> ()) {
        guard let popupView = popupView else { completion(); return }
        let y = popupView.bounds.height
        UIView.animate(withDuration: configuration.animationDuration, delay: 0, options: .curveEaseIn) {
            contentView.frame.origin.y = y
            backgroundView.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    
    private func setupLayout(popupView: TFYSwiftPopupView, contentView: UIView) {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: configuration.minimumHeight),
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: configuration.maximumHeight)
        ])
    }
    
    private func addPanGesture(to view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(pan)
        self.panGesture = pan
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let popupView = popupView, let contentView = contentView else { return }
        let translation = gesture.translation(in: popupView)
        let velocity = gesture.velocity(in: popupView)
        switch gesture.state {
        case .began:
            isDragging = true
            initialTouchPoint = gesture.location(in: popupView)
            initialFrame = contentView.frame
        case .changed:
            let newY = max(initialFrame.origin.y + translation.y, popupView.bounds.height - configuration.maximumHeight)
            let maxY = popupView.bounds.height - configuration.minimumHeight
            if newY <= maxY {
                contentView.frame.origin.y = newY
            }
        case .ended, .cancelled:
            isDragging = false
            let moved = contentView.frame.origin.y - (popupView.bounds.height - configuration.defaultHeight)
            if moved > configuration.dismissThreshold || velocity.y > 1000 {
                // 关闭
                popupView.dismiss(animated: true)
            } else if abs(moved) > configuration.snapToDefaultThreshold && configuration.allowsFullScreen && velocity.y < 0 {
                // 全屏展开
                UIView.animate(withDuration: configuration.animationDuration, delay: 0, usingSpringWithDamping: configuration.springDamping, initialSpringVelocity: configuration.springVelocity, options: .curveEaseOut) {
                    contentView.frame.origin.y = popupView.bounds.height - self.configuration.maximumHeight
                    contentView.frame.size.height = self.configuration.maximumHeight
                }
            } else {
                // 回弹到默认高度
                UIView.animate(withDuration: configuration.animationDuration, delay: 0, usingSpringWithDamping: configuration.springDamping, initialSpringVelocity: configuration.springVelocity, options: .curveEaseOut) {
                    contentView.frame.origin.y = popupView.bounds.height - self.configuration.defaultHeight
                    contentView.frame.size.height = self.configuration.defaultHeight
                }
            }
        default:
            break
        }
    }
}

// MARK: - Constraint Helpers
// 删除UIView的widthConstraint、heightConstraint等约束查找扩展

// MARK: - Gesture Support
extension TFYSwiftPopupView {
    private func setupGestures() {
        guard configuration.enableDragToDismiss else { return }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        contentView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            handlePanBegan()
        case .changed:
            handlePanChanged(translation: translation)
        case .ended, .cancelled:
            handlePanEnded(translation: translation, velocity: velocity)
        default:
            break
        }
    }
    
    private func handlePanBegan() {
        // 停止任何正在进行的动画
        layer.removeAllAnimations()
        contentView.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
    }
    
    private func handlePanChanged(translation: CGPoint) {
        let dragDistance = translation.y
        let progress = abs(dragDistance / bounds.height)
        
        // 应用拖动变换
        contentView.transform = CGAffineTransform(translationX: 0, y: dragDistance)
        
        // 更新背景透明度
        backgroundView.alpha = 1 - (progress * 0.8) // 保留一些最小透明度
    }
    
    private func handlePanEnded(translation: CGPoint, velocity: CGPoint) {
        let dragDistance = translation.y
        let progress = abs(dragDistance / bounds.height)
        
        if progress > configuration.dragDismissThreshold || abs(velocity.y) > 1000 {
            // 完成消失动画
            let remainingDistance = bounds.height - abs(dragDistance)
            let duration = TimeInterval(remainingDistance / abs(velocity.y))
            
            UIView.animate(withDuration: min(duration, 0.3), delay: 0, options: .curveEaseOut) {
                self.contentView.transform = CGAffineTransform(translationX: 0, y: dragDistance > 0 ? self.bounds.height : -self.bounds.height)
                self.backgroundView.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }
        } else {
            // 恢复原位
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut) {
                self.contentView.transform = .identity
                self.backgroundView.alpha = 1
            }
        }
    }
}

// MARK: - Accessibility
extension TFYSwiftPopupView {
    private func setupAccessibility() {
        isAccessibilityElement = false
        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = .allowsDirectInteraction
        
        if #available(iOS 13.0, *) {
            contentView.accessibilityRespondsToUserInteraction = true
        }
    }
}

// MARK: - Spring Animator
open class TFYSwiftSpringAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        contentView.alpha = 0
        backgroundView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        displayAnimationBlock = {
            contentView.alpha = 1
            contentView.transform = .identity
            backgroundView.alpha = 1
        }
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            backgroundView.alpha = 0
        }
    }
}

// MARK: - Bottom Sheet PopupView Convenience
public extension TFYSwiftPopupView {
    @discardableResult
    static func showBottomSheet(
        contentView: UIView,
        configuration: TFYSwiftBottomSheetAnimator.Configuration = TFYSwiftBottomSheetAnimator.Configuration(),
        popupConfig: TFYSwiftPopupViewConfiguration = TFYSwiftPopupViewConfiguration(),
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> TFYSwiftPopupView {
        let animator = TFYSwiftBottomSheetAnimator(configuration: configuration)
        return TFYSwiftPopupView.show(
            contentView: contentView,
            configuration: popupConfig,
            animator: animator,
            animated: animated,
            completion: completion
        )
    }
}
