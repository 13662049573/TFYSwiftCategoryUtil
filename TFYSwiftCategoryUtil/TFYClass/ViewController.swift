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
            .text("shish")
            .textColor(.blue)
            .font(.systemFont(ofSize: 14, weight: .bold))
            .borderColor(.orange)
            .build
        return labe
    }()
    
    lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect(x: 0, y: 0, width: TFYSwiftWidth, height: TFYSwiftHeight), style: .plain)
        tab.tfy
            .registerHeaderOrFooter(UITableViewHeaderFooterView.self)
        return tab
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        
//        let attrText = NSMutableAttributedString(string: "Hello World").tfy
//            .systemFont(ofSize: 18)
//            .foregroundColor(UIColor.yellow, range: NSMakeRange(0, 5))
//            .backgroundColor(UIColor.blue)
//            .baselineOffset(5, range: NSMakeRange(6, 5))
//            .kern(0.5)
//            .strikethroughStyle(1)
//            .underlineStyle(1)
//            .writingDirection([3]).build
//        button.setAttributedTitle(attrText, for: .normal)
        
        UserDefaults.standard.tfy
            .set(123, forKey: "integer")
            .set("string", forKey: "string")
            .set(false, forKey: "boolean")
            .synchronize()
        
        debugPrint(UserDefaults.standard.integer(forKey: "integer"))
        debugPrint(UserDefaults.standard.string(forKey: "string") ?? "")
        debugPrint(UserDefaults.standard.bool(forKey: "boolean"))
        
        DateFormatter().tfy
            .dateFormat("")
            .dateStyle(.full)
            .timeZone(.current)
        
        let name0 = Notification.Name("notification0")
        let name1 = Notification.Name("notification1")
        let name2 = Notification.Name("notification2")
        
        NotificationCenter.default.tfy
            .addObserver(self, selector: #selector(notificationAction0), name: name0)
            .addObserver(self, selector: #selector(notificationAction2), name: name2)
            .addObserver(self, selector: #selector(notificationAction1), name: name1)
        
        NotificationCenter.default.tfy
            .post(name: name1)
            .post(Notification(name: name2))
            .post(name: name0)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func buttonAction(btn:UIButton) {
        btn.isSelected = !btn.isSelected
//        button.activityIndicatorEnabled = true
//        let webVc:WKWebController = WKWebController()
//        webVc.url = URL(string: "https://github.com/13662049573/TFYSwiftCategoryUtil")
//        self.present(webVc, animated: true, completion: nil)
        
        let aler:UIAlertController = UIAlertController(title: "Tips", message: "After you are added to the blacklist, you will no longer receive messages from the peer party. Are you sure to block them?", preferredStyle: .alert)
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
            .build
        
    }
    
    @objc private func notificationAction0() {
        debugPrint("notificationAction0")
    }
    
    @objc private func notificationAction1() {
        debugPrint("notificationAction1")
    }
    
    @objc private func notificationAction2() {
        debugPrint("notificationAction2")
    }
}

