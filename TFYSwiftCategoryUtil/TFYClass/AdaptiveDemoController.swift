//
//  AdaptiveDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFYSwift on 2025/1/24.
//

import UIKit

class AdaptiveDemoController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let demoItems: [DemoItem] = [
        DemoItem(title: "设备信息", description: "显示当前设备类型、屏幕尺寸等信息", action: .deviceInfo),
        DemoItem(title: "屏幕适配", description: "展示不同屏幕尺寸的适配效果", action: .screenAdaptation),
        DemoItem(title: "方向检测", description: "检测屏幕方向变化", action: .orientation),
        DemoItem(title: "安全区域", description: "显示安全区域信息", action: .safeArea),
        DemoItem(title: "分屏检测", description: "检测iPad分屏模式", action: .splitScreen),
        DemoItem(title: "响应式布局", description: "展示响应式布局效果", action: .responsiveLayout),
        DemoItem(title: "字体适配", description: "展示字体大小适配", action: .fontAdaptation),
        DemoItem(title: "间距适配", description: "展示间距适配效果", action: .spacingAdaptation)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDeviceAdaptation()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "适配演示"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupStackView()
        addDemoItems()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 20.adap
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.adap),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.adap),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.adap),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.adap)
        ])
    }
    
    private func addDemoItems() {
        for (index, item) in demoItems.enumerated() {
            let cardView = createDemoCard(for: item, at: index)
            stackView.addArrangedSubview(cardView)
        }
    }
    
    private func createDemoCard(for item: DemoItem, at index: Int) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 12.adap
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2.adap)
        cardView.layer.shadowRadius = 4.adap
        cardView.layer.shadowOpacity = 0.1
        cardView.tfy_setGradientBackground(direction: UIColor.GradientChangeDirection(rawValue: (index+1)) ?? .level, colors: [.tfy.random,.tfy.random],cornerRadius: 12.adap)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = TFYSwiftAdaptiveKit.Device.isIPad ? .boldSystemFont(ofSize: 18.adap) : .boldSystemFont(ofSize: 16.adap)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = item.description
        descriptionLabel.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 14.adap) : .systemFont(ofSize: 12.adap)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("演示", for: .normal)
        actionButton.titleLabel?.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 14.adap, weight: .medium) : .systemFont(ofSize: 12.adap, weight: .medium)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 6.adap
        actionButton.tag = index
        actionButton.addTarget(self, action: #selector(demoButtonTapped(_:)), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(titleLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(actionButton)
        
        let padding: CGFloat = TFYSwiftAdaptiveKit.Device.isIPad ? 20.adap : 16.adap
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100.adap),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -padding),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.adap),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: padding),
            descriptionLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -padding),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -padding),
            
            actionButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -padding),
            actionButton.widthAnchor.constraint(equalToConstant: 60.adap),
            actionButton.heightAnchor.constraint(equalToConstant: 32.adap)
        ])
        
        return cardView
    }
    
    private func setupDeviceAdaptation() {
        // 根据设备类型调整布局
        if TFYSwiftAdaptiveKit.Device.isIPad {
            // iPad布局调整
            stackView.spacing = 30.adap
            
            // 如果是分屏模式，调整间距
            if TFYSwiftAdaptiveKit.Device.isSplitScreen {
                stackView.spacing = 20.adap
            }
        }
    }
    
    // MARK: - Actions
    @objc private func demoButtonTapped(_ sender: UIButton) {
        let item = demoItems[sender.tag]
        performDemoAction(item.action)
    }
    
    private func performDemoAction(_ action: DemoAction) {
        switch action {
        case .deviceInfo:
            showDeviceInfo()
        case .screenAdaptation:
            showScreenAdaptation()
        case .orientation:
            showOrientationInfo()
        case .safeArea:
            showSafeAreaInfo()
        case .splitScreen:
            showSplitScreenInfo()
        case .responsiveLayout:
            showResponsiveLayout()
        case .fontAdaptation:
            showFontAdaptation()
        case .spacingAdaptation:
            showSpacingAdaptation()
        }
    }
    
    private func showDeviceInfo() {
        let deviceType = TFYSwiftAdaptiveKit.Device.isIPad ? "iPad" : "iPhone"
        let screenWidth = TFYSwiftAdaptiveKit.Screen.width
        let screenHeight = TFYSwiftAdaptiveKit.Screen.height
        let scale = UIScreen.main.scale
        
        let message = """
        设备类型: \(deviceType)
        屏幕尺寸: \(String(format: "%.0f x %.0f", screenWidth, screenHeight))
        屏幕比例: \(String(format: "%.1f", scale))x
        设备型号: \(UIDevice.current.model)
        系统版本: \(UIDevice.current.systemVersion)
        """
        
        showAlert(title: "设备信息", message: message)
    }
    
    private func showScreenAdaptation() {
        let referenceWidth = TFYSwiftAdaptiveKit.Config.referenceWidth
        let referenceHeight = TFYSwiftAdaptiveKit.Config.referenceHeight
        let currentWidth = TFYSwiftAdaptiveKit.Screen.width
        let currentHeight = TFYSwiftAdaptiveKit.Screen.height
        
        let widthRatio = currentWidth / referenceWidth
        let heightRatio = currentHeight / referenceHeight
        
        let message = """
        参照尺寸: \(String(format: "%.0f x %.0f", referenceWidth, referenceHeight))
        当前尺寸: \(String(format: "%.0f x %.0f", currentWidth, currentHeight))
        宽度比例: \(String(format: "%.2f", widthRatio))
        高度比例: \(String(format: "%.2f", heightRatio))
        """
        
        showAlert(title: "屏幕适配", message: message)
    }
    
    private func showOrientationInfo() {
        let orientation = TFYSwiftAdaptiveKit.Device.orientation
        let isPortrait = TFYSwiftAdaptiveKit.Device.isPortrait
        let isLandscape = TFYSwiftAdaptiveKit.Device.isLandscape
        
        let message = """
        当前方向: \(orientation.description)
        是否竖屏: \(isPortrait ? "是" : "否")
        是否横屏: \(isLandscape ? "是" : "否")
        """
        
        showAlert(title: "方向检测", message: message)
    }
    
    private func showSafeAreaInfo() {
        let insets = TFYSwiftAdaptiveKit.Device.getSafeAreaInsets()
        let topMargin = TFYSwiftAdaptiveKit.Device.getSafeAreaTopMargin()
        let bottomMargin = TFYSwiftAdaptiveKit.Device.getSafeAreaBottomMargin()
        
        let message = """
        顶部安全区域: \(String(format: "%.0f", topMargin))
        底部安全区域: \(String(format: "%.0f", bottomMargin))
        左侧安全区域: \(String(format: "%.0f", insets.left))
        右侧安全区域: \(String(format: "%.0f", insets.right))
        """
        
        showAlert(title: "安全区域", message: message)
    }
    
    private func showSplitScreenInfo() {
        let isSplitScreen = TFYSwiftAdaptiveKit.Device.isSplitScreen
        let isIPad = TFYSwiftAdaptiveKit.Device.isIPad
        
        let message = """
        设备类型: \(isIPad ? "iPad" : "iPhone")
        分屏模式: \(isSplitScreen ? "是" : "否")
        """
        
        showAlert(title: "分屏检测", message: message)
    }
    
    private func showResponsiveLayout() {
        let message = "当前页面使用了响应式布局，会根据设备类型和屏幕尺寸自动调整UI元素的大小和间距。"
        showAlert(title: "响应式布局", message: message)
    }
    
    private func showFontAdaptation() {
        let message = """
        字体大小会根据设备类型自动调整：
        iPhone: 较小字体
        iPad: 较大字体
        分屏模式: 适中字体
        """
        showAlert(title: "字体适配", message: message)
    }
    
    private func showSpacingAdaptation() {
        let message = """
        间距会根据设备类型自动调整：
        iPhone: 紧凑间距
        iPad: 宽松间距
        分屏模式: 适中间距
        """
        showAlert(title: "间距适配", message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Orientation Support
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            // 重新计算布局
            self.setupDeviceAdaptation()
        }
    }
}

// MARK: - Supporting Types
extension AdaptiveDemoController {
    struct DemoItem {
        let title: String
        let description: String
        let action: DemoAction
    }
    
    enum DemoAction {
        case deviceInfo
        case screenAdaptation
        case orientation
        case safeArea
        case splitScreen
        case responsiveLayout
        case fontAdaptation
        case spacingAdaptation
    }
}

// MARK: - UIInterfaceOrientation Extension
extension UIInterfaceOrientation {
    var description: String {
        switch self {
        case .portrait:
            return "竖屏"
        case .portraitUpsideDown:
            return "倒置竖屏"
        case .landscapeLeft:
            return "左横屏"
        case .landscapeRight:
            return "右横屏"
        default:
            return "未知"
        }
    }
} 
