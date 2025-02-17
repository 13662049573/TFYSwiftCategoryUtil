//
//  TFYSwiftPopupView.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/6/6.
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
    
    // MARK: - Initialization
    public init(containerView: UIView, 
               contentView: UIView, 
               animator: TFYSwiftPopupViewAnimator = TFYSwiftFadeInOutAnimator(),
               configuration: TFYSwiftPopupViewConfiguration = TFYSwiftPopupViewConfiguration()) {
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
        isDismissible = configuration.isDismissible
        isInteractive = configuration.isInteractive
        isPenetrable = configuration.isPenetrable
        configureBackground(
            style: configuration.backgroundStyle,
            color: configuration.backgroundColor,
            blurStyle: configuration.blurStyle
        )
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
    
    public func display(animated: Bool, completion: (()->())? = nil) {
        guard !isAnimating else { return }
        
        isPresenting = true
        isAnimating = true
        
        setupConstraints()
        willDisplayCallback?()
        
        animator.display(contentView: contentView, 
                        backgroundView: backgroundView, 
                        animated: animated) { [weak self] in
            guard let self = self else { return }
            completion?()
            self.isAnimating = false
            self.didDisplayCallback?()
    }
        }
    
    public func dismiss(animated: Bool, completion: (()->())? = nil) {
        guard !isAnimating else { return }
        
        isAnimating = true
        willDismissCallback?()
        
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
}

// MARK: - Convenience Methods
public extension TFYSwiftPopupView {
    static func show(in viewController: UIViewController,
                    contentView: UIView,
                    configuration: TFYSwiftPopupViewConfiguration = TFYSwiftPopupViewConfiguration(),
                    animator: TFYSwiftPopupViewAnimator = TFYSwiftFadeInOutAnimator(),
                    animated: Bool = true,
                    completion: (() -> Void)? = nil) -> TFYSwiftPopupView {
        let popupView = TFYSwiftPopupView(containerView: viewController.view,
                                         contentView: contentView,
                                         animator: animator)
        popupView.configure(with: configuration)
        popupView.display(animated: animated, completion: completion)
        return popupView
    }
    
    static func show(contentView: UIView,
                    configuration: TFYSwiftPopupViewConfiguration = TFYSwiftPopupViewConfiguration(),
                    animator: TFYSwiftPopupViewAnimator = TFYSwiftFadeInOutAnimator(),
                    animated: Bool = true,
                    completion: (() -> Void)? = nil) {
        guard let window = getKeyWindow() else { return }
        
        let popupView = TFYSwiftPopupView(containerView: window,
                                         contentView: contentView,
                                         animator: animator)
        popupView.isDismissible = true
        popupView.display(animated: animated, completion: completion)
    }
}

// MARK: - Utilities
private extension TFYSwiftPopupView {
    static func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.keyWindow
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

// MARK: - Constraint Helpers
extension UIView {
    func widthConstraint(firstItem: UIView) -> NSLayoutConstraint? {
        return constraints.first { $0.firstAttribute == .width && $0.firstItem as? UIView == firstItem }
    }
    
    func heightConstraint(firstItem: UIView) -> NSLayoutConstraint? {
        return constraints.first { $0.firstAttribute == .height && $0.firstItem as? UIView == firstItem }
    }

    func centerXConstraint(firstItem: UIView) -> NSLayoutConstraint? {
        return constraints.first { $0.firstAttribute == .centerX && $0.firstItem as? UIView == firstItem }
    }

    func centerYConstraint(firstItem: UIView) -> NSLayoutConstraint? {
        return constraints.first { $0.firstAttribute == .centerY && $0.firstItem as? UIView == firstItem }
    }

    func topConstraint(firstItem: UIView) -> NSLayoutConstraint? {
        return constraints.first { $0.firstAttribute == .top && $0.firstItem as? UIView == firstItem }
    }

    func bottomConstraint(firstItem: UIView) -> NSLayoutConstraint? {
       return constraints.first { $0.firstAttribute == .bottom && $0.firstItem as? UIView == firstItem }
    }

    func leadingConstraint(firstItem: UIView) -> NSLayoutConstraint? {
        return constraints.first { $0.firstAttribute == .leading && $0.firstItem as? UIView == firstItem }
    }

    func trailingConstraint(firstItem: UIView) -> NSLayoutConstraint? {
       return constraints.first { $0.firstAttribute == .trailing && $0.firstItem as? UIView == firstItem }
    }
}

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

// MARK: - Configuration
extension TFYSwiftPopupView {
    public struct InteractionConfiguration {
        public var enableDragToDismiss: Bool
        public var dragDismissThreshold: CGFloat
        public var dragResistance: CGFloat
        public var bounceBackVelocityThreshold: CGFloat
        
        public static let `default` = InteractionConfiguration(
            enableDragToDismiss: true,
            dragDismissThreshold: 0.3,
            dragResistance: 1.0,
            bounceBackVelocityThreshold: 1000
        )
    }
    
    public struct AnimationConfiguration {
        public var duration: TimeInterval
        public var springDamping: CGFloat
        public var springVelocity: CGFloat
        public var options: UIView.AnimationOptions
        
        public static let `default` = AnimationConfiguration(
            duration: 0.3,
            springDamping: 0.8,
            springVelocity: 0.2,
            options: .curveEaseOut
        )
    }
}

// MARK: - Transition Coordinator
extension TFYSwiftPopupView {
    final class TransitionCoordinator {
        private weak var popupView: TFYSwiftPopupView?
        private var currentAnimation: UIViewPropertyAnimator?
        
        init(popupView: TFYSwiftPopupView) {
            self.popupView = popupView
        }
        
        func animate(withDuration duration: TimeInterval,
                    delay: TimeInterval = 0,
                    dampingRatio: CGFloat = 1,
                    velocity: CGFloat = 0,
                    options: UIView.AnimationOptions = [],
                    animations: @escaping () -> Void,
                    completion: ((Bool) -> Void)? = nil) {
            // 取消当前动画
            currentAnimation?.stopAnimation(true)
            
            // 创建新动画
            let animator = UIViewPropertyAnimator(
                duration: duration,
                dampingRatio: dampingRatio,
                animations: animations
            )
            
            animator.addCompletion { position in
                completion?(position == .end)
                self.currentAnimation = nil
            }
            
            currentAnimation = animator
            animator.startAnimation(afterDelay: delay)
        }
        
        func cancelCurrentAnimation() {
            currentAnimation?.stopAnimation(true)
            currentAnimation = nil
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

// MARK: - Additional Animators
open class TFYSwiftSpringAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        // 配置弹簧动画参数
        displaySpringDampingRatio = 0.7
        displaySpringVelocity = 0.3

        contentView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        backgroundView.alpha = 0

        displayAnimationBlock = {
            contentView.alpha = 1
            contentView.transform = .identity
            backgroundView.alpha = 1
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            backgroundView.alpha = 0
        }
    }
}

open class TFYSwiftBounceAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)

        contentView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        backgroundView.alpha = 0

        displayAnimationBlock = {
            UIView.animateKeyframes(withDuration: self.displayDuration, delay: 0, options: .calculationModeCubic) {
                // 关键帧1：快速放大超过目标大小
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                    contentView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            contentView.alpha = 1
            backgroundView.alpha = 1
                }
                
                // 关键帧2：回弹到正常大小
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                    contentView.transform = .identity
                }
            }
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            backgroundView.alpha = 0
        }
    }
}

open class TFYSwiftRotationAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(rotationAngle: .pi)
        backgroundView.alpha = 0
        
        displayAnimationBlock = {
            contentView.alpha = 1
            contentView.transform = .identity
            backgroundView.alpha = 1
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(rotationAngle: -.pi)
            backgroundView.alpha = 0
        }
    }
}

open class TFYSwiftPulseAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        backgroundView.alpha = 0
        
        displayAnimationBlock = {
            UIView.animateKeyframes(withDuration: self.displayDuration, delay: 0, options: .calculationModeCubic) {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                    contentView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    contentView.alpha = 1
                    backgroundView.alpha = 1
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
                    contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
                    contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                    contentView.transform = .identity
                }
            }
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            backgroundView.alpha = 0
        }
    }
}

// MARK: - Providing Default Implementations
public extension TFYSwiftPopupViewDelegate {
    func popupViewWillAppear(_ popupView: TFYSwiftPopupView) {}
    func popupViewDidAppear(_ popupView: TFYSwiftPopupView) {}
    func popupViewWillDisappear(_ popupView: TFYSwiftPopupView) {}
    func popupViewDidDisappear(_ popupView: TFYSwiftPopupView) {}
    func popupViewDidReceiveMemoryWarning(_ popupView: TFYSwiftPopupView) {}
}

// MARK: - Additional Animation Effects
open class TFYSwiftCascadeAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        // 初始状态
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: -50).concatenating(CGAffineTransform(scaleX: 0.8, y: 0.8))
        backgroundView.alpha = 0
        
        displayAnimationBlock = {
            UIView.animateKeyframes(withDuration: self.displayDuration, delay: 0, options: .calculationModeCubic) {
                // 第一阶段：下落并放大
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                    contentView.transform = CGAffineTransform(translationX: 0, y: 10).concatenating(CGAffineTransform(scaleX: 1.1, y: 1.1))
                    contentView.alpha = 1
                    backgroundView.alpha = 1
                }
                
                // 第二阶段：轻微回弹
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                    contentView.transform = .identity
                }
            }
        }
        
        dismissAnimationBlock = {
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(translationX: 0, y: 50).concatenating(CGAffineTransform(scaleX: 0.8, y: 0.8))
            backgroundView.alpha = 0
        }
    }
}

open class TFYSwiftElasticAnimator: TFYSwiftBaseAnimator {
    open override func setup(popupView: TFYSwiftPopupView, contentView: UIView, backgroundView: TFYSwiftPopupView.BackgroundView) {
        super.setup(popupView: popupView, contentView: contentView, backgroundView: backgroundView)
        
        displaySpringDampingRatio = 0.5
        displaySpringVelocity = 0.8
        
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        backgroundView.alpha = 0
        
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

// MARK: - Custom Transition
public struct TFYSwiftPopupTransition {
    public var presentDuration: TimeInterval = 0.3
    public var dismissDuration: TimeInterval = 0.3
    public var presentTimingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    public var dismissTimingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    
    public var presentAnimation: CAAnimation?
    public var dismissAnimation: CAAnimation?
    
    public static func createFadeTransition() -> TFYSwiftPopupTransition {
        var transition = TFYSwiftPopupTransition()
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0
        fadeIn.toValue = 1
        transition.presentAnimation = fadeIn
        
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        transition.dismissAnimation = fadeOut
        
        return transition
    }
    
    public static func createScaleTransition() -> TFYSwiftPopupTransition {
        var transition = TFYSwiftPopupTransition()
        
        let scaleIn = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleIn.values = [0.3, 1.1, 0.9, 1.0]
        scaleIn.keyTimes = [0, 0.6, 0.8, 1.0]
        transition.presentAnimation = scaleIn
        
        let scaleOut = CABasicAnimation(keyPath: "transform.scale")
        scaleOut.fromValue = 1.0
        scaleOut.toValue = 0.3
        transition.dismissAnimation = scaleOut
        
        return transition
    }
}

extension TFYSwiftPopupView {
    private func setupContainerConstraints() {
        let config = configuration.containerConfiguration
        
        // 设置宽度约束
        switch config.width {
        case .fixed(let width):
            contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        case .automatic:
            break // 不设置宽度约束，由内容决定
        case .ratio(let ratio):
            contentView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: ratio).isActive = true
        case .custom(let handler):
            contentView.widthAnchor.constraint(equalToConstant: handler(contentView)).isActive = true
        }
        
        // 设置高度约束
        switch config.height {
        case .fixed(let height):
            contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
        case .automatic:
            break // 不设置高度约束，由内容决定
        case .ratio(let ratio):
            contentView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: ratio).isActive = true
        case .custom(let handler):
            contentView.heightAnchor.constraint(equalToConstant: handler(contentView)).isActive = true
        }
        
        // 设置最大/最小尺寸约束
        if let maxWidth = config.maxWidth {
            contentView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
        }
        if let maxHeight = config.maxHeight {
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight).isActive = true
        }
        if let minWidth = config.minWidth {
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth).isActive = true
        }
        if let minHeight = config.minHeight {
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight).isActive = true
        }
        
        // 设置内容边距
        let insets = config.contentInsets
        if let stackView = contentView.subviews.first as? UIStackView {
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom)
            ])
        }
    }
}
