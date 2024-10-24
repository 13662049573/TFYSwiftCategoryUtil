//
//  ViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/9.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var button: UIButton = {
        UIButton(type: .custom).tfy
            .frame(x: 0, y: 0, width: 120, height: 30)
            .center(view.center)
            .backgroundColor(UIColor.colorGradientChangeWithSize(size: CGSize(width: 120, height: 30), direction: .GradientChangeDirectionLevel, colors: [UIColor.blue.cgColor,UIColor.red.cgColor,UIColor.yellow.cgColor]))
            .systemFont(ofSize: 14)
            .title("进入下一个界面", for: .normal)
            .titleColor(UIColor.white, for: .normal, .highlighted)
            .cornerRadius(15)
            .addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside).build
    }()
    
    private lazy var lablel: UILabel = {
        let labe = UILabel().tfy
            .frame(x: 20, y: 200, width: UIScreen.width-40, height: 50)
            .text("说的可不敢看谁都不敢开始崩溃时刻崩溃是白费口舌吧看《说的几个时刻》，《说的进口关税个》")
            .textColor(.gray)
            .font(.systemFont(ofSize: 14, weight: .bold))
            .borderColor(.orange)
            .numberOfLines(0)
            .isUserInteractionEnabled(true)
            .build
        return labe
    }()
    
    lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height), style: .plain)
        tab.tfy
            .registerHeaderOrFooter(UITableViewHeaderFooterView.self)
        return tab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        
        view.addSubview(lablel)
       
        lablel.tfy.changeColorWithTextColor(textColor: .orange, texts: ["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"])
    
    }

    @objc private func buttonAction(btn:UIButton) {
        btn.isSelected = !btn.isSelected
        UIAlertController(title: "Tips", message: "After you are added to the blacklist, you will no longer receive messages from the peer party. Are you sure to block them?", preferredStyle: .alert)
            .tfy
            .action("Cancel", custom: { action in
                action.tfy.titleColor(.red)
            }, handler: { action in
                
            })
            .action("OK", custom: { action in
                action.tfy.titleColor(.yellow)
            }, handler: { action in
                
            })
            .show(self)
    }
    
}

