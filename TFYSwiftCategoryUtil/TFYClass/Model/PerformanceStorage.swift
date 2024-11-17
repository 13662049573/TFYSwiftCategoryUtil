////
////  PerformanceStorage.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 性能数据存储管理器
//final class PerformanceStorage {
//    
//    // MARK: - 属性
//    private let fileManager = FileManager.default
//    private let decoder = JSONDecoder()
//    private let encoder = JSONEncoder()
//    
//    private var performanceDirectory: URL {
//        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls[0].appendingPathComponent("performance")
//    }
//    
//    // MARK: - 初始化
//    init() {
//        createDirectoryIfNeeded()
//    }
//    
//    // MARK: - 公共方法
//    func saveProfile(_ profile: PerformanceProfile) {
//        do {
//            let data = try encoder.encode(profile)
//            let fileURL = performanceDirectory.appendingPathComponent("\(profile.startTime.timeIntervalSince1970).perf")
//            try data.write(to: fileURL)
//        } catch {
//            print("Failed to save performance profile: \(error)")
//        }
//    }
//    
//    func loadProfiles() -> [PerformanceProfile] {
//        var profiles: [PerformanceProfile] = []
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(at: performanceDirectory, includingPropertiesForKeys: nil)
//            for file in files {
//                if let data = try? Data(contentsOf: file),
//                   let profile = try? decoder.decode(PerformanceProfile.self, from: data) {
//                    profiles.append(profile)
//                }
//            }
//        } catch {
//            print("Failed to load performance profiles: \(error)")
//        }
//        
//        return profiles.sorted { $0.startTime > $1.startTime }
//    }
//    
//    func clearProfiles() {
//        do {
//            let files = try fileManager.contentsOfDirectory(at: performanceDirectory, includingPropertiesForKeys: nil)
//            for file in files {
//                try fileManager.removeItem(at: file)
//            }
//        } catch {
//            print("Failed to clear performance profiles: \(error)")
//        }
//    }
//    
//    private func createDirectoryIfNeeded() {
//        do {
//            try fileManager.createDirectory(at: performanceDirectory, withIntermediateDirectories: true)
//        } catch {
//            print("Failed to create performance directory: \(error)")
//        }
//    }
//}
//
//// MARK: - 性能图表绘制视图
//final class PerformanceChartView: UIView {
//    
//    // MARK: - UI组件
//    private let graphLayer = CAShapeLayer()
//    private let gradientLayer = CAGradientLayer()
//    private let gridLayer = CAShapeLayer()
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .label
//        return label
//    }()
//    
//    private lazy var valueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.textColor = .label
//        return label
//    }()
//    
//    // MARK: - 属性
//    private var dataPoints: [Double] = []
//    private let maxDataPoints: Int
//    private let formatter: (Double) -> String
//    
//    // MARK: - 初始化
//    init(title: String, maxDataPoints: Int = 60, formatter: @escaping (Double) -> String) {
//        self.maxDataPoints = maxDataPoints
//        self.formatter = formatter
//        super.init(frame: .zero)
//        titleLabel.text = title
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        layer.addSublayer(gridLayer)
//        layer.addSublayer(gradientLayer)
//        layer.addSublayer(graphLayer)
//        
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            
//            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            valueLabel.heightAnchor.constraint(equalToConstant: 24)
//        ])
//        
//        setupLayers()
//    }
//    
//    private func setupLayers() {
//        gridLayer.strokeColor = UIColor.systemGray5.cgColor
//        gridLayer.lineWidth = 0.5
//        
//        graphLayer.fillColor = nil
//        graphLayer.strokeColor = UIColor.systemBlue.cgColor
//        graphLayer.lineWidth = 2
//        
//        gradientLayer.colors = [
//            UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
//            UIColor.systemBlue.withAlphaComponent(0.1).cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
//    }
//    
//    // MARK: - 布局
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let graphRect = CGRect(
//            x: 0,
//            y: 44,
//            width: bounds.width,
//            height: bounds.height - 44
//        )
//        
//        gradientLayer.frame = graphRect
//        updateGraph()
//        drawGrid(in: graphRect)
//    }
//    
//    // MARK: - 数据更新
//    func update(with values: [Double]) {
//        dataPoints = values.suffix(maxDataPoints)
//        if let lastValue = values.last {
//            valueLabel.text = formatter(lastValue)
//        }
//        setNeedsLayout()
//    }
//    
//    // MARK: - 绘制方法
//    private func updateGraph() {
//        guard !dataPoints.isEmpty else { return }
//        
//        let graphRect = CGRect(
//            x: 0,
//            y: 44,
//            width: bounds.width,
//            height: bounds.height - 44
//        )
//        
//        let maxValue = dataPoints.max() ?? 1
//        let path = UIBezierPath()
//        let fillPath = UIBezierPath()
//        
//        let stepX = graphRect.width / CGFloat(maxDataPoints - 1)
//        let stepY = graphRect.height / CGFloat(maxValue)
//        
//        fillPath.move(to: CGPoint(x: graphRect.minX, y: graphRect.maxY))
//        
//        for (index, value) in dataPoints.enumerated() {
//            let point = CGPoint(
//                x: graphRect.minX + CGFloat(index) * stepX,
//                y: graphRect.maxY - CGFloat(value) * stepY
//            )
//            
//            if index == 0 {
//                path.move(to: point)
//                fillPath.addLine(to: point)
//            } else {
//                path.addLine(to: point)
//                fillPath.addLine(to: point)
//            }
//        }
//        
//        fillPath.addLine(to: CGPoint(x: graphRect.maxX, y: graphRect.maxY))
//        fillPath.close()
//        
//        graphLayer.path = path.cgPath
//        gradientLayer.mask = {
//            let maskLayer = CAShapeLayer()
//            maskLayer.path = fillPath.cgPath
//            return maskLayer
//        }()
//    }
//    
//    private func drawGrid(in rect: CGRect) {
//        let path = UIBezierPath()
//        
//        // 绘制水平网格线
//        let horizontalSpacing = rect.height / 4
//        for i in 0...4 {
//            let y = rect.minY + CGFloat(i) * horizontalSpacing
//            path.move(to: CGPoint(x: rect.minX, y: y))
//            path.addLine(to: CGPoint(x: rect.maxX, y: y))
//        }
//        
//        // 绘制垂直网格线
//        let verticalSpacing = rect.width / 6
//        for i in 0...6 {
//            let x = rect.minX + CGFloat(i) * verticalSpacing
//            path.move(to: CGPoint(x: x, y: rect.minY))
//            path.addLine(to: CGPoint(x: x, y: rect.maxY))
//        }
//        
//        gridLayer.path = path.cgPath
//    }
//}
