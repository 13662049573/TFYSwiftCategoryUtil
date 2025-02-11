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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        
        // 设置ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 设置ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 添加约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 添加按钮
        var previousButton: UIButton?
        for (_, direction) in types.enumerated() {
            let btn = UIButton(type: .custom)
            let title: String
            
            // 为不同模式设置不同的文字内容
            switch direction {
            case .centerImageTop, .centerImageLeft, .centerImageRight, .centerImageBottom,
                 .leftImageLeft, .leftImageRight, .rightImageLeft, .rightImageRight,
                 .centerImageTopFixedSpace, .centerImageLeftFixedSpace, .centerImageRightFixedSpace, .centerImageBottomFixedSpace,
                 .topImageTop, .topImageBottom, .bottomImageTop, .bottomImageBottom:
                title = "\(direction) - 单行文字"
            case .centerImageTopTextBelow, .centerImageLeftTextRight, .centerImageRightTextLeft, .centerImageBottomTextAbove:
                title = "\(direction) - 这是一段较长的文字，用于测试多行显示效果"
            case .imageOnly:
                title = "" // 仅显示图片
            case .textOnly:
                title = "\(direction) - 仅显示文字"
            case .imageTopTextBelowFixedHeight, .imageBottomTextAboveFixedHeight:
                title = "\(direction) - 固定高度模式"
            case .imageLeftTextRightFixedWidth, .imageRightTextLeftFixedWidth:
                title = "\(direction) - 固定宽度模式"
            }
            
            btn.tfy
                .font(.systemFont(ofSize: 12, weight: .bold))
                .title(title, for: .normal)
                .image(UIImage(named: "vip_broadcast"), for: .normal)
                .imageDirection(direction, 10) // 设置间距为10
                .borderWidth(1)
                .cornerRadius(10)
                .backgroundColor(UIColor.random())
                .borderColor(.systemGray)
                .titleColor(.label, for: .normal)
                .addToSuperView(contentView)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20), // 减少边距
                btn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20), // 减少边距
                btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 60) // 高度自适应
            ])
            
            if let previousButton = previousButton {
                btn.topAnchor.constraint(equalTo: previousButton.bottomAnchor, constant: 20).isActive = true
            } else {
                btn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
            }
            
            previousButton = btn
        }
        
        // 设置ContentView的底部约束
        if let lastButton = previousButton {
            contentView.bottomAnchor.constraint(equalTo: lastButton.bottomAnchor, constant: 20).isActive = true
        }
    }

}
