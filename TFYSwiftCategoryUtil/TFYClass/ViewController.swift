//
//  ViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/9.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

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
        
        
        let tap = UITapGestureRecognizer()
        tap.tfy
            .delegate(self)
            .name("name")
            .addTarget(self, action: #selector(buttonclick))
        label.tfy.addGubview(tap)
        
        ///定时器
        let timer = TFYCountDownTimer(interval: .fromSeconds(0.1), times: 10) { timer , leftTimes in
            label.text = "\(leftTimes)"
        }
        timer.start()
        
        let timer2 = TFYTimer.repeaticTimer(interval: .seconds(5)) { timer in
            print("doSomething")
        }
        timer2.start()
        
        
        func speedUp(timer: TFYTimer) {
            timer2.rescheduleRepeating(interval: .seconds(1))
        }
        speedUp(timer: timer2) // print doSomething every 1 second
     
    }
    
    @objc func buttonclick() {
        
    }

}

