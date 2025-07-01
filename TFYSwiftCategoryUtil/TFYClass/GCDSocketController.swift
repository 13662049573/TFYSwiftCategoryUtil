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
        let contentView = CustomViewTipsView()
        contentView.dataBlock = { [weak self] btn in
            self?.closeButtonTapped()
        }
        var config = TFYSwiftPopupViewConfiguration()
        var animator: TFYSwiftPopupViewAnimator = TFYSwiftFadeInOutAnimator()
        
        // 配置基本属性
        config.isDismissible = true
        config.backgroundStyle = .solidColor
        config.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // 根据设备类型设置默认容器大小
        let defaultWidth = TFYSwiftAdaptiveKit.Device.isIPad ? 400.adap : UIScreen.main.bounds.width - 60.adap
        let defaultHeight = TFYSwiftAdaptiveKit.Device.isIPad ? 350.adap : 289.adap
        
        config.containerConfiguration.width = .fixed(defaultWidth)
        config.containerConfiguration.height = .fixed(defaultHeight)
        
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
            animator = TFYSwiftUpwardAnimator(layout: .bottom(.init(bottomMargin: 20.adap)))
        case .downward:
            animator = TFYSwiftDownwardAnimator(layout: .top(.init(topMargin: 20.adap)))
        case .leftward:
            animator = TFYSwiftLeftwardAnimator(layout: .trailing(.init(trailingMargin: 20.adap)))
        case .rightward:
            animator = TFYSwiftRightwardAnimator(layout: .leading(.init(leadingMargin: 20.adap)))
            
        // 位置展示
        case .top:
            animator = TFYSwiftFadeInOutAnimator(layout: .top(.init(topMargin: 50.adap)))
        case .bottom:
            animator = TFYSwiftFadeInOutAnimator(layout: .bottom(.init(bottomMargin: 50.adap)))
        case .leading:
            animator = TFYSwiftFadeInOutAnimator(layout: .leading(.init(leadingMargin: 20.adap)))
        case .trailing:
            animator = TFYSwiftFadeInOutAnimator(layout: .trailing(.init(trailingMargin: 20.adap)))
        case .center:
            animator = TFYSwiftFadeInOutAnimator(layout: .center(.init()))
            
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
            config.enableDragToDismiss = true
        case .penetrable:
            config.isPenetrable = true
        case .keyboard:
            config.keyboardConfiguration.isEnabled = true
        }
        
        // 显示弹窗
        currentPopupView = TFYSwiftPopupView.show(
            contentView: contentView,
            configuration: config,
            animator: animator
        )
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
        // 容器大小
        case fixedSize, autoSize, ratioSize, customSize
    }
}


