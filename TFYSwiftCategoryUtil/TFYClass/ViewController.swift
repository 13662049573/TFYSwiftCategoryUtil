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
    
        lablel.addTapAction(["《说的几个时刻》","《说的进口关税个》","崩溃","看谁"]) { string, range, int in
            TFYLog("点击了\(string)标签 - {\(range.location) , \(range.length)} - \(int)")
        }
    }

   

    @objc private func buttonAction(btn:UIButton) {
        btn.isSelected = !btn.isSelected
        let title = "用户协议和隐私政策"

        let linkDic = ["《用户协议》": "http://api.irainone.com/app/iop/register.html",
                       "《隐私政策》": "http://api.irainone.com/app/iop/register.html",]
        let string = "\t用户协议和隐私政策请您务必审值阅读、充分理解 “用户协议” 和 ”隐私政策” 各项条款，包括但不限于：为了向您提供即时通讯、内容分享等服务，我们需要收集您的设备信息、操作日志等个人信息。\n\t您可阅读《用户协议》和《隐私政策》了解详细信息。如果您同意，请点击 “同意” 开始接受我们的服务;"
        
        let attributedText = NSAttributedString.create(string, textTaps: Array(linkDic.keys))
        
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle:  .alert)
            .addActionTitles(["取消", "同意"]) { vc, action in
                TFYLog(action.title ?? "")
            }
        
        alertVC.setValue(attributedText, forKey: kAlertMessage)
        alertVC.messageLabel?.addGestureTap({ reco in
            reco.didTapLabelAttributedText(linkDic) { text, url in
                TFYLog("\(text), \(url ?? "_")")
            }
        })
        alertVC.present()
    }
    
}

