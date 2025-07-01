//
//  ViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/9.
//

import UIKit

class ViewController: UIViewController {
    
    let linkDic = ["《用户协议》": "http://api.irainone.com/app/iop/register.html",
                   "《隐私政策》": "http://api.irainone.com/app/iop/register.html",]
    
    let string = "\t用户协议和隐私政策请您务必审值阅读、充分理解 \"用户协议\" 和 \"隐私政策\" 各项条款，包括但不限于：为了向您提供即时通讯、内容分享等服务，我们需要收集您的设备信息、操作日志等个人信息。\n\t您可阅读《用户协议》和《隐私政策》了解详细信息。如果您同意，请点击 \"同意\" 开始接受我们的服务;"
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var button: UIButton = {
        let btn = UIButton(type: .custom).tfy
            .backgroundColor(UIColor.colorGradientChangeWithSize(size: CGSize(width: 120.adap, height: 30.adap), direction: .GradientChangeDirectionLevel, colors: [UIColor.blue.cgColor,UIColor.red.cgColor,UIColor.yellow.cgColor]))
            .systemFont(ofSize: 14.adap)
            .title("进入下一个界面", for: .normal)
            .titleColor(UIColor.white, for: .normal, .highlighted)
            .cornerRadius(15.adap)
            .addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside).build
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var label: UILabel = {
        let labe = UILabel().tfy
            .text(string)
            .textColor(.gray)
            .font(.systemFont(ofSize: 14.adap, weight: .bold))
            .borderColor(.orange)
            .numberOfLines(0)
            .isUserInteractionEnabled(true)
            .build
        labe.translatesAutoresizingMaskIntoConstraints = false
        return labe
    }()
    
    private lazy var tableView: UITableView = {
        let tab = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height), style: .plain)
        tab.tfy
            .registerHeaderOrFooter(UITableViewHeaderFooterView.self)
        return tab
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDeviceAdaptation()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "功能展示"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupComponents()
        setupConstraints()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
    }
    
    private func setupComponents() {
        contentView.addSubview(button)
        contentView.addSubview(label)
        
        // 设置标签的点击事件
        label.changeColorWithTextColor(textColor: .orange, texts: linkDic.keys.sorted())
        label.addGestureTap { reco in
            reco.didTapLabelAttributedText(self.linkDic) { text, url in
                TFYUtils.Logger.log("\(text), \(url ?? "_")")
                self.showLinkAlert(text: text, url: url)
            }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Button约束
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.adap),
            button.widthAnchor.constraint(equalToConstant: 120.adap),
            button.heightAnchor.constraint(equalToConstant: 30.adap),
            
            // Label约束
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 30.adap),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.adap),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.adap),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.adap)
        ])
    }
    
    private func setupDeviceAdaptation() {
        // 根据设备类型调整布局
        if TFYSwiftAdaptiveKit.Device.isIPad {
            // iPad布局调整 - 使用更安全的方式
            let maxWidth: CGFloat = 600.adap
            let widthConstraint = contentView.widthAnchor.constraint(equalToConstant: maxWidth)
            let centerConstraint = contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
            
            // 设置优先级，避免约束冲突
            widthConstraint.priority = .defaultHigh
            centerConstraint.priority = .defaultHigh
            
            widthConstraint.isActive = true
            centerConstraint.isActive = true
        }
    }
    
    // MARK: - Actions
    @objc private func buttonAction(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        
        let title = "用户协议和隐私政策"
        
        let attributedText = NSAttributedString.create(string, textTaps: Array(linkDic.keys))
        
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            .addActionTitles(["取消", "同意"]) { vc, action in
                TFYUtils.Logger.log(action.title ?? "")
            }
        alertVC.setValue(attributedText, forKey: AlertKeys.attributedMessage)
        alertVC.messageLabel?.addGestureTap({ reco in
            reco.didTapLabelAttributedText(self.linkDic) { text, url in
                TFYUtils.Logger.log("\(text), \(url ?? "_")")
            }
        })
        alertVC.present()
    }
    
    private func showLinkAlert(text: String, url: String?) {
        let alert = UIAlertController(title: "链接点击", message: "您点击了: \(text)\n链接: \(url ?? "无")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
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

