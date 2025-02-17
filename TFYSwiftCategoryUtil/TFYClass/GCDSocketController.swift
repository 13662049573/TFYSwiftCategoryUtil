//
//  GCDSocketController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2025/1/24.
//

import UIKit

class GCDSocketController: UIViewController {
    
    // MARK: - Properties
    private var currentPopupView: TFYSwiftPopupView?
    private let sections: [(title: String, items: [PopupItem])] = [
        ("基础动画", [
            PopupItem(title: "淡入淡出", style: .fade),
            PopupItem(title: "缩放", style: .zoom),
            PopupItem(title: "3D翻转", style: .flip),
            PopupItem(title: "旋转", style: .rotation),
            PopupItem(title: "弹性", style: .spring),
            PopupItem(title: "脉冲", style: .pulse),
            PopupItem(title: "级联", style: .cascade),
            PopupItem(title: "弹性缩放", style: .elastic)
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
        ])
    ]
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Popup 演示"
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    private func showPopup(for item: PopupItem) {
        var config = TFYSwiftPopupViewConfiguration()
        var animator: TFYSwiftPopupViewAnimator
        
        // 配置基本属性
        config.isDismissible = true
        
        // 根据不同类型配置动画和样式
        switch item.style {
        // 基础动画
        case .fade:
            animator = TFYSwiftFadeInOutAnimator()
        case .zoom:
            animator = TFYSwiftZoomInOutAnimator()
        case .flip:
            animator = TFYSwift3DFlipAnimator()
        case .rotation:
            animator = TFYSwiftRotationAnimator()
        case .spring:
            animator = TFYSwiftSpringAnimator()
        case .pulse:
            animator = TFYSwiftPulseAnimator()
        case .cascade:
            animator = TFYSwiftCascadeAnimator()
        case .elastic:
            animator = TFYSwiftElasticAnimator()
            
        // 方向动画
        case .upward:
            animator = TFYSwiftUpwardAnimator(layout: .bottom(.init(bottomMargin: 20)))
        case .downward:
            animator = TFYSwiftDownwardAnimator(layout: .top(.init(topMargin: 20)))
        case .leftward:
            animator = TFYSwiftLeftwardAnimator(layout: .trailing(.init(trailingMargin: 20)))
        case .rightward:
            animator = TFYSwiftRightwardAnimator(layout: .leading(.init(leadingMargin: 20)))
            
        // 位置展示
        case .top:
            animator = TFYSwiftFadeInOutAnimator(layout: .top(.init(topMargin: 50)))
        case .bottom:
            animator = TFYSwiftFadeInOutAnimator(layout: .bottom(.init(bottomMargin: 50)))
        case .leading:
            animator = TFYSwiftFadeInOutAnimator(layout: .leading(.init(leadingMargin: 20)))
        case .trailing:
            animator = TFYSwiftFadeInOutAnimator(layout: .trailing(.init(trailingMargin: 20)))
        case .center:
            animator = TFYSwiftFadeInOutAnimator(layout: .center(.init()))
            
        // 背景效果
        case .solidColor:
            animator = TFYSwiftFadeInOutAnimator()
            config.backgroundStyle = .solidColor
            config.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case .blur:
            animator = TFYSwiftFadeInOutAnimator()
            config.backgroundStyle = .blur
        case .gradient:
            animator = TFYSwiftFadeInOutAnimator()
            let backgroundView = createGradientBackgroundView()
            config.backgroundStyle = .custom { view in
                view.addSubview(backgroundView)
            }
        case .customBackground:
            animator = TFYSwiftFadeInOutAnimator()
            config.backgroundStyle = .custom { view in
                view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            }
            
        // 交互方式
        case .draggable:
            animator = TFYSwiftFadeInOutAnimator()
            config.enableDragToDismiss = true
        case .penetrable:
            animator = TFYSwiftFadeInOutAnimator()
            config.isPenetrable = true
        case .keyboard:
            animator = TFYSwiftFadeInOutAnimator()
            config.keyboardConfiguration.isEnabled = true
            let contentView = createKeyboardTestView()
            currentPopupView = TFYSwiftPopupView.show(
                in: self,
                contentView: contentView,
                configuration: config,
                animator: animator
            )
            return
        }
        
        // 创建并显示弹窗
        let contentView = createDemoContentView(for: item)
        currentPopupView = TFYSwiftPopupView.show(
            in: self,
            contentView: contentView,
            configuration: config,
            animator: animator
        )
    }
    
    // MARK: - Helper Methods
    private func createDemoContentView(for item: PopupItem) -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        
        let messageLabel = UILabel()
        messageLabel.text = "这是一个演示弹窗\n展示了不同的动画效果和交互方式"
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        [titleLabel, messageLabel, closeButton].forEach { stackView.addArrangedSubview($0) }
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 280),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        return contentView
    }
    
    private func createKeyboardTestView() -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        
        let textField = UITextField()
        textField.placeholder = "请输入文字"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textField)
        contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 280),
            
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        return contentView
    }
    
    private func createGradientBackgroundView() -> UIView {
        let view = UIView()
        view.frame = self.view.bounds
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.7).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.addSublayer(gradientLayer)
        
        return view
    }
    
    @objc private func closeButtonTapped() {
        currentPopupView?.dismiss(animated: true)
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
        case fade, zoom, flip, rotation, spring, pulse, cascade, elastic
        // 方向动画
        case upward, downward, leftward, rightward
        // 位置展示
        case top, bottom, leading, trailing, center
        // 背景效果
        case solidColor, blur, gradient, customBackground
        // 交互方式
        case draggable, penetrable, keyboard
    }
}
