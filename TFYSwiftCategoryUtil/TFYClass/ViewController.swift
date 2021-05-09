//
//  ViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/9.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let w_w = UIScreen.main.bounds.width
//        let h_h = UIScreen.main.bounds.height
    
        let buttoon = UIButton(frame: CGRect(x: 0, y: 0, width: w_w, height: 88))
        buttoon.tfy
            .backgroundColor(.orange)
            .text("点击按钮", state: .normal)
            .systemFont(16)
            .textColor(.white, state: .normal)
            .addTarget(self, action: #selector(buttonclick), controlEvents: .touchUpInside)
            .addSubview(view)
          
        
        let label = UILabel(frame: CGRect(x: 0, y: buttoon.maxY, width: w_w, height: 50))
        label.tfy
            .text("描述")
            .systemFont(15)
            .backgroundColor(.blue)
            .textAlignment(.center)
            .addSubview(view)
        
        
        

    }
    
    @objc func buttonclick() {
        
    }

}

