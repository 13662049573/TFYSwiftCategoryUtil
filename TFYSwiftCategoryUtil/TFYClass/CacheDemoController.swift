//
//  CacheDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/12/19.
//  用途：缓存功能展示界面，展示TFYSwiftCacheKit的所有功能。
//

import UIKit

/// 用户模型（用于演示缓存功能）
struct CacheUser: Codable {
    let id: Int
    let name: String
    let email: String
    let avatar: String
    let createdAt: Date
    
    init(id: Int, name: String, email: String, avatar: String) {
        self.id = id
        self.name = name
        self.email = email
        self.avatar = avatar
        self.createdAt = Date()
    }
}

/// 缓存演示控制器
class CacheDemoController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let logTextView = UITextView()
    
    // MARK: - Properties
    private var demoUsers: [CacheUser] = []
    private var demoImages: [UIImage] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDemoData()
        setupDeviceAdaptation()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "缓存功能演示"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentView()
        setupStackView()
        setupLogTextView()
        addDemoButtons()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 15.adap
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.adap),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.adap),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.adap)
        ])
    }
    
    private func setupLogTextView() {
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.backgroundColor = .systemGray6
        logTextView.layer.cornerRadius = 8.adap
        logTextView.font = .monospacedSystemFont(ofSize: 12.adap, weight: .regular)
        logTextView.isEditable = false
        logTextView.text = "缓存操作日志:\n"
        
        contentView.addSubview(logTextView)
        
        NSLayoutConstraint.activate([
            logTextView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20.adap),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.adap),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.adap),
            logTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.adap),
            logTextView.heightAnchor.constraint(equalToConstant: 200.adap)
        ])
    }
    
    private func setupDemoData() {
        // 创建演示用户数据
        demoUsers = [
            CacheUser(id: 1, name: "张三", email: "zhangsan@example.com", avatar: "avatar1"),
            CacheUser(id: 2, name: "李四", email: "lisi@example.com", avatar: "avatar2"),
            CacheUser(id: 3, name: "王五", email: "wangwu@example.com", avatar: "avatar3")
        ]
        
        // 创建演示图片
        demoImages = [
            createDemoImage(size: CGSize(width: 100, height: 100), color: .systemRed),
            createDemoImage(size: CGSize(width: 150, height: 150), color: .systemBlue),
            createDemoImage(size: CGSize(width: 200, height: 200), color: .systemGreen)
        ]
    }
    
    private func createDemoImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 添加文字
            let text = "Demo"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func setupDeviceAdaptation() {
        if TFYSwiftAdaptiveKit.Device.isIPad {
            stackView.spacing = 20.adap
        }
    }
    
    // MARK: - Demo Buttons
    private func addDemoButtons() {
        // 基础缓存操作
        addSectionTitle("基础缓存操作")
        addButton("字符串缓存", action: #selector(demoStringCache))
        addButton("数字缓存", action: #selector(demoNumberCache))
        addButton("数组缓存", action: #selector(demoArrayCache))
        addButton("字典缓存", action: #selector(demoDictionaryCache))
        
        // 自定义模型缓存
        addSectionTitle("自定义模型缓存")
        addButton("用户模型缓存", action: #selector(demoUserCache))
        addButton("批量用户缓存", action: #selector(demoBatchUserCache))
        
        // 图片缓存
        addSectionTitle("图片缓存")
        addButton("单张图片缓存", action: #selector(demoSingleImageCache))
        addButton("批量图片缓存", action: #selector(demoBatchImageCache))
        addButton("获取缓存图片", action: #selector(demoGetCachedImage))
        
        // 同步缓存操作
        addSectionTitle("同步缓存操作")
        addButton("同步设置缓存", action: #selector(demoSyncSetCache))
        addButton("同步获取缓存", action: #selector(demoSyncGetCache))
        
        // 缓存管理
        addSectionTitle("缓存管理")
        addButton("获取缓存大小", action: #selector(demoGetCacheSize))
        addButton("清理过期缓存", action: #selector(demoCleanExpiredCache))
        addButton("清空内存缓存", action: #selector(demoClearMemoryCache))
        addButton("清空磁盘缓存", action: #selector(demoClearDiskCache))
        
        // 统计功能
        addSectionTitle("统计功能")
        addButton("获取缓存统计", action: #selector(demoGetCacheStats))
        addButton("重置统计信息", action: #selector(demoResetStats))
        
        // 配置管理
        addSectionTitle("配置管理")
        addButton("查看当前配置", action: #selector(demoShowCurrentConfig))
        addButton("更新为小内存配置", action: #selector(demoUpdateToSmallConfig))
        addButton("更新为大内存配置", action: #selector(demoUpdateToLargeConfig))
        addButton("更新为默认配置", action: #selector(demoUpdateToDefaultConfig))
        
        // 错误处理演示
        addSectionTitle("错误处理演示")
        addButton("无效键名测试", action: #selector(demoInvalidKeyTest))
        addButton("内存警告测试", action: #selector(demoMemoryWarningTest))
    }
    
    private func addSectionTitle(_ title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16.adap)
        titleLabel.textColor = .systemBlue
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleLabel)
        
        // 添加分隔线
        let separator = UIView()
        separator.backgroundColor = .systemGray4
        separator.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(separator)
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    private func addButton(_ title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.adap, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.adap
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        stackView.addArrangedSubview(button)
        button.heightAnchor.constraint(equalToConstant: 44.adap).isActive = true
    }
    
    // MARK: - Logging
    private func log(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter().apply {
                $0.dateFormat = "HH:mm:ss"
            }.string(from: Date())
            
            let logMessage = "[\(timestamp)] \(message)\n"
            self.logTextView.text += logMessage
            
            // 自动滚动到底部
            let bottom = NSMakeRange(self.logTextView.text.count - 1, 1)
            self.logTextView.scrollRangeToVisible(bottom)
        }
    }
    
    // MARK: - Demo Actions
    
    // 基础缓存操作
    @objc private func demoStringCache() {
        log("开始字符串缓存演示")
        
        let testString = "Hello, TFYSwiftCacheKit! 这是一个测试字符串，包含中文和特殊字符：🎉🚀✨"
        
        TFYSwiftCacheKit.shared.setCache(testString, forKey: "demo_string") { result in
            switch result {
            case .success:
                self.log("✅ 字符串缓存成功")
                
                // 立即获取缓存
                TFYSwiftCacheKit.shared.getCache(String.self, forKey: "demo_string") { getResult in
                    switch getResult {
                    case .success(let cachedString):
                        self.log("✅ 获取缓存字符串成功: \(cachedString)")
                    case .failure(let error):
                        self.log("❌ 获取缓存字符串失败: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.log("❌ 字符串缓存失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func demoNumberCache() {
        log("开始数字缓存演示")
        
        let testNumber = 42.5
        
        TFYSwiftCacheKit.shared.setCache(testNumber, forKey: "demo_number") { result in
            switch result {
            case .success:
                self.log("✅ 数字缓存成功")
                
                TFYSwiftCacheKit.shared.getCache(Double.self, forKey: "demo_number") { getResult in
                    switch getResult {
                    case .success(let cachedNumber):
                        self.log("✅ 获取缓存数字成功: \(cachedNumber)")
                    case .failure(let error):
                        self.log("❌ 获取缓存数字失败: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.log("❌ 数字缓存失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func demoArrayCache() {
        log("开始数组缓存演示")
        
        let testArray = ["苹果", "香蕉", "橙子", "葡萄", "草莓"]
        
        TFYSwiftCacheKit.shared.setCache(testArray, forKey: "demo_array") { result in
            switch result {
            case .success:
                self.log("✅ 数组缓存成功")
                
                TFYSwiftCacheKit.shared.getCache([String].self, forKey: "demo_array") { getResult in
                    switch getResult {
                    case .success(let cachedArray):
                        self.log("✅ 获取缓存数组成功: \(cachedArray)")
                    case .failure(let error):
                        self.log("❌ 获取缓存数组失败: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.log("❌ 数组缓存失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func demoDictionaryCache() {
        log("开始字典缓存演示")
        
        let testDict = [
            "name": "张三",
            "age": 25,
            "city": "北京",
            "hobbies": ["读书", "游泳", "编程"]
        ] as [String: Any]
        
        // 注意：由于字典包含不同类型，需要特殊处理
        let jsonData = try? JSONSerialization.data(withJSONObject: testDict)
        if let data = jsonData {
            TFYSwiftCacheKit.shared.setDiskCache(data, forKey: "demo_dict") { result in
                switch result {
                case .success:
                    self.log("✅ 字典缓存成功")
                    
                    TFYSwiftCacheKit.shared.getDiskCache(forKey: "demo_dict") { getResult in
                        switch getResult {
                        case .success(let data):
                            if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                self.log("✅ 获取缓存字典成功: \(dict)")
                            } else {
                                self.log("❌ 解析缓存字典失败")
                            }
                        case .failure(let error):
                            self.log("❌ 获取缓存字典失败: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    self.log("❌ 字典缓存失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 自定义模型缓存
    @objc private func demoUserCache() {
        log("开始用户模型缓存演示")
        
        let user = demoUsers[0]
        
        TFYSwiftCacheKit.shared.setCache(user, forKey: "demo_user") { result in
            switch result {
            case .success:
                self.log("✅ 用户模型缓存成功: \(user.name)")
                
                TFYSwiftCacheKit.shared.getCache(CacheUser.self, forKey: "demo_user") { getResult in
                    switch getResult {
                    case .success(let cachedUser):
                        self.log("✅ 获取缓存用户成功: \(cachedUser.name) - \(cachedUser.email)")
                    case .failure(let error):
                        self.log("❌ 获取缓存用户失败: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.log("❌ 用户模型缓存失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func demoBatchUserCache() {
        log("开始批量用户缓存演示")
        
        for (index, user) in demoUsers.enumerated() {
            let key = "demo_user_\(index)"
            TFYSwiftCacheKit.shared.setCache(user, forKey: key) { result in
                switch result {
                case .success:
                    self.log("✅ 用户 \(user.name) 缓存成功")
                case .failure(let error):
                    self.log("❌ 用户 \(user.name) 缓存失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 图片缓存
    @objc private func demoSingleImageCache() {
        log("开始单张图片缓存演示")
        
        guard let image = demoImages.first else {
            log("❌ 没有可用的演示图片")
            return
        }
        
        TFYSwiftCacheKit.shared.cacheImage(image, forKey: "demo_image_single") { result in
            switch result {
            case .success:
                self.log("✅ 单张图片缓存成功，尺寸: \(image.size)")
            case .failure(let error):
                self.log("❌ 单张图片缓存失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func demoBatchImageCache() {
        log("开始批量图片缓存演示")
        
        for (index, image) in demoImages.enumerated() {
            let key = "demo_image_\(index)"
            TFYSwiftCacheKit.shared.cacheImage(image, forKey: key) { result in
                switch result {
                case .success:
                    self.log("✅ 图片 \(index) 缓存成功，尺寸: \(image.size)")
                case .failure(let error):
                    self.log("❌ 图片 \(index) 缓存失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func demoGetCachedImage() {
        log("开始获取缓存图片演示")
        
        TFYSwiftCacheKit.shared.getCachedImage(forKey: "demo_image_single") { result in
            switch result {
            case .success(let image):
                self.log("✅ 获取缓存图片成功，尺寸: \(image.size)")
            case .failure(let error):
                self.log("❌ 获取缓存图片失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 同步缓存操作
    @objc private func demoSyncSetCache() {
        log("开始同步设置缓存演示")
        
        let testData = "同步缓存测试数据"
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = TFYSwiftCacheKit.shared.setCacheSync(testData, forKey: "demo_sync_set")
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.log("✅ 同步设置缓存成功")
                case .failure(let error):
                    self.log("❌ 同步设置缓存失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func demoSyncGetCache() {
        log("开始同步获取缓存演示")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = TFYSwiftCacheKit.shared.getCacheSync(String.self, forKey: "demo_sync_set")
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cachedData):
                    self.log("✅ 同步获取缓存成功: \(cachedData)")
                case .failure(let error):
                    self.log("❌ 同步获取缓存失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 缓存管理
    @objc private func demoGetCacheSize() {
        log("开始获取缓存大小演示")
        
        TFYSwiftCacheKit.shared.getCacheSize { result in
            switch result {
            case .success(let size):
                let sizeInMB = Double(size) / (1024 * 1024)
                self.log("✅ 当前缓存大小: \(String(format: "%.2f", sizeInMB)) MB")
            case .failure(let error):
                self.log("❌ 获取缓存大小失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func demoCleanExpiredCache() {
        log("开始清理过期缓存演示")
        
        TFYSwiftCacheKit.shared.cleanExpiredCache { result in
            switch result {
            case .success:
                self.log("✅ 过期缓存清理成功")
            case .failure(let error):
                self.log("❌ 过期缓存清理失败: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func demoClearMemoryCache() {
        log("开始清空内存缓存演示")
        
        TFYSwiftCacheKit.shared.clearMemoryCache()
        log("✅ 内存缓存已清空")
    }
    
    @objc private func demoClearDiskCache() {
        log("开始清空磁盘缓存演示")
        
        TFYSwiftCacheKit.shared.clearDiskCache { result in
            switch result {
            case .success:
                self.log("✅ 磁盘缓存已清空")
            case .failure(let error):
                self.log("❌ 清空磁盘缓存失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 统计功能
    @objc private func demoGetCacheStats() {
        log("开始获取缓存统计演示")
        
        let report = TFYSwiftCacheKit.shared.getCacheReport()
        log("📊 缓存统计报告:\n\(report)")
    }
    
    @objc private func demoResetStats() {
        log("开始重置统计信息演示")
        
        TFYSwiftCacheKit.shared.resetStatistics()
        log("✅ 统计信息已重置")
    }
    
    // 配置管理
    @objc private func demoShowCurrentConfig() {
        log("开始查看当前配置演示")
        
        let config = TFYSwiftCacheKit.shared.getCurrentConfig()
        log("📋 当前配置:")
        log("- 内存缓存大小: \(config.memoryCacheSize) MB")
        log("- 磁盘缓存大小: \(config.diskCacheSize) MB")
        log("- 过期时间: \(config.expirationInterval / 3600) 小时")
        log("- 启用压缩: \(config.enableCompression)")
        log("- 启用加密: \(config.enableEncryption)")
        log("- 启用统计: \(config.enableStatistics)")
        log("- 启用自动清理: \(config.enableAutoClean)")
    }
    
    @objc private func demoUpdateToSmallConfig() {
        log("开始更新为小内存配置演示")
        
        let smallConfig = TFYCacheConfig.smallMemory()
        let success = TFYSwiftCacheKit.shared.updateConfig(smallConfig)
        
        if success {
            log("✅ 已更新为小内存配置")
        } else {
            log("❌ 更新配置失败")
        }
    }
    
    @objc private func demoUpdateToLargeConfig() {
        log("开始更新为大内存配置演示")
        
        let largeConfig = TFYCacheConfig.largeMemory()
        let success = TFYSwiftCacheKit.shared.updateConfig(largeConfig)
        
        if success {
            log("✅ 已更新为大内存配置")
        } else {
            log("❌ 更新配置失败")
        }
    }
    
    @objc private func demoUpdateToDefaultConfig() {
        log("开始更新为默认配置演示")
        
        let defaultConfig = TFYCacheConfig.default()
        let success = TFYSwiftCacheKit.shared.updateConfig(defaultConfig)
        
        if success {
            log("✅ 已更新为默认配置")
        } else {
            log("❌ 更新配置失败")
        }
    }
    
    // 错误处理演示
    @objc private func demoInvalidKeyTest() {
        log("开始无效键名测试演示")
        
        let invalidKeys = ["", "invalid/key", "invalid\\key", "invalid*key", "invalid?key"]
        
        for key in invalidKeys {
            TFYSwiftCacheKit.shared.setCache("test", forKey: key) { result in
                switch result {
                case .success:
                    self.log("⚠️ 意外成功: 键名 '\(key)' 应该被拒绝")
                case .failure(let error):
                    self.log("✅ 正确拒绝无效键名 '\(key)': \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func demoMemoryWarningTest() {
        log("开始内存警告测试演示")
        
        // 模拟内存警告
        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        log("✅ 已发送内存警告通知")
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    func apply(_ block: (DateFormatter) -> Void) -> DateFormatter {
        block(self)
        return self
    }
} 