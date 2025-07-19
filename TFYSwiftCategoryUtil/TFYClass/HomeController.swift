//
//  HomeController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2025/1/24.
//

import UIKit

class HomeController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDeviceAdaptation()
    }
    
    private let types: [UIButton.ButtonImageDirection] = [
        // 基础布局模式
        .centerImageTop,          // 图片在上方居中
        .centerImageLeft,         // 图片在左侧居中
        .centerImageRight,        // 图片在右侧居中
        .centerImageBottom,       // 图片在下方居中
        .leftImageLeft,           // 图片和文字都靠左
        .leftImageRight,          // 图片左文字右
        .rightImageLeft,          // 图片右文字左
        .rightImageRight,         // 图片和文字都靠右
        
        // 固定间距模式
        .centerImageTopFixedSpace,    // 图片在上方居中，固定间距
        .centerImageLeftFixedSpace,   // 图片在左侧居中，固定间距
        .centerImageRightFixedSpace,  // 图片在右侧居中，固定间距
        .centerImageBottomFixedSpace, // 图片在下方居中，固定间距
        
        // 顶部/底部对齐模式
        .topImageTop,            // 图片和文字都顶部对齐
        .topImageBottom,         // 图片顶部对齐，文字底部对齐
        .bottomImageTop,         // 图片底部对齐，文字顶部对齐
        .bottomImageBottom,      // 图片和文字都底部对齐
        
        // 多行文字模式
        .centerImageTopTextBelow,    // 图片在上文字在下（多行）
        .centerImageLeftTextRight,   // 图片在左文字在右（多行）
        .centerImageRightTextLeft,  // 图片在右文字在左（多行）
        .centerImageBottomTextAbove, // 图片在下文字在上（多行）
        
        // 特殊显示模式
        .imageOnly,                  // 仅显示图片模式
        .textOnly,                   // 仅显示文字模式
        
        // 固定尺寸模式
        .imageTopTextBelowFixedHeight,   // 图片在上文字在下，固定高度
        .imageLeftTextRightFixedWidth,   // 图片在左文字在右，固定宽度
        .imageRightTextLeftFixedWidth,   // 图片在右文字在左，固定宽度
        .imageBottomTextAboveFixedHeight // 图片在下文字在上，固定高度
    ]

    private func setupUI() {
        title = "首页"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupStackView()
        addButtons()
        addCollectionViewDemoButton()
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
    
    private func addButtons() {
        for (index, direction) in types.enumerated() {
            let btn = createButton(for: direction, at: index)
            stackView.addArrangedSubview(btn)
        }
    }
    
    private func createButton(for direction: UIButton.ButtonImageDirection, at index: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        let title = getButtonTitle(for: direction)
        
        btn.tfy
            .font(.systemFont(ofSize: 12.adap, weight: .bold))
            .title(title, for: .normal)
            .image(UIImage(named: "vip_broadcast"), for: .normal)
            .imageDirection(direction, 10.adap)
            .borderWidth(1.adap)
            .cornerRadius(10.adap)
            .backgroundColor(UIColor.random())
            .borderColor(.systemGray)
            .titleColor(.label, for: .normal)
        
        // 设置按钮高度约束，移除固定宽度约束
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.adap).isActive = true
        
        // 添加点击事件
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        btn.tag = index
        
        return btn
    }
    
    private func getButtonTitle(for direction: UIButton.ButtonImageDirection) -> String {
        switch direction {
        case .centerImageTop, .centerImageLeft, .centerImageRight, .centerImageBottom,
             .leftImageLeft, .leftImageRight, .rightImageLeft, .rightImageRight,
             .centerImageTopFixedSpace, .centerImageLeftFixedSpace, .centerImageRightFixedSpace, .centerImageBottomFixedSpace,
             .topImageTop, .topImageBottom, .bottomImageTop, .bottomImageBottom:
            return "\(direction) - 单行文字"
        case .centerImageTopTextBelow, .centerImageLeftTextRight, .centerImageRightTextLeft, .centerImageBottomTextAbove:
            return "\(direction) - 这是一段较长的文字，用于测试多行显示效果"
        case .imageOnly:
            return "" // 仅显示图片
        case .textOnly:
            return "\(direction) - 仅显示文字"
        case .imageTopTextBelowFixedHeight, .imageBottomTextAboveFixedHeight:
            return "\(direction) - 固定高度模式"
        case .imageLeftTextRightFixedWidth, .imageRightTextLeftFixedWidth:
            return "\(direction) - 固定宽度模式"
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let direction = types[sender.tag]
        let alert = UIAlertController(title: "按钮点击", message: "您点击了: \(direction)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func addCollectionViewDemoButton() {
        let demoButton = UIButton(type: .system)
        demoButton.setTitle("UICollectionView自适应演示", for: .normal)
        demoButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        demoButton.backgroundColor = .systemBlue
        demoButton.setTitleColor(.white, for: .normal)
        demoButton.layer.cornerRadius = 12
        demoButton.translatesAutoresizingMaskIntoConstraints = false
        
        demoButton.addTarget(self, action: #selector(collectionViewDemoTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(demoButton)
        
        demoButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc private func collectionViewDemoTapped() {
        let demoVC = UICollectionViewAdaptiveDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
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
    
    // MARK: - Orientation Support
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            // 重新计算布局 - 只在需要时更新
            if TFYSwiftAdaptiveKit.Device.isIPad {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
}
