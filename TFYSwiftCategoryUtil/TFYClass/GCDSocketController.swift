//
//  GCDSocketController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2025/1/24.
//

/*
 TFYSwiftPopupView 完整功能展示控制器
 
 本控制器展示了 TFYSwiftPopupView 的所有功能：
 
 1. 配置类型 (Configuration Types)
    - KeyboardConfiguration: 键盘配置
    - ContainerConfiguration: 容器配置
    - TFYSwiftPopupViewConfiguration: 主配置
 
 2. 协议 (Protocols)
    - TFYSwiftPopupViewAnimator: 动画器协议
    - TFYSwiftPopupViewDelegate: 代理协议
 
 3. 动画器 (Animators)
    - TFYSwiftFadeInOutAnimator: 淡入淡出
    - TFYSwiftZoomInOutAnimator: 缩放动画
    - TFYSwift3DFlipAnimator: 3D翻转
    - TFYSwiftBounceAnimator: 弹性动画
    - TFYSwiftSlideAnimator: 滑动动画
    - TFYSwiftRotateAnimator: 旋转动画
    - TFYSwiftSpringAnimator: 弹簧动画
    - TFYSwiftBottomSheetAnimator: 底部弹出框
    - 方向动画器: Upward, Downward, Leftward, Rightward
 
 4. 实用方法 (Utility Methods)
    - showAlert: 警告弹窗
    - showConfirm: 确认弹窗
    - showLoading: 加载弹窗
    - showSuccess: 成功提示
    - showError: 错误提示
    - showBottomSheet: 底部弹出框
 
 5. 高级功能
    - 键盘适配
    - 主题支持
    - 手势支持
    - 无障碍支持
    - 触觉反馈
    - 多弹窗管理
    - 内存管理
    - 代理回调
 */

import UIKit

class GCDSocketController: UIViewController {
    
    // MARK: - Properties
    private var currentPopupView: TFYSwiftPopupView?
    private var loadingPopupView: TFYSwiftPopupView?
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        setupButtons()
    }
    
    private func setupNavigationBar() {
        title = "TFYSwiftPopupView 功能展示"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupButtons() {
        // 1. 基本功能展示
        addSection(title: "📱 基本功能")
        addButton(title: "基本弹窗", action: #selector(showBasicPopup))
        addButton(title: "自定义内容弹窗", action: #selector(showCustomContentPopup))
        addButton(title: "配置弹窗", action: #selector(showConfiguredPopup))
        addButton(title: "简单测试弹窗", action: #selector(showSimpleTestPopup))
        addButton(title: "安全测试弹窗", action: #selector(showSafeTestPopup))
        
        // 2. 动画器展示
        addSection(title: "🎬 动画效果")
        addButton(title: "淡入淡出动画", action: #selector(showFadeAnimation))
        addButton(title: "缩放动画", action: #selector(showZoomAnimation))
        addButton(title: "3D翻转动画", action: #selector(show3DFlipAnimation))
        addButton(title: "弹性动画", action: #selector(showBounceAnimation))
        addButton(title: "滑动动画", action: #selector(showSlideAnimation))
        addButton(title: "旋转动画", action: #selector(showRotateAnimation))
        addButton(title: "弹簧动画", action: #selector(showSpringAnimation))
        
        // 3. 方向动画
        addSection(title: "➡️ 方向动画")
        addButton(title: "从上方滑入", action: #selector(showUpwardAnimation))
        addButton(title: "从下方滑入", action: #selector(showDownwardAnimation))
        addButton(title: "从左侧滑入", action: #selector(showLeftwardAnimation))
        addButton(title: "从右侧滑入", action: #selector(showRightwardAnimation))
        
        // 4. 底部弹出框
        addSection(title: "📋 底部弹出框")
        addButton(title: "简单底部弹出框", action: #selector(showSimpleBottomSheet))
        addButton(title: "自定义底部弹出框", action: #selector(showCustomBottomSheet))
        addButton(title: "全屏底部弹出框", action: #selector(showFullScreenBottomSheet))
        
        // 5. 实用方法
        addSection(title: "🛠️ 实用方法")
        addButton(title: "警告弹窗", action: #selector(showAlert))
        addButton(title: "确认弹窗", action: #selector(showConfirm))
        addButton(title: "加载弹窗", action: #selector(showLoading))
        addButton(title: "成功提示", action: #selector(showSuccess))
        addButton(title: "错误提示", action: #selector(showError))
        
        // 6. 高级功能
        addSection(title: "⚡ 高级功能")
        addButton(title: "键盘适配弹窗", action: #selector(showKeyboardPopup))
        addButton(title: "主题弹窗", action: #selector(showThemePopup))
        addButton(title: "手势弹窗", action: #selector(showGesturePopup))
        addButton(title: "代理弹窗", action: #selector(showDelegatePopup))
        addButton(title: "多弹窗管理", action: #selector(showMultiplePopups))
        
        // 7. 背景效果
        addSection(title: "🎨 背景效果")
        addButton(title: "模糊背景", action: #selector(showBlurBackground))
        addButton(title: "渐变背景", action: #selector(showGradientBackground))
        addButton(title: "自定义背景", action: #selector(showCustomBackground))
        
        // 8. 布局展示
        addSection(title: "📐 布局展示")
        addButton(title: "顶部布局", action: #selector(showTopLayout))
        addButton(title: "底部布局", action: #selector(showBottomLayout))
        addButton(title: "左侧布局", action: #selector(showLeadingLayout))
        addButton(title: "右侧布局", action: #selector(showTrailingLayout))
        addButton(title: "固定尺寸", action: #selector(showFixedSizeLayout))
        
        // 9. 清理功能
        addSection(title: "🧹 清理功能")
        addButton(title: "关闭所有弹窗", action: #selector(dismissAllPopups))
        addButton(title: "显示弹窗数量", action: #selector(showPopupCount))
    }
    
    // MARK: - Helper Methods
    private func addSection(title: String) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        contentStackView.addArrangedSubview(containerView)
    }
    
    private func addButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        contentStackView.addArrangedSubview(button)
    }
    
    // MARK: - 基本功能展示
    @objc private func showBasicPopup() {
        let customView = createCustomView(title: "基本弹窗", message: "这是一个基本的弹窗示例")
        
        print("显示基本弹窗")
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animated: true
        ) {
            print("基本弹窗显示完成")
        }
    }
    
    @objc private func showCustomContentPopup() {
        print("开始创建自定义内容弹窗")
        
        // 创建一个简单的测试视图
        let testView = createSimpleTestView()
        
        var config = TFYSwiftPopupViewConfiguration()
        config.isDismissible = true
        config.tapOutsideToDismiss = true
        config.enableHapticFeedback = true
        config.maxPopupCount = 5 // 确保这个值大于0
        
        // 添加容器配置
        var containerConfig = ContainerConfiguration()
        containerConfig.width = .fixed(300)
        containerConfig.height = .automatic
        containerConfig.cornerRadius = 12
        containerConfig.shadowEnabled = true
        containerConfig.shadowColor = .black
        containerConfig.shadowOpacity = 0.2
        containerConfig.shadowRadius = 8
        config.containerConfiguration = containerConfig
        
        // 验证配置
        let isValid = config.validate()
        print("配置验证结果: \(isValid)")
        
        if !isValid {
            print("配置验证失败，使用默认配置")
            config = TFYSwiftPopupViewConfiguration()
        }
        
        print("准备显示弹窗")
        currentPopupView = TFYSwiftPopupView.show(
            contentView: testView,
            configuration: config,
            animated: true
        ) {
            print("弹窗显示完成")
        }
        
        print("弹窗创建完成")
    }
    
    @objc private func showConfiguredPopup() {
        let customView = createCustomView(title: "配置弹窗", message: "这是一个高度配置的弹窗")
        
        // 键盘配置
        var keyboardConfig = KeyboardConfiguration()
        keyboardConfig.isEnabled = true
        keyboardConfig.avoidingMode = .transform
        keyboardConfig.additionalOffset = 20
        
        // 容器配置
        var containerConfig = ContainerConfiguration()
        containerConfig.width = .fixed(320)
        containerConfig.height = .automatic
        containerConfig.cornerRadius = 16
        containerConfig.shadowEnabled = true
        containerConfig.shadowColor = .black
        containerConfig.shadowOpacity = 0.3
        containerConfig.shadowRadius = 10
        
        // 主配置
        var config = TFYSwiftPopupViewConfiguration()
        config.keyboardConfiguration = keyboardConfig
        config.containerConfiguration = containerConfig
        config.maxPopupCount = 5
        config.enableDragToDismiss = true
        config.dragDismissThreshold = 0.3
        config.theme = .current
        config.enableAccessibility = true
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    @objc private func showSimpleTestPopup() {
        print("开始简单测试弹窗")
        
        // 创建一个最简单的视图
        let simpleView = UIView()
        simpleView.backgroundColor = .systemBackground
        simpleView.layer.cornerRadius = 8
        simpleView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "简单测试"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        simpleView.addSubview(label)
        
        NSLayoutConstraint.activate([
            simpleView.widthAnchor.constraint(equalToConstant: 200),
            simpleView.heightAnchor.constraint(equalToConstant: 100),
            label.centerXAnchor.constraint(equalTo: simpleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: simpleView.centerYAnchor)
        ])
        
        print("使用默认配置显示弹窗")
        let popup = TFYSwiftPopupView.show(
            contentView: simpleView,
            animated: true
        ) {
            print("简单测试弹窗显示完成")
        }
        
        currentPopupView = popup
        print("简单测试弹窗创建完成")
    }
    
    @objc private func showSafeTestPopup() {
        print("开始安全测试弹窗")
        
        // 创建一个最简单的视图
        let simpleView = UIView()
        simpleView.backgroundColor = .systemBackground
        simpleView.layer.cornerRadius = 8
        simpleView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "安全测试"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        simpleView.addSubview(label)
        
        NSLayoutConstraint.activate([
            simpleView.widthAnchor.constraint(equalToConstant: 200),
            simpleView.heightAnchor.constraint(equalToConstant: 100),
            label.centerXAnchor.constraint(equalTo: simpleView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: simpleView.centerYAnchor)
        ])
        
        // 使用最安全的配置
        var config = TFYSwiftPopupViewConfiguration()
        config.isDismissible = true
        config.tapOutsideToDismiss = true
        config.maxPopupCount = 5
        config.autoDismissDelay = 0
        config.dragDismissThreshold = 0.3
        config.animationDuration = 0.25
        
        // 验证配置
        let isValid = config.validate()
        print("安全测试配置验证结果: \(isValid)")
        
        if !isValid {
            print("配置验证失败，使用系统默认配置")
            config = TFYSwiftPopupViewConfiguration()
        }
        
        print("使用安全配置显示弹窗")
        let popup = TFYSwiftPopupView.show(
            contentView: simpleView,
            configuration: config,
            animated: true
        ) {
            print("安全测试弹窗显示完成")
        }
        
        currentPopupView = popup
        print("安全测试弹窗创建完成")
    }
    
    // MARK: - 动画效果展示
    @objc private func showFadeAnimation() {
        let customView = createCustomView(title: "淡入淡出", message: "使用淡入淡出动画效果")
        
        let animator = TFYSwiftFadeInOutAnimator()
        animator.displayDuration = 0.5
        animator.dismissDuration = 0.3
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showZoomAnimation() {
        let customView = createCustomView(title: "缩放动画", message: "使用缩放动画效果")
        
        let animator = TFYSwiftZoomInOutAnimator()
        animator.displayDuration = 0.4
        animator.dismissDuration = 0.3
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func show3DFlipAnimation() {
        let customView = createCustomView(title: "3D翻转", message: "使用3D翻转动画效果")
        
        let animator = TFYSwift3DFlipAnimator()
        animator.displayDuration = 0.6
        animator.dismissDuration = 0.4
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showBounceAnimation() {
        let customView = createCustomView(title: "弹性动画", message: "使用弹性动画效果")
        
        let animator = TFYSwiftBounceAnimator()
        animator.displaySpringDampingRatio = 0.6
        animator.displaySpringVelocity = 0.8
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showSlideAnimation() {
        let customView = createCustomView(title: "滑动动画", message: "从底部滑入的动画效果")
        
        let animator = TFYSwiftSlideAnimator(direction: .fromBottom)
        animator.displayDuration = 0.4
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showRotateAnimation() {
        print("GCDSocketController: 显示旋转动画弹窗")
        let customView = createCustomView(title: "旋转动画", message: "使用旋转动画效果")
        
        let animator = TFYSwiftRotateAnimator()
        // 不覆盖动画时间，使用动画器默认设置
        print("GCDSocketController: 使用旋转动画器")
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showSpringAnimation() {
        let customView = createCustomView(title: "弹簧动画", message: "使用弹簧动画效果")
        
        let animator = TFYSwiftSpringAnimator()
        animator.displaySpringDampingRatio = 0.7
        animator.displaySpringVelocity = 0.5
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    // MARK: - 方向动画展示
    @objc private func showUpwardAnimation() {
        let customView = createCustomView(title: "从上方滑入", message: "从屏幕上方滑入的动画")
        
        let animator = TFYSwiftUpwardAnimator()
        animator.displayDuration = 0.4
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showDownwardAnimation() {
        let customView = createCustomView(title: "从下方滑入", message: "从屏幕下方滑入的动画")
        
        let animator = TFYSwiftDownwardAnimator()
        animator.displayDuration = 0.4
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showLeftwardAnimation() {
        let customView = createCustomView(title: "从左侧滑入", message: "从屏幕左侧滑入的动画")
        
        let animator = TFYSwiftLeftwardAnimator()
        animator.displayDuration = 0.4
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showRightwardAnimation() {
        let customView = createCustomView(title: "从右侧滑入", message: "从屏幕右侧滑入的动画")
        
        let animator = TFYSwiftRightwardAnimator()
        animator.displayDuration = 0.4
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    // MARK: - 底部弹出框展示
    @objc private func showSimpleBottomSheet() {
        let customView = createCustomView(title: "底部弹出框", message: "这是一个简单的底部弹出框示例")
        
        currentPopupView = TFYSwiftPopupView.showBottomSheet(
            contentView: customView,
            animated: true
        )
    }
    
    @objc private func showCustomBottomSheet() {
        let customView = createComplexCustomView()
        
        var config = TFYSwiftBottomSheetAnimator.Configuration()
        config.defaultHeight = 400
        config.minimumHeight = 150
        config.maximumHeight = 600
        config.allowsFullScreen = true
        config.snapToDefaultThreshold = 80
        config.springDamping = 0.8
        config.springVelocity = 0.4
        config.animationDuration = 0.35
        config.dismissThreshold = 60
        
        currentPopupView = TFYSwiftPopupView.showBottomSheet(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    @objc private func showFullScreenBottomSheet() {
        let customView = createComplexCustomView()
        
        var config = TFYSwiftBottomSheetAnimator.Configuration()
        config.defaultHeight = 300
        config.maximumHeight = UIScreen.main.bounds.height
        config.allowsFullScreen = true
        
        currentPopupView = TFYSwiftPopupView.showBottomSheet(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    // MARK: - 实用方法展示
    @objc private func showAlert() {
        _ = TFYSwiftPopupView.showAlert(
            title: "提示",
            message: "这是一个警告弹窗示例，点击确定按钮关闭。",
            buttonTitle: "知道了",
            animated: true
        ) {
            print("警告弹窗已关闭")
        }
    }
    
    @objc private func showConfirm() {
        _ = TFYSwiftPopupView.showConfirm(
            title: "确认操作",
            message: "确定要执行这个操作吗？",
            confirmTitle: "确定",
            cancelTitle: "取消",
            animated: true,
            onConfirm: {
                print("用户确认了操作")
                TFYSwiftPopupView.showSuccess(message: "操作已确认！")
            },
            onCancel: {
                print("用户取消了操作")
                TFYSwiftPopupView.showError(message: "操作已取消")
            }
        )
    }
    
    @objc private func showLoading() {
        loadingPopupView = TFYSwiftPopupView.showLoading(
            message: "正在加载数据...",
            animated: true
        )
        
        // 3秒后自动关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.loadingPopupView?.dismiss(animated: true)
        }
    }
    
    @objc private func showSuccess() {
        _ = TFYSwiftPopupView.showSuccess(
            message: "操作成功完成！",
            duration: 2.0,
            animated: true
        )
    }
    
    @objc private func showError() {
        _ = TFYSwiftPopupView.showError(
            message: "操作失败，请重试",
            duration: 3.0,
            animated: true
        )
    }
    
    // MARK: - 高级功能展示
    @objc private func showKeyboardPopup() {
        let customView = createKeyboardTestView()
        
        var keyboardConfig = KeyboardConfiguration()
        keyboardConfig.isEnabled = true
        keyboardConfig.avoidingMode = .transform
        keyboardConfig.additionalOffset = 20
        keyboardConfig.animationDuration = 0.25
        keyboardConfig.respectSafeArea = true
        
        var config = TFYSwiftPopupViewConfiguration()
        config.keyboardConfiguration = keyboardConfig
        config.isDismissible = true
        config.tapOutsideToDismiss = true
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    @objc private func showThemePopup() {
        let customView = createCustomView(title: "主题弹窗", message: "支持深色/浅色主题切换")
        
        var config = TFYSwiftPopupViewConfiguration()
        config.theme = .current // 自动适配系统主题
        config.enableAccessibility = true
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    @objc private func showGesturePopup() {
        let customView = createCustomView(title: "手势弹窗", message: "支持拖拽关闭手势")
        
        var config = TFYSwiftPopupViewConfiguration()
        config.enableDragToDismiss = true
        config.dragDismissThreshold = 0.3
        config.enableHapticFeedback = true
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    @objc private func showDelegatePopup() {
        let customView = createCustomView(title: "代理弹窗", message: "使用代理回调功能")
        
        let popupView = TFYSwiftPopupView.show(
            contentView: customView,
            animated: true
        )
        
        popupView.delegate = self
    }
    
    @objc private func showMultiplePopups() {
        // 显示多个弹窗
        for i in 1...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                let customView = self.createCustomView(
                    title: "弹窗 \(i)",
                    message: "这是第 \(i) 个弹窗"
                )
                
                _ = TFYSwiftPopupView.show(
                    contentView: customView,
                    animated: true
                )
            }
        }
        
        // 显示当前弹窗数量
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let count = TFYSwiftPopupView.currentPopupCount
            _ = TFYSwiftPopupView.showAlert(
                title: "弹窗数量",
                message: "当前显示弹窗数量: \(count)",
                buttonTitle: "知道了"
            )
        }
    }
    
    // MARK: - 背景效果展示
    @objc private func showBlurBackground() {
        print("GCDSocketController: 显示模糊背景弹窗")
        let customView = createCustomView(title: "模糊背景", message: "使用模糊背景效果")
        
        var config = TFYSwiftPopupViewConfiguration()
        config.backgroundStyle = TFYSwiftPopupView.BackgroundView.BackgroundStyle.blur
        config.blurStyle = .dark
        print("GCDSocketController: 背景配置 - style: \(config.backgroundStyle)")
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    @objc private func showGradientBackground() {
        print("GCDSocketController: 显示渐变背景弹窗")
        let customView = createCustomView(title: "渐变背景", message: "使用渐变背景效果")
        
        var config = TFYSwiftPopupViewConfiguration()
        config.backgroundStyle = TFYSwiftPopupView.BackgroundView.BackgroundStyle.gradient
        print("GCDSocketController: 背景配置 - style: \(config.backgroundStyle)")
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    @objc private func showCustomBackground() {
        print("GCDSocketController: 显示自定义背景弹窗")
        let customView = createCustomView(title: "自定义背景", message: "使用自定义背景效果")
        
        var config = TFYSwiftPopupViewConfiguration()
        config.backgroundStyle = TFYSwiftPopupView.BackgroundView.BackgroundStyle.custom { backgroundView in
            print("GCDSocketController: 执行自定义背景设置")
            backgroundView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.8)
        }
        print("GCDSocketController: 背景配置 - style: \(config.backgroundStyle)")
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            configuration: config,
            animated: true
        )
    }
    
    // MARK: - 布局展示
    @objc private func showTopLayout() {
        let customView = createCustomView(title: "顶部布局", message: "弹窗显示在屏幕顶部")
        
        let animator = TFYSwiftBaseAnimator(layout: .top(.init(topMargin: 100)))
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showBottomLayout() {
        let customView = createCustomView(title: "底部布局", message: "弹窗显示在屏幕底部")
        
        let animator = TFYSwiftBaseAnimator(layout: .bottom(.init(bottomMargin: 100)))
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showLeadingLayout() {
        let customView = createCustomView(title: "左侧布局", message: "弹窗显示在屏幕左侧")
        
        let animator = TFYSwiftBaseAnimator(layout: .leading(.init(leadingMargin: 20)))
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showTrailingLayout() {
        let customView = createCustomView(title: "右侧布局", message: "弹窗显示在屏幕右侧")
        
        let animator = TFYSwiftBaseAnimator(layout: .trailing(.init(trailingMargin: 20)))
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    @objc private func showFixedSizeLayout() {
        let customView = createCustomView(title: "固定尺寸", message: "使用固定尺寸的弹窗")
        
        let animator = TFYSwiftBaseAnimator(layout: .center(.init(width: 300, height: 200)))
        
        currentPopupView = TFYSwiftPopupView.show(
            contentView: customView,
            animator: animator,
            animated: true
        )
    }
    
    // MARK: - 清理功能
    @objc private func dismissAllPopups() {
        TFYSwiftPopupView.dismissAll(animated: true) {
            print("所有弹窗已关闭")
        }
    }
    
    @objc private func showPopupCount() {
        let count = TFYSwiftPopupView.currentPopupCount
        _ = TFYSwiftPopupView.showAlert(
            title: "弹窗统计",
            message: "当前显示弹窗数量: \(count)",
            buttonTitle: "知道了"
        )
    }
    
    // MARK: - Helper Methods
    private func createCustomView(title: String, message: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        stackView.addArrangedSubview(messageLabel)
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        closeButton.backgroundColor = UIColor.systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(closeButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            
            // 修复按钮约束，移除固定宽度约束，让按钮自适应内容
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        return containerView
    }
    
    private func createComplexCustomView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "复杂内容弹窗"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        // 描述
        let descriptionLabel = UILabel()
        descriptionLabel.text = "这是一个包含多种UI元素的复杂弹窗，展示了TFYSwiftPopupView的强大功能。"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        stackView.addArrangedSubview(descriptionLabel)
        
        // 图片
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
        
        // 按钮组 - 修复约束冲突
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        stackView.addArrangedSubview(buttonStackView)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.backgroundColor = UIColor.systemGray5
        cancelButton.setTitleColor(.systemGray, for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        buttonStackView.addArrangedSubview(cancelButton)
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.backgroundColor = UIColor.systemBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped(_:)), for: .touchUpInside)
        buttonStackView.addArrangedSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // 修复图片约束，移除固定宽度约束
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            // 修复按钮约束，移除固定宽度约束，只设置高度
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            confirmButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return containerView
    }
    
    private func createKeyboardTestView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = "键盘测试"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "点击输入框测试键盘适配功能"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        stackView.addArrangedSubview(descriptionLabel)
        
        let textField = UITextField()
        textField.placeholder = "请输入内容..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        closeButton.backgroundColor = UIColor.systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(closeButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            
            // 修复约束冲突，移除固定宽度约束
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        return containerView
    }
    
    private func createSimpleTestView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = "简单测试弹窗"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        let messageLabel = UILabel()
        messageLabel.text = "这是一个简单的测试弹窗，用于验证基本功能。"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        stackView.addArrangedSubview(messageLabel)
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(closeButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        
        return containerView
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        if let popupView = sender.findPopupView() {
            popupView.dismiss(animated: true)
        }
    }
    
    @objc private func confirmButtonTapped(_ sender: UIButton) {
        if let popupView = sender.findPopupView() {
            popupView.dismiss(animated: true)
        }
        TFYSwiftPopupView.showSuccess(message: "操作已确认！")
    }
}

// MARK: - TFYSwiftPopupViewDelegate
extension GCDSocketController: TFYSwiftPopupViewDelegate {
    
    func popupViewWillAppear(_ popupView: TFYSwiftPopupView) {
        print("弹窗即将显示")
    }
    
    func popupViewDidAppear(_ popupView: TFYSwiftPopupView) {
        print("弹窗已显示")
    }
    
    func popupViewWillDisappear(_ popupView: TFYSwiftPopupView) {
        print("弹窗即将消失")
    }
    
    func popupViewDidDisappear(_ popupView: TFYSwiftPopupView) {
        print("弹窗已消失")
    }
    
    func popupViewDidReceiveMemoryWarning(_ popupView: TFYSwiftPopupView) {
        print("弹窗收到内存警告")
    }
    
    func popupViewShouldDismiss(_ popupView: TFYSwiftPopupView) -> Bool {
        print("检查是否可以消失弹窗")
        return true
    }
    
    func popupViewDidTapBackground(_ popupView: TFYSwiftPopupView) {
        print("用户点击了背景")
    }
    
    func popupViewDidSwipeToDismiss(_ popupView: TFYSwiftPopupView) {
        print("用户滑动关闭了弹窗")
    }
    
    func popupViewDidDragToDismiss(_ popupView: TFYSwiftPopupView) {
        print("用户拖拽关闭了弹窗")
    }
}

// MARK: - UIView Extension
private extension UIView {
    func findPopupView() -> TFYSwiftPopupView? {
        var currentView: UIView? = self
        while currentView != nil {
            if let popupView = currentView as? TFYSwiftPopupView {
                return popupView
            }
            currentView = currentView?.superview
        }
        return nil
    }
}


