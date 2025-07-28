//
//  ViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/9.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - 属性
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let resultLabel = UILabel()
    private let controlPanel = UIView()
    
    // 测试图片数组 - 使用真实的图片资源
    private let testImages: [UIImage] = [
        UIImage(named: "login_logo") ?? UIImage(),
        UIImage(named: "mine_banner") ?? UIImage(),
        UIImage(named: "vip_bg") ?? UIImage(),
        UIImage(named: "home_bg") ?? UIImage(),
        UIImage(named: "mine_bg") ?? UIImage(),
        UIImage(named: "login_bg") ?? UIImage(),
        UIImage(named: "mine_cloud") ?? UIImage(),
        UIImage(named: "vip_status") ?? UIImage(),
        UIImage(named: "mine_scan") ?? UIImage(),
        UIImage(named: "mine_setting") ?? UIImage(),
        UIImage(named: "mine_order") ?? UIImage(),
        UIImage(named: "mine_quest") ?? UIImage(),
        UIImage(named: "mine_live") ?? UIImage(),
        UIImage(named: "mine_feedback") ?? UIImage(),
        UIImage(named: "mine_authentication") ?? UIImage(),
        UIImage(named: "mine_accredit") ?? UIImage(),
        UIImage(named: "vip_live") ?? UIImage(),
        UIImage(named: "vip_game") ?? UIImage(),
        UIImage(named: "vip_manage") ?? UIImage(),
        UIImage(named: "vip_broadcast") ?? UIImage(),
        UIImage(named: "vip_top") ?? UIImage(),
        UIImage(named: "vip_more") ?? UIImage(),
        UIImage(named: "vip_refresh") ?? UIImage(),
        UIImage(named: "vip_max_add") ?? UIImage(),
        UIImage(named: "vip_min_add") ?? UIImage(),
        UIImage(named: "vip_empty") ?? UIImage(),
        UIImage(named: "vip_down") ?? UIImage(),
        UIImage(named: "vip_all") ?? UIImage(),
        UIImage(named: "vip_anyway") ?? UIImage(),
        UIImage(named: "mine_xingxing") ?? UIImage(),
        UIImage(named: "mine_stimulate_bg") ?? UIImage(),
        UIImage(named: "mine_sign") ?? UIImage(),
        UIImage(named: "mine_space") ?? UIImage(),
        UIImage(named: "mine_se_avaer") ?? UIImage(),
        UIImage(named: "mine_he_right") ?? UIImage(),
        UIImage(named: "mine_de_avaer") ?? UIImage(),
        UIImage(named: "mine_blue_right") ?? UIImage(),
        UIImage(named: "mine_batch") ?? UIImage(),
        UIImage(named: "login_sel") ?? UIImage(),
        UIImage(named: "mein_bg") ?? UIImage(),
        UIImage(named: "login_def") ?? UIImage(),
        UIImage(named: "login_arrow") ?? UIImage(),
        UIImage(named: "loginBtn_Nor") ?? UIImage(),
        UIImage(named: "login_Off") ?? UIImage(),
        UIImage(named: "loginBtn_Dis") ?? UIImage(),
        UIImage(named: "loginBtn_Hig") ?? UIImage(),
        UIImage(named: "langebg") ?? UIImage(),
        UIImage(named: "home_search") ?? UIImage(),
        UIImage(named: "emp_data_graph") ?? UIImage(),
        UIImage(named: "default_device") ?? UIImage(),
        UIImage(named: "details_eye") ?? UIImage(),
        UIImage(named: "btn_white") ?? UIImage()
    ]
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "TFYStitchImage 功能展示"
        
        // 设置滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // 设置内容视图
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 设置图片显示区域
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        
        // 设置结果标签
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.font = .systemFont(ofSize: 14)
        resultLabel.textColor = .secondaryLabel
        contentView.addSubview(resultLabel)
        
        // 设置控制面板
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.backgroundColor = .systemGray6
        controlPanel.layer.cornerRadius = 12
        contentView.addSubview(controlPanel)
        
        setupControlPanel()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 滚动视图约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 内容视图约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 图片视图约束
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            // 结果标签约束
            resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 控制面板约束
            controlPanel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            controlPanel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            controlPanel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            controlPanel.heightAnchor.constraint(greaterThanOrEqualToConstant: 600)
        ])
    }
    
    private func setupControlPanel() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: -16)
        ])
        
        // 添加各种功能按钮
        let buttons = [
            ("九宫格布局", #selector(showNineGrid)),
            ("瀑布流布局", #selector(showWaterfall)),
            ("横向布局", #selector(showHorizontal)),
            ("纵向布局", #selector(showVertical)),
            ("圆形布局", #selector(showCircular)),
            ("螺旋布局", #selector(showSpiral)),
            ("随机布局", #selector(showRandom)),
            ("带阴影效果", #selector(showWithShadow)),
            ("带边框效果", #selector(showWithBorder)),
            ("带圆角效果", #selector(showWithCornerRadius)),
            ("异步处理", #selector(showAsyncProcessing)),
            ("分页处理", #selector(showPagination)),
            ("自定义布局", #selector(showCustomLayout)),
            ("滤镜效果", #selector(showWithFilter)),
            ("批量处理", #selector(showBatchProcessing)),
            ("缓存管理", #selector(showCacheManagement)),
            ("性能监控", #selector(showPerformanceMonitoring)),
            ("大量图片拼接", #selector(showLargeImageStitch))
        ]
        
        for (title, action) in buttons {
            let button = createButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    private func setupActions() {
        // 验证图片资源加载
        validateImageResources()
        // 默认显示九宫格布局
        showNineGrid()
    }
    
    // MARK: - 图片资源验证
    
    private func validateImageResources() {
        var loadedCount = 0
        var failedCount = 0
        var failedImages: [String] = []
        
        for (index, image) in testImages.enumerated() {
            if image.size.width > 0 && image.size.height > 0 {
                loadedCount += 1
            } else {
                failedCount += 1
                // 获取图片名称（这里简化处理）
                let imageNames = [
                    "login_logo", "mine_banner", "vip_bg", "home_bg", "mine_bg", 
                    "login_bg", "mine_cloud", "vip_status", "mine_scan", "mine_setting",
                    "mine_order", "mine_quest", "mine_live", "mine_feedback", "mine_authentication",
                    "mine_accredit", "vip_live", "vip_game", "vip_manage", "vip_broadcast",
                    "vip_top", "vip_more", "vip_refresh", "vip_max_add", "vip_min_add",
                    "vip_empty", "vip_down", "vip_all", "vip_anyway", "mine_xingxing",
                    "mine_stimulate_bg", "mine_sign", "mine_space", "mine_se_avaer",
                    "mine_he_right", "mine_de_avaer", "mine_blue_right", "mine_batch",
                    "login_sel", "mein_bg", "login_def", "login_arrow", "loginBtn_Nor",
                    "login_Off", "loginBtn_Dis", "loginBtn_Hig", "langebg", "home_search",
                    "emp_data_graph", "default_device", "details_eye", "btn_white"
                ]
                if index < imageNames.count {
                    failedImages.append(imageNames[index])
                }
            }
        }
        
        print("TFYStitchImage 图片资源验证结果:")
        print("成功加载: \(loadedCount) 张图片")
        print("加载失败: \(failedCount) 张图片")
        if !failedImages.isEmpty {
            print("失败的图片: \(failedImages)")
        }
    }
    
    // MARK: - 功能展示方法
    
    @objc private func showNineGrid() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(9)),
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("九宫格布局", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("九宫格布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showWaterfall() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let config = TFYStitchConfig.waterfall(columns: 3, gap: 6)
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(15)), // 使用更多图片
            size: CGSize(width: 300, height: 400),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("瀑布流布局 (15张图片)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("瀑布流布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showHorizontal() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let config = TFYStitchConfig.horizontal(gap: 4, keepAspectRatio: false) // 使用固定宽度
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(5)),
            size: CGSize(width: 350, height: 120),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("横向布局 (5张图片)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("横向布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showVertical() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let config = TFYStitchConfig.vertical(gap: 4, keepAspectRatio: false) // 使用固定高度
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(4)),
            size: CGSize(width: 120, height: 350),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("纵向布局 (4张图片)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("纵向布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showCircular() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 使用配置方式而不是便利方法
        var config = TFYStitchConfig()
        config.layoutType = .circular(radius: 100)
        config.gap = 8
        config.keepAspectRatio = false // 不使用宽高比，确保图片能完整显示
        config.contentMode = .scaleToFill
        
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(6)),
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("圆形布局 (6张图片)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("圆形布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showSpiral() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 使用配置方式而不是便利方法
        var config = TFYStitchConfig()
        config.layoutType = .spiral
        config.gap = 8
        config.keepAspectRatio = false // 不使用宽高比，确保图片能完整显示
        config.contentMode = .scaleToFill
        
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(8)),
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("螺旋布局 (8张图片)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("螺旋布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showRandom() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 使用配置方式而不是便利方法
        var config = TFYStitchConfig()
        config.layoutType = .random
        config.gap = 8
        config.keepAspectRatio = false // 不使用宽高比，确保图片能完整显示
        config.contentMode = .scaleToFill
        
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(6)), // 减少到6张图片，确保有足够空间
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("随机布局 (6张图片)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("随机布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showWithShadow() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var config = TFYStitchConfig.nineGrid(gap: 6, cornerRadius: 12)
        config.enableShadow = true
        config.shadowConfig.color = .black
        config.shadowConfig.offset = CGSize(width: 0, height: 4)
        config.shadowConfig.radius = 8
        config.shadowConfig.opacity = 0.3
        
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(9)),
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("带阴影效果", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("带阴影效果失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showWithBorder() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        config.enableBorder = true
        config.borderConfig.color = .systemBlue
        config.borderConfig.width = 2
        config.borderConfig.style = .solid
        
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(9)),
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("带边框效果", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("带边框效果失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showWithCornerRadius() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var config = TFYStitchConfig.nineGrid(gap: 6, cornerRadius: 16)
        config.backgroundColor = .systemGray5
        
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(9)),
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("带圆角效果", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("带圆角效果失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showAsyncProcessing() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        config.enableAsync = true
        
        TFYStitchImage.stitchImages(
            images: Array(testImages.prefix(9)),
            size: CGSize(width: 300, height: 300),
            config: config
        ) { result in
            DispatchQueue.main.async {
                if result.isSuccess, let image = result.images.first {
                    self.imageView.image = image
                    self.updateResultLabel("异步处理", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
                } else {
                    self.updateResultLabel("异步处理失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
                }
            }
        }
        
        updateResultLabel("正在异步处理...", processingTime: 0)
    }
    
    @objc private func showPagination() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        config.itemsPerPage = 4 // 每页4张图片
        
        let result = TFYStitchImage.stitchImagesSync(
            images: testImages,
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("分页处理 (共\(result.images.count)页)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("分页处理失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showCustomLayout() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var config = TFYStitchConfig()
        config.layoutType = .custom { count, size, gap in
            var frames: [CGRect] = []
            let itemSize = CGSize(width: 80, height: 80)
            
            for i in 0..<count {
                let x = CGFloat(i % 3) * (itemSize.width + gap) + gap
                let y = CGFloat(i / 3) * (itemSize.height + gap) + gap
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: itemSize))
            }
            
            return frames
        }
        config.gap = 10
        config.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(6)),
            size: CGSize(width: 300, height: 200),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("自定义布局", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("自定义布局失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showWithFilter() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(9)),
            size: CGSize(width: 300, height: 300),
            config: config
        )
        
        if result.isSuccess, let originalImage = result.images.first {
            // 应用黑白滤镜
            let grayscaleFilter = CIFilter(name: "CIColorControls")
            grayscaleFilter?.setValue(CIImage(image: originalImage), forKey: kCIInputImageKey)
            grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey)
            
            if let outputImage = grayscaleFilter?.outputImage,
               let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) {
                let filteredImage = UIImage(cgImage: cgImage)
                imageView.image = filteredImage
                updateResultLabel("滤镜效果 (黑白)", processingTime: CFAbsoluteTimeGetCurrent() - startTime)
            } else {
                imageView.image = originalImage
                updateResultLabel("滤镜效果失败", processingTime: CFAbsoluteTimeGetCurrent() - startTime)
            }
        } else {
            updateResultLabel("滤镜效果失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    @objc private func showBatchProcessing() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let imageGroups = [
            Array(testImages.prefix(4)),
            Array(testImages.prefix(6)),
            Array(testImages.prefix(9))
        ]
        
        let config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        
        TFYStitchImage.batchStitch(
            imageGroups: imageGroups,
            size: CGSize(width: 300, height: 300),
            config: config
        ) { results in
            DispatchQueue.main.async {
                if let firstResult = results.first, firstResult.isSuccess, let image = firstResult.images.first {
                    self.imageView.image = image
                    self.updateResultLabel("批量处理 (共\(results.count)组)", processingTime: CFAbsoluteTimeGetCurrent() - startTime)
                } else {
                    self.updateResultLabel("批量处理失败", processingTime: CFAbsoluteTimeGetCurrent() - startTime)
                }
            }
        }
        
        updateResultLabel("正在批量处理...", processingTime: 0)
    }
    
    @objc private func showCacheManagement() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 显示缓存信息
        let cacheSize = TFYStitchImage.getCacheSize()
        let statistics = TFYStitchImage.getStatistics()
        
        // 清除缓存
        TFYStitchImage.clearCache()
        
        updateResultLabel("缓存管理\n缓存大小: \(cacheSize)\n队列: \(statistics.processingQueueLabel)", processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        
        // 显示一个简单的拼接结果
        let config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        let result = TFYStitchImage.stitchImagesSync(
            images: Array(testImages.prefix(4)),
            size: CGSize(width: 200, height: 200),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
        }
    }
    
    @objc private func showPerformanceMonitoring() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 设置性能监控
        let performanceConfig = TFYStitchImage.PerformanceConfig()
        TFYStitchImage.setPerformanceConfig(performanceConfig)
        
        // 执行多次拼接测试性能
        let config = TFYStitchConfig.nineGrid(gap: 4, cornerRadius: 8)
        var totalTime: TimeInterval = 0
        let iterations = 5
        
        for i in 0..<iterations {
            let iterationStart = CFAbsoluteTimeGetCurrent()
            let result = TFYStitchImage.stitchImagesSync(
                images: Array(testImages.prefix(9)),
                size: CGSize(width: 300, height: 300),
                config: config
            )
            totalTime += CFAbsoluteTimeGetCurrent() - iterationStart
            
            if result.isSuccess, let image = result.images.first, i == iterations - 1 {
                imageView.image = image
            }
        }
        
        let averageTime = totalTime / Double(iterations)
        updateResultLabel("性能监控\n平均处理时间: \(String(format: "%.3f", averageTime))s\n总时间: \(String(format: "%.3f", totalTime))s", processingTime: CFAbsoluteTimeGetCurrent() - startTime)
    }
    
    @objc private func showLargeImageStitch() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 使用所有可用的图片进行拼接
        var config = TFYStitchConfig()
        config.layoutType = .fixedGrid(columns: 5)
        config.gap = 4
        config.cornerRadius = 6
        config.maxImageCount = 25 // 限制最大数量
        
        let result = TFYStitchImage.stitchImagesSync(
            images: testImages,
            size: CGSize(width: 350, height: 350),
            config: config
        )
        
        if result.isSuccess, let image = result.images.first {
            imageView.image = image
            updateResultLabel("大量图片拼接 (5x5网格, 25张图片)", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        } else {
            updateResultLabel("大量图片拼接失败", result: result, processingTime: CFAbsoluteTimeGetCurrent() - startTime)
        }
    }
    
    // MARK: - 辅助方法
    
    private func updateResultLabel(_ title: String, result: TFYStitchResult? = nil, processingTime: TimeInterval = 0) {
        var text = "当前功能: \(title)\n"
        
        // 添加图片资源信息
        let validImages = testImages.filter { $0.size.width > 0 && $0.size.height > 0 }
        text += "可用图片: \(validImages.count)/\(testImages.count)\n"
        
        if let result = result {
            text += "状态: \(result.isSuccess ? "成功" : "失败")\n"
            text += "处理时间: \(String(format: "%.3f", result.processingTime))s\n"
            text += "图片数量: \(result.images.count)\n"
            if let error = result.error {
                text += "错误: \(error.localizedDescription)\n"
            }
        } else if processingTime > 0 {
            text += "处理时间: \(String(format: "%.3f", processingTime))s\n"
        }
        
        resultLabel.text = text
    }
}

// MARK: - TFYStitchImage 功能总结
/*
TFYStitchImage 功能总结:

1. 布局类型 (TFYStitchLayoutType):
   - grid: 自动网格布局
   - fixedGrid(columns: Int): 固定列数网格
   - horizontal: 横向布局
   - vertical: 纵向布局
   - waterfall(columns: Int): 瀑布流布局
   - circular(radius: CGFloat): 圆形布局
   - spiral: 螺旋布局
   - random: 随机布局
   - custom: 自定义布局

2. 配置选项 (TFYStitchConfig):
   - gap: 图片间距
   - backgroundColor: 背景颜色
   - layoutType: 布局类型
   - keepAspectRatio: 保持宽高比
   - maxImageCount: 最大图片数量
   - cornerRadius: 圆角大小
   - contentInsets: 边距
   - itemsPerPage: 每页数量
   - imageQuality: 图片质量
   - enableCache: 启用缓存
   - cacheExpirationTime: 缓存过期时间
   - enableAsync: 异步处理
   - contentMode: 缩放模式
   - enableShadow: 启用阴影
   - enableBorder: 启用边框

3. 主要方法:
   - stitchImages(): 异步拼接
   - stitchImagesSync(): 同步拼接
   - createNineGrid(): 创建九宫格
   - createWaterfall(): 创建瀑布流
   - createHorizontal(): 创建横向布局
   - createVertical(): 创建纵向布局
   - createCircular(): 创建圆形布局
   - createSpiral(): 创建螺旋布局
   - createRandom(): 创建随机布局
   - createWithShadow(): 带阴影效果
   - createWithBorder(): 带边框效果
   - batchStitch(): 批量处理
   - clearCache(): 清除缓存
   - getCacheSize(): 获取缓存大小

4. 错误处理 (TFYStitchError):
   - emptyImages: 图片数组为空
   - invalidSize: 无效尺寸
   - invalidConfig: 无效配置
   - processingFailed: 处理失败
   - cacheError: 缓存错误
   - memoryError: 内存错误

5. 高级功能:
   - 滤镜效果支持
   - 性能监控
   - 内存管理
   - 异步处理
   - 缓存机制
   - 批量处理
   - 自定义布局
*/

