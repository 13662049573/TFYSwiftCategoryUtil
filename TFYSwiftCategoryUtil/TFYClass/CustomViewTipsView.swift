//
//  CustomViewTipsView.swift
//  TFYSwiftCategoryUtil
//
//  Created by mi ni on 2025/2/17.
//

import UIKit

public typealias dataBlock = (_ data:Any) -> Void

class CustomViewTipsView: UIView {

    var dataBlock: dataBlock?
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "弹窗演示"
        label.font = TFYSwiftAdaptiveKit.Device.isIPad ? .boldSystemFont(ofSize: 20.adap) : .boldSystemFont(ofSize: 18.adap)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "这是一个演示弹窗\n展示了不同的动画效果和交互方式\n支持iPhone和iPad适配"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 16.adap) : .systemFont(ofSize: 14.adap)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("关闭", for: .normal)
        button.titleLabel?.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 16.adap, weight: .medium) : .systemFont(ofSize: 14.adap, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.adap
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var deviceInfoLabel: UILabel = {
        let label = UILabel()
        label.text = getDeviceInfo()
        label.font = .systemFont(ofSize: 12.adap)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12.adap
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.adap)
        layer.shadowRadius = 8.adap
        layer.shadowOpacity = 0.1
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(deviceInfoLabel)
        addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let padding: CGFloat = TFYSwiftAdaptiveKit.Device.isIPad ? 30.adap : 20.adap
        let spacing: CGFloat = TFYSwiftAdaptiveKit.Device.isIPad ? 20.adap : 16.adap
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            // Message Label
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            // Device Info Label
            deviceInfoLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: spacing),
            deviceInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            deviceInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            // Close Button
            closeButton.topAnchor.constraint(equalTo: deviceInfoLabel.bottomAnchor, constant: spacing),
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100.adap),
            closeButton.heightAnchor.constraint(equalToConstant: 40.adap),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }
    
    private func getDeviceInfo() -> String {
        let deviceType = TFYSwiftAdaptiveKit.Device.isIPad ? "iPad" : "iPhone"
        let orientation = TFYSwiftAdaptiveKit.Device.isPortrait ? "竖屏" : "横屏"
        let isSplitScreen = TFYSwiftAdaptiveKit.Device.isSplitScreen ? "分屏模式" : "全屏模式"
        
        return "设备: \(deviceType)\n方向: \(orientation)\n模式: \(isSplitScreen)"
    }
    
    @objc func closeButtonTapped() {
        guard let block = dataBlock else { return }
        block("")
    }
}

// MARK: - Bottom Sheet Content View
class BottomSheetContentView: UIView {
    
    var dataBlock: dataBlock?
    
    // MARK: - UI Components
    private lazy var dragIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiaryLabel
        view.layer.cornerRadius = 2.adap
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "底部弹出框"
        label.font = TFYSwiftAdaptiveKit.Device.isIPad ? .boldSystemFont(ofSize: 22.adap) : .boldSystemFont(ofSize: 20.adap)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "🔸 向上滑动可展开到全屏\n🔸 向下滑动到最低值会关闭\n🔸 在中间位置松手会回到默认高度\n🔸 支持快速滑动手势"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 16.adap) : .systemFont(ofSize: 14.adap)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16.adap
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("关闭弹窗", for: .normal)
        button.titleLabel?.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 16.adap, weight: .medium) : .systemFont(ofSize: 14.adap, weight: .medium)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.adap
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // 只给顶部设置圆角
        layer.cornerRadius = 16.adap
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(dragIndicator)
        addSubview(titleLabel)
        addSubview(instructionLabel)
        addSubview(scrollView)
        addSubview(closeButton)
        
        scrollView.addSubview(contentStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let padding: CGFloat = TFYSwiftAdaptiveKit.Device.isIPad ? 24.adap : 20.adap
        
        NSLayoutConstraint.activate([
            // Drag Indicator
            dragIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8.adap),
            dragIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 40.adap),
            dragIndicator.heightAnchor.constraint(equalToConstant: 4.adap),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 16.adap),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            // Instruction Label
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.adap),
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20.adap),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -16.adap),
            
            // Content Stack View
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: padding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -padding),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2*padding),
            
            // Close Button
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            closeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.adap),
            closeButton.heightAnchor.constraint(equalToConstant: 44.adap)
        ])
    }
    
    private func setupContent() {
        // 添加一些示例内容来展示滚动效果
        let features = [
            "✨ 智能滑动检测",
            "🎯 精确的手势识别",
            "🌊 流畅的动画效果",
            "📱 完美的设备适配",
            "🔄 自动回弹机制",
            "⚡ 快速滑动支持",
            "🎨 自定义背景效果",
            "🔧 灵活的配置选项",
            "📏 动态高度调整",
            "🎪 多种展示模式"
        ]
        
        for feature in features {
            let label = createFeatureLabel(text: feature)
            contentStackView.addArrangedSubview(label)
        }
        
        // 添加一些额外的空间来演示滚动
        for i in 1...10 {
            let label = createFeatureLabel(text: "第 \(i) 行额外内容，用于演示滚动效果")
            contentStackView.addArrangedSubview(label)
        }
    }
    
    private func createFeatureLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = TFYSwiftAdaptiveKit.Device.isIPad ? .systemFont(ofSize: 16.adap) : .systemFont(ofSize: 14.adap)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }
    
    @objc private func closeButtonTapped() {
        guard let block = dataBlock else { return }
        block("")
    }
}
