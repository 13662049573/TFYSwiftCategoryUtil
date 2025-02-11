//
//  HomeController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2025/1/24.
//

import UIKit

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private let types: [UIButton.ButtonImageDirection] = [
        .centerImageTop,
        .centerImageLeft,
        .centerImageRight,
        .centerImageBottom,
        .leftImageLeft,
        .leftImageRight,
        .rightImageLeft,
        .rightImageRight
    ]

    private func setupUI() {
        title = "首页"
        view.backgroundColor = .systemBackground
        
        for (index, direction) in types.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tfy
                .frame(x: 40, y: CGFloat(UIDevice.navBarHeight + 30 + CGFloat(index * 70)), width: UIScreen.width - 80, height: 60)
                .font(.systemFont(ofSize: 12, weight: .bold))
                .title("\(direction)", for: .normal) // 修正：显示方向名称
                .image(UIImage(named: "vip_broadcast"), for: .normal)
                .imageDirection(direction, 5)
                .borderWidth(1)
                .cornerRadius(10)
                .backgroundColor(UIColor.random())
                .borderColor(.systemGray)
                .titleColor(.label, for: .normal)
                .addToSuperView(view)
        }
    }

}
