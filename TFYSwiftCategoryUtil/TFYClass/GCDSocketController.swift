//
//  GCDSocketController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2025/1/24.
//

/*
 底部弹出框使用示例：
 
 1. 简单使用：
 ```swift
 let controller = GCDSocketController()
 controller.showSimpleBottomSheet(
     title: "提示",
     message: "这是一个简单的底部弹出框"
 )
 ```
 
 2. 使用自定义内容视图：
 ```swift
 let customView = YourCustomView()
 controller.showBottomSheet(contentView: customView)
 ```
 
 3. 自定义配置：
 ```swift
 var config = TFYSwiftBottomSheetAnimator.Configuration()
 config.defaultHeight = 400
 config.minimumHeight = 150
 config.allowsFullScreen = true
 config.snapToDefaultThreshold = 80
 
 controller.showBottomSheet(
     contentView: customView,
     configuration: config
 )
 ```
 
 4. 直接使用便利方法：
 ```swift
 TFYSwiftPopupView.showBottomSheet(
     contentView: yourView,
     configuration: configuration
 )
 ```
 
 特性说明：
 - ✨ 从底部弹出，支持设置默认高度
 - 🔄 可向上滑动到全屏（可配置）
 - ⬇️ 向下滑动到最低值会自动关闭
 - 🎯 中间位置松手会自动回弹到默认高度
 - ⚡ 支持快速滑动手势
 - 🎨 支持多种背景效果
 - 📱 完美适配iPhone和iPad
 - 🔧 灵活的配置选项
 */

import UIKit

class GCDSocketController: UIViewController {
    
    // MARK: - Properties
    private var currentPopupView: TFYSwiftPopupView?
   
    private let sections: [(title: String, items: [PopupItem])] = [
        ("基础动画", [
            PopupItem(title: "淡入淡出", style: .fade),
            PopupItem(title: "缩放", style: .zoom),
            PopupItem(title: "3D翻转", style: .flip),
            PopupItem(title: "弹性", style: .spring)
        ]),
        ("方向动画", [
            PopupItem(title: "向上弹出", style: .upward),
            PopupItem(title: "向下弹出", style: .downward),
            PopupItem(title: "向左弹出", style: .leftward),
            PopupItem(title: "向右弹出", style: .rightward)
        ]),
        ("位置展示", [
            PopupItem(title: "顶部展示", style: .top),
            PopupItem(title: "底部展示", style: .bottom),
            PopupItem(title: "左侧展示", style: .leading),
            PopupItem(title: "右侧展示", style: .trailing),
            PopupItem(title: "居中展示", style: .center)
        ]),
        ("底部弹出框", [
            PopupItem(title: "默认底部弹出框", style: .bottomSheet),
            PopupItem(title: "可全屏底部弹出框", style: .bottomSheetFullScreen),
            PopupItem(title: "固定高度底部弹出框", style: .bottomSheetFixed),
            PopupItem(title: "自定义配置底部弹出框", style: .bottomSheetCustom)
        ]),
        ("背景效果", [
            PopupItem(title: "纯色背景", style: .solidColor),
            PopupItem(title: "模糊背景", style: .blur),
            PopupItem(title: "渐变背景", style: .gradient),
            PopupItem(title: "自定义背景", style: .customBackground)
        ]),
        ("交互方式", [
            PopupItem(title: "可拖拽关闭", style: .draggable),
            PopupItem(title: "背景可穿透", style: .penetrable),
            PopupItem(title: "键盘处理", style: .keyboard)
        ]),
        ("容器大小", [
            PopupItem(title: "固定大小", style: .fixedSize),
            PopupItem(title: "自动大小", style: .autoSize),
            PopupItem(title: "比例大小", style: .ratioSize),
            PopupItem(title: "自定义大小", style: .customSize)
        ])
    ]
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20.adap, bottom: 0, right: 20.adap)
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDeviceAdaptation()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "弹窗演示"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupDeviceAdaptation() {
        // 根据设备类型调整布局
        if TFYSwiftAdaptiveKit.Device.isIPad {
            // iPad布局调整
            tableView.separatorStyle = .singleLine
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 20.adap, bottom: 0, right: 20.adap)
        }
    }
    
    // MARK: - Actions
    private func showPopup(for item: PopupItem) {
        // 如果已经有弹窗在显示，先关闭它
        if let existingPopup = currentPopupView {
            existingPopup.dismiss(animated: false) { [weak self] in
                self?.showNewPopup(for: item)
            }
        } else {
            showNewPopup(for: item)
        }
    }
    
    private func showNewPopup(for item: PopupItem) {
        // 根据弹出框类型选择合适的内容视图
        let contentView: UIView
        
        switch item.style {
        case .bottomSheet, .bottomSheetFullScreen, .bottomSheetFixed, .bottomSheetCustom:
            let bottomSheetView = BottomSheetContentView()
            bottomSheetView.dataBlock = { [weak self] btn in
                self?.closeButtonTapped()
            }
            contentView = bottomSheetView
        default:
            let tipsView = CustomViewTipsView()
            tipsView.dataBlock = { [weak self] btn in
                self?.closeButtonTapped()
            }
            contentView = tipsView
        }
        
        var config = TFYSwiftPopupViewConfiguration()
        var animator: TFYSwiftPopupViewAnimator = TFYSwiftFadeInOutAnimator()
        
        // 配置基本属性
        config.isDismissible = true
        config.backgroundStyle = .solidColor
        config.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        
        // 根据设备类型设置默认容器大小
        let defaultWidth = TFYSwiftAdaptiveKit.Device.isIPad ? 400.adap : UIScreen.main.bounds.width - 60.adap
        let defaultHeight = TFYSwiftAdaptiveKit.Device.isIPad ? 350.adap : 289.adap
        
        config.containerConfiguration.width = .fixed(defaultWidth)
        config.containerConfiguration.height = .fixed(defaultHeight)
        config.enableDragToDismiss = true
        // 根据不同类型配置动画和样式
        switch item.style {
        // 基础动画
        case .fade:
            animator = TFYSwiftFadeInOutAnimator()
        case .zoom:
            animator = TFYSwiftZoomInOutAnimator()
        case .flip:
            animator = TFYSwift3DFlipAnimator()
        case .spring:
            animator = TFYSwiftSpringAnimator()
        // 方向动画
        case .upward:
            animator = TFYSwiftUpwardAnimator(layout: .bottom(.init(bottomMargin: 20.adap)))
        case .downward:
            animator = TFYSwiftDownwardAnimator(layout: .top(.init(topMargin: 20.adap)))
        case .leftward:
            animator = TFYSwiftLeftwardAnimator(layout: .trailing(.init(trailingMargin: 20.adap)))
        case .rightward:
            animator = TFYSwiftRightwardAnimator(layout: .leading(.init(leadingMargin: 20.adap)))
        // 位置展示
        case .top:
            animator = TFYSwiftFadeInOutAnimator(layout: .top(.init(topMargin: 0.adap)))
        case .bottom:
            animator = TFYSwiftFadeInOutAnimator(layout: .bottom(.init(bottomMargin: 0.adap)))
        case .leading:
            animator = TFYSwiftFadeInOutAnimator(layout: .leading(.init(leadingMargin: 0.adap)))
        case .trailing:
            animator = TFYSwiftFadeInOutAnimator(layout: .trailing(.init(trailingMargin: 0.adap)))
        case .center:
            animator = TFYSwiftFadeInOutAnimator(layout: .center(.init()))
        // 底部弹出框
        case .bottomSheet:
            var sheetConfig = TFYSwiftBottomSheetAnimator.Configuration()
            sheetConfig.defaultHeight = TFYSwiftAdaptiveKit.Device.isIPad ? 350.adap : 300.adap
            sheetConfig.minimumHeight = 100.adap
            sheetConfig.allowsFullScreen = true
            animator = TFYSwiftBottomSheetAnimator(configuration: sheetConfig)
            config.backgroundStyle = .solidColor
            config.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        case .bottomSheetFullScreen:
            var sheetConfig = TFYSwiftBottomSheetAnimator.Configuration()
            sheetConfig.maximumHeight = view.bounds.height
            sheetConfig.defaultHeight = view.bounds.height * 0.8
            sheetConfig.minimumHeight = 60.adap
            sheetConfig.allowsFullScreen = false
            sheetConfig.snapToDefaultThreshold = 80.adap
            sheetConfig.springDamping = 0.7
            animator = TFYSwiftBottomSheetAnimator(configuration: sheetConfig)
            config.backgroundStyle = .blur
        case .bottomSheetFixed:
            var sheetConfig = TFYSwiftBottomSheetAnimator.Configuration()
            sheetConfig.defaultHeight = TFYSwiftAdaptiveKit.Device.isIPad ? 300.adap : 250.adap
            sheetConfig.minimumHeight = 80.adap
            sheetConfig.maximumHeight = TFYSwiftAdaptiveKit.Device.isIPad ? 400.adap : 350.adap
            sheetConfig.allowsFullScreen = false
            sheetConfig.dismissThreshold = 30.adap
            animator = TFYSwiftBottomSheetAnimator(configuration: sheetConfig)
            config.backgroundStyle = .gradient
        case .bottomSheetCustom:
            var sheetConfig = TFYSwiftBottomSheetAnimator.Configuration()
            sheetConfig.defaultHeight = TFYSwiftAdaptiveKit.Device.isIPad ? 450.adap : 400.adap
            sheetConfig.minimumHeight = 150.adap
            sheetConfig.allowsFullScreen = true
            sheetConfig.snapToDefaultThreshold = 100.adap
            sheetConfig.dismissThreshold = 80.adap
            sheetConfig.springDamping = 0.6
            sheetConfig.springVelocity = 0.4
            sheetConfig.animationDuration = 0.4
            animator = TFYSwiftBottomSheetAnimator(configuration: sheetConfig)
            config.backgroundStyle = .custom { view in
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = view.bounds
                gradientLayer.colors = [
                    UIColor.systemBlue.withAlphaComponent(0.2).cgColor,
                    UIColor.systemPurple.withAlphaComponent(0.4).cgColor
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                gradientLayer.endPoint = CGPoint(x: 1, y: 1)
                view.layer.addSublayer(gradientLayer)
            }
        // 背景效果
        case .solidColor:
            config.backgroundStyle = .solidColor
            config.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case .blur:
            config.backgroundStyle = .blur
        case .gradient:
            config.backgroundStyle = .gradient
        case .customBackground:
            config.backgroundStyle = .custom { view in
                view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            }
        // 交互方式
        case .draggable:
            config.enableDragToDismiss = false
        case .penetrable:
            config.isPenetrable = true
        case .keyboard:
            config.keyboardConfiguration.isEnabled = true
        // 容器大小
        case .fixedSize:
            config.containerConfiguration.width = .fixed(300.adap)
            config.containerConfiguration.height = .fixed(300.adap)
        case .autoSize:
            config.containerConfiguration.width = .automatic
            config.containerConfiguration.height = .automatic
            config.containerConfiguration.maxWidth = view.bounds.width - 40.adap
            config.containerConfiguration.maxHeight = view.bounds.height - 100.adap
        case .ratioSize:
            config.containerConfiguration.width = .ratio(0.8)
            config.containerConfiguration.height = .ratio(0.4)
        case .customSize:
            config.containerConfiguration.width = .custom { [weak self] view in
                guard let self = self else { return 280.adap }
                return self.view.bounds.width * 0.7
            }
            config.containerConfiguration.height = .custom { [weak self] view in
                guard let self = self else { return 200.adap }
                return self.view.bounds.height * 0.3
            }
        }
        
        // 显示弹窗
        switch item.style {
        case .bottomSheet, .bottomSheetFullScreen, .bottomSheetFixed, .bottomSheetCustom:
            // 使用底部弹出框的便利方法
            let sheetAnimator = animator as! TFYSwiftBottomSheetAnimator
            currentPopupView = TFYSwiftPopupView.showBottomSheet(
                contentView: contentView,
                configuration: sheetAnimator.configuration,
                popupConfig: config
            )
        default:
            // 使用常规弹窗方法
            currentPopupView = TFYSwiftPopupView.show(
                contentView: contentView,
                configuration: config,
                animator: animator
            )
        }
    }
    
    @objc private func closeButtonTapped() {
        currentPopupView?.dismiss(animated: true)
    }
    
    // MARK: - Public Methods for External Use
    
    /// 显示默认配置的底部弹出框
    /// - Parameters:
    ///   - contentView: 要显示的内容视图
    ///   - completion: 完成回调
    /// - Returns: 弹窗实例
    @discardableResult
    public func showBottomSheet(contentView: UIView, completion: (() -> Void)? = nil) -> TFYSwiftPopupView {
        var config = TFYSwiftBottomSheetAnimator.Configuration()
        config.defaultHeight = TFYSwiftAdaptiveKit.Device.isIPad ? 350.adap : 300.adap
        config.minimumHeight = 100.adap
        config.allowsFullScreen = true
        
        return TFYSwiftPopupView.showBottomSheet(
            contentView: contentView,
            configuration: config,
            animated: true,
            completion: completion
        )
    }
    
    /// 显示自定义配置的底部弹出框
    /// - Parameters:
    ///   - contentView: 要显示的内容视图
    ///   - configuration: 底部弹出框配置
    ///   - popupConfig: 弹窗基础配置
    ///   - completion: 完成回调
    /// - Returns: 弹窗实例
    @discardableResult
    public func showBottomSheet(
        contentView: UIView,
        configuration: TFYSwiftBottomSheetAnimator.Configuration,
        popupConfig: TFYSwiftPopupViewConfiguration = TFYSwiftPopupViewConfiguration(),
        completion: (() -> Void)? = nil
    ) -> TFYSwiftPopupView {
        return TFYSwiftPopupView.showBottomSheet(
            contentView: contentView,
            configuration: configuration,
            popupConfig: popupConfig,
            animated: true,
            completion: completion
        )
    }
    
    /// 显示简单的底部弹出框（只包含文本内容）
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - buttonTitle: 按钮标题，默认为"关闭"
    ///   - buttonAction: 按钮点击回调
    ///   - completion: 完成回调
    /// - Returns: 弹窗实例
    @discardableResult
    public func showSimpleBottomSheet(
        title: String,
        message: String,
        buttonTitle: String = "关闭",
        buttonAction: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> TFYSwiftPopupView {
        let contentView = createSimpleBottomSheetView(
            title: title,
            message: message,
            buttonTitle: buttonTitle,
            buttonAction: buttonAction
        )
        
        return showBottomSheet(contentView: contentView, completion: completion)
    }
    
    /// 创建简单的底部弹出框内容视图
    private func createSimpleBottomSheetView(
        title: String,
        message: String,
        buttonTitle: String,
        buttonAction: (() -> Void)?
    ) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16.adap
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 拖动指示器
        let dragIndicator = UIView()
        dragIndicator.backgroundColor = .tertiaryLabel
        dragIndicator.layer.cornerRadius = 2.adap
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题标签
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TFYSwiftAdaptiveKit.Device.isIPad ? .boldSystemFont(ofSize: 20.adap) : .boldSystemFont(ofSize: 18.adap)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 消息标签
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 16.adap) : .systemFont(ofSize: 14.adap)
        messageLabel.textColor = .secondaryLabel
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 按钮
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 16.adap, weight: .medium) : .systemFont(ofSize: 14.adap, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.adap
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { _ in
            buttonAction?()
            // 查找并关闭当前弹窗
            if let popup = containerView.popupView() {
                popup.dismiss(animated: true)
            }
        }, for: .touchUpInside)
        
        containerView.addSubview(dragIndicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(button)
        
        let padding: CGFloat = TFYSwiftAdaptiveKit.Device.isIPad ? 24.adap : 20.adap
        
        NSLayoutConstraint.activate([
            // 拖动指示器
            dragIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.adap),
            dragIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 40.adap),
            dragIndicator.heightAnchor.constraint(equalToConstant: 4.adap),
            
            // 标题
            titleLabel.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 20.adap),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            
            // 消息
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.adap),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            
            // 按钮
            button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24.adap),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            button.heightAnchor.constraint(equalToConstant: 44.adap),
            button.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
        
        return containerView
    }
}

// MARK: - UITableViewDelegate & DataSource
extension GCDSocketController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        showPopup(for: item)
    }
}

// MARK: - Supporting Types
extension GCDSocketController {
    struct PopupItem {
        let title: String
        let style: PopupStyle
    }
    
    enum PopupStyle {
        // 基础动画
        case fade, zoom, flip, spring
        // 方向动画
        case upward, downward, leftward, rightward
        // 位置展示
        case top, bottom, leading, trailing, center
        // 底部弹出框
        case bottomSheet, bottomSheetFullScreen, bottomSheetFixed, bottomSheetCustom
        // 背景效果
        case solidColor, blur, gradient, customBackground
        // 交互方式
        case draggable, penetrable, keyboard
        // 容器大小
        case fixedSize, autoSize, ratioSize, customSize
    }
}


