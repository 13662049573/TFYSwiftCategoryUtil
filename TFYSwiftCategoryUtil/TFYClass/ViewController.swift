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
            .backgroundColor(UIColor.red)
            .systemFont(ofSize: 14)
            .title("Hello World", for: .normal)
            .titleColor(UIColor.blue, for: .normal, .highlighted)
            .cornerRadius(15)
            .masksToBounds(true)
            .addTarget(self, action: #selector(buttonAction), for: .touchUpInside).build
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

    @objc private func buttonAction() {
        debugPrint("Hello World")
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

