//
//  WindowCleanerDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFY on 2024
//
//  WindowCleanerDemoController - Window清理工具演示控制器
//
//  功能说明：
//  - 演示TFYWindowCleaner的各种使用方法
//  - 展示不同类型的清理操作
//  - 展示链式调用和配置选项
//  - 展示动画清理效果
//  - 展示内存清理和重置功能
//  - 展示错误处理和性能监控
//  - 展示批量清理和状态管理
//

import UIKit

class WindowCleanerDemoController: UIViewController {
    
    // MARK: - UI组件
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let statusLabel = UILabel()
    
    // MARK: - 按钮数组
    private var buttons: [UIButton] = []
    
    // MARK: - 测试视图
    private var testViews: [UIView] = []
    
    // MARK: - 定时器
    private var statusUpdateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        createDemoButtons()
        addTestViews()
        startStatusUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopStatusUpdates()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 设置滚动视图
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 设置内容视图
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 设置标题
        titleLabel.text = "TFYWindowCleaner 演示"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // 设置描述
        descriptionLabel.text = "演示TFYWindowCleaner的各种功能，包括清理子视图、模态控制器、导航栈、错误处理、性能监控等"
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // 设置状态标签
        statusLabel.text = "状态: 准备就绪"
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .systemGreen
        statusLabel.backgroundColor = .systemGray6
        statusLabel.layer.cornerRadius = 6
        statusLabel.layer.masksToBounds = true
        contentView.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Window清理演示"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "添加测试视图",
            style: .plain,
            target: self,
            action: #selector(addMoreTestViews)
        )
    }
    
    // MARK: - 状态更新
    private func startStatusUpdates() {
        statusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatus()
        }
    }
    
    private func stopStatusUpdates() {
        statusUpdateTimer?.invalidate()
        statusUpdateTimer = nil
    }
    
    private func updateStatus() {
        let isCleaning = TFYWindowCleaner.isCurrentlyCleaning
        statusLabel.text = isCleaning ? "状态: 正在清理..." : "状态: 准备就绪"
        statusLabel.textColor = isCleaning ? .systemOrange : .systemGreen
    }
    
    // MARK: - 创建演示按钮
    private func createDemoButtons() {
        let buttonTitles = [
            "1. 智能清理（保留界面）",
            "2. 清理背景视图",
            "3. 清理覆盖视图",
            "4. 清理所有Window",
            "5. 清理当前Window",
            "6. 清理模态控制器",
            "7. 深度清理",
            "8. 重置Window",
            "9. 动画清理演示",
            "10. 内存清理演示",
            "11. 安全清理（带错误处理）",
            "12. 批量清理Windows",
            "13. 性能监控清理",
            "14. 取消清理操作",
            "15. 清理特定类型控制器"
        ]
        
        var lastButton: UIButton?
        
        for (index, title) in buttonTitles.enumerated() {
            let button = createButton(title: title, tag: index)
            contentView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            if let lastButton = lastButton {
                button.topAnchor.constraint(equalTo: lastButton.bottomAnchor, constant: 15).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30).isActive = true
            }
            
            lastButton = button
            buttons.append(button)
        }
        
        // 设置内容视图底部约束
        if let lastButton = lastButton {
            contentView.bottomAnchor.constraint(equalTo: lastButton.bottomAnchor, constant: 20).isActive = true
        }
    }
    
    private func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - 添加测试视图
    private func addTestViews() {
        // 添加一些测试视图到window上
        if let window = getCurrentWindow() {
            for i in 0..<3 {
                let testView = createTestView(index: i)
                window.addSubview(testView)
                testViews.append(testView)
            }
        }
    }
    
    @objc private func addMoreTestViews() {
        if let window = getCurrentWindow() {
            let testView = createTestView(index: testViews.count)
            window.addSubview(testView)
            testViews.append(testView)
            
            showAlert(title: "添加成功", message: "已添加新的测试视图到Window上")
        }
    }
    
    // 获取当前window的辅助方法
    private func getCurrentWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }?
                .windows
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    private func createTestView(index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemRed.cgColor
        
        let label = UILabel()
        label.text = "测试视图 \(index + 1)"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 随机位置
        let randomX = CGFloat.random(in: 50...300)
        let randomY = CGFloat.random(in: 100...600)
        view.frame = CGRect(x: randomX, y: randomY, width: 120, height: 80)
        
        return view
    }
    
    // MARK: - 按钮事件处理
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            demonstrateSmartClean()
        case 1:
            demonstrateCleanBackgroundViews()
        case 2:
            demonstrateCleanOverlayViews()
        case 3:
            demonstrateCleanAllWindows()
        case 4:
            demonstrateCleanCurrentWindow()
        case 5:
            demonstrateCleanModalControllers()
        case 6:
            demonstrateDeepClean()
        case 7:
            demonstrateResetWindow()
        case 8:
            demonstrateAnimatedClean()
        case 9:
            demonstrateMemoryClean()
        case 10:
            demonstrateSafeClean()
        case 11:
            demonstrateBatchClean()
        case 12:
            demonstratePerformanceMonitoringClean()
        case 13:
            demonstrateCancelCleaning()
        case 14:
            demonstrateCleanSpecificControllers()
        default:
            break
        }
    }
    
    // MARK: - 演示方法
    
    /// 演示智能清理（保留当前界面）
    private func demonstrateSmartClean() {
        TFYWindowCleaner.smartCleanCurrentWindow()
            .withAnimation(true)
            .withCompletion {
                self.showAlert(title: "智能清理完成", message: "已清理背景和覆盖视图，保留当前界面")
            }
            .execute()
    }
    
    /// 演示清理背景视图
    private func demonstrateCleanBackgroundViews() {
        TFYWindowCleaner.cleanBackgroundViews()
            .withAnimation(true)
            .withCompletion {
                self.showAlert(title: "背景视图清理完成", message: "已清理所有背景视图")
            }
            .execute()
    }
    
    /// 演示清理覆盖视图
    private func demonstrateCleanOverlayViews() {
        TFYWindowCleaner.cleanOverlayViews()
            .withAnimation(true)
            .withCompletion {
                self.showAlert(title: "覆盖视图清理完成", message: "已清理所有覆盖视图")
            }
            .execute()
    }
    
    /// 演示清理所有Window
    private func demonstrateCleanAllWindows() {
        TFYWindowCleaner.cleanAllWindows()
            .withAnimation(true)
            .withCompletion {
                self.showAlert(title: "清理完成", message: "已清理所有Window上的内容")
            }
            .execute()
    }
    
    /// 演示清理当前Window
    private func demonstrateCleanCurrentWindow() {
        TFYWindowCleaner.cleanCurrentWindow()
            .withAnimation(true)
            .withCompletion {
                self.showAlert(title: "清理完成", message: "已清理当前Window上的内容")
            }
            .execute()
    }
    
    /// 演示清理模态控制器
    private func demonstrateCleanModalControllers() {
        // 先添加一个模态控制器
        let modalVC = createTestModalController()
        present(modalVC, animated: true) {
            // 然后清理模态控制器
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                TFYWindowCleaner.cleanCurrentWindow()
                    .withCleanTypes([.modalControllers])
                    .withAnimation(true)
                    .withCompletion {
                        self.showAlert(title: "模态控制器清理完成", message: "已清理所有模态控制器")
                    }
                    .execute()
            }
        }
    }
    
    /// 演示深度清理
    private func demonstrateDeepClean() {
        if let window = getCurrentWindow() {
            var config = CleanConfig()
            config.animated = true
            config.completion = {
                self.showAlert(title: "深度清理完成", message: "已深度清理Window，包括内存引用")
            }
            TFYWindowCleaner.deepCleanWindow(window, config: config)
        }
    }
    
    /// 演示重置Window
    private func demonstrateResetWindow() {
        let newRootVC = createTestViewController(title: "新的根控制器", color: .systemPurple)
        
        if let window = getCurrentWindow() {
            var config = CleanConfig()
            config.animated = true
            config.completion = {
                self.showAlert(title: "Window重置完成", message: "已重置Window到新的根控制器")
            }
            TFYWindowCleaner.resetWindow(window, to: newRootVC, config: config)
        }
    }
    
    /// 演示动画清理
    private func demonstrateAnimatedClean() {
        TFYWindowCleaner.cleanCurrentWindow()
            .withAnimation(true)
            .withAnimationDuration(1.0)
            .withCompletion {
                self.showAlert(title: "动画清理完成", message: "已使用动画效果清理Window")
            }
            .execute()
    }
    
    /// 演示内存清理
    private func demonstrateMemoryClean() {
        // 模拟内存清理
        autoreleasepool {
            // 清理可能的循环引用
            testViews.removeAll()
            
            TFYWindowCleaner.cleanCurrentWindow()
                .withAnimation(false)
                .withCompletion {
                    self.showAlert(title: "内存清理完成", message: "已清理内存引用和循环引用")
                }
                .execute()
        }
    }
    
    /// 演示安全清理（带错误处理）
    private func demonstrateSafeClean() {
        if let window = getCurrentWindow() {
            TFYWindowCleaner.safeCleanWindow(window, errorHandler: { error in
                self.showAlert(title: "清理错误", message: "清理过程中发生错误: \(error.localizedDescription)")
            })
        }
    }
    
    /// 演示批量清理Windows
    private func demonstrateBatchClean() {
        let windows = getAllWindows()
        
        TFYWindowCleaner.safeCleanWindows(
            windows,
            progressHandler: { completed, total in
                print("批量清理进度: \(completed)/\(total)")
            },
            completion: {
                self.showAlert(title: "批量清理完成", message: "已成功清理 \(windows.count) 个Window")
            },
            errorHandler: { error in
                self.showAlert(title: "批量清理错误", message: "批量清理过程中发生错误: \(error.localizedDescription)")
            }
        )
    }
    
    /// 演示性能监控清理
    private func demonstratePerformanceMonitoringClean() {
        if let window = getCurrentWindow() {
            TFYWindowCleaner.cleanWithPerformanceMonitoring(window) { duration, subviewCount in
                let message = String(format: "清理耗时: %.3f秒\n清理前子视图数量: %d", duration, subviewCount)
                self.showAlert(title: "性能监控结果", message: message)
            }
        }
    }
    
    /// 演示取消清理操作
    private func demonstrateCancelCleaning() {
        if TFYWindowCleaner.isCurrentlyCleaning {
            TFYWindowCleaner.cancelCleaning()
            showAlert(title: "操作已取消", message: "清理操作已被取消")
        } else {
            showAlert(title: "无需取消", message: "当前没有正在进行的清理操作")
        }
    }
    
    /// 演示清理特定类型控制器
    private func demonstrateCleanSpecificControllers() {
        if let window = getCurrentWindow() {
            // 先添加一个测试控制器
            let testVC = TestViewController()
            window.rootViewController = testVC
            
            // 延迟后清理特定类型的控制器
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var config = CleanConfig()
                config.completion = {
                    self.showAlert(title: "特定控制器清理完成", message: "已清理所有TestViewController类型的控制器")
                }
                TFYWindowCleaner.cleanControllers(window, ofType: TestViewController.self, config: config)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func getAllWindows() -> [UIWindow] {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
        } else {
            return UIApplication.shared.windows
        }
    }
    
    private func createTestModalController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemYellow
        vc.title = "测试模态控制器"
        
        let label = UILabel()
        label.text = "这是一个测试模态控制器"
        label.textAlignment = .center
        label.numberOfLines = 0
        
        vc.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20)
        ])
        
        return vc
    }
    
    private func createTestViewController(title: String, color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.title = title
        vc.view.backgroundColor = color
        
        let label = UILabel()
        label.text = "这是 \(title)"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        
        vc.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - 测试控制器
class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
        title = "测试控制器"
        
        let label = UILabel()
        label.text = "这是一个测试控制器"
        label.textAlignment = .center
        label.textColor = .white
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
} 