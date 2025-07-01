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
