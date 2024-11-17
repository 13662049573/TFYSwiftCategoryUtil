////
////  CrashDetailViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 崩溃详情视图控制器
//final class CrashDetailViewController: UIViewController {
//    
//    // MARK: - UI组件
//    private lazy var scrollView: UIScrollView = {
//        let scroll = UIScrollView()
//        scroll.translatesAutoresizingMaskIntoConstraints = false
//        return scroll
//    }()
//    
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.spacing = 16
//        return stack
//    }()
//    
//    private lazy var crashSection = DetailSection(title: "Crash Information")
//    private lazy var deviceSection = DetailSection(title: "Device Information")
//    private lazy var stackTraceSection = DetailSection(title: "Stack Trace")
//    
//    private lazy var stackTraceTextView: UITextView = {
//        let textView = UITextView()
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.isEditable = false
//        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
//        textView.textColor = .label
//        textView.backgroundColor = .secondarySystemBackground
//        textView.layer.cornerRadius = 8
//        return textView
//    }()
//    
//    // MARK: - 属性
//    private let report: CrashReport
//    private let analyzer = CrashAnalyzer()
//    
//    // MARK: - 初始化
//    init(report: CrashReport) {
//        self.report = report
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - 生命周期
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupData()
//        analyzeCrash()
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Crash Details"
//        view.backgroundColor = .systemBackground
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "square.and.arrow.up"),
//            style: .plain,
//            target: self,
//            action: #selector(shareButtonTapped)
//        )
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(stackView)
//        
//        [crashSection, deviceSection, stackTraceSection].forEach {
//            stackView.addArrangedSubview($0)
//        }
//        
//        stackTraceSection.addArrangedSubview(stackTraceTextView)
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
//            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
//            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
//            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
//            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
//            
//            stackTraceTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
//        ])
//    }
//    
//    // MARK: - 数据设置
//    private func setupData() {
//        // 崩溃信息
//        crashSection.addRow(title: "Type", value: report.type.rawValue.capitalized)
//        crashSection.addRow(title: "Name", value: report.name)
//        crashSection.addRow(title: "Reason", value: report.reason)
//        crashSection.addRow(title: "Time", value: report.formattedTimestamp)
//        
//        // 设备信息
//        deviceSection.addRow(title: "Device", value: report.deviceInfo.deviceModel)
//        deviceSection.addRow(title: "OS", value: "\(report.deviceInfo.systemName) \(report.deviceInfo.systemVersion)")
//        deviceSection.addRow(title: "App Version", value: "\(report.deviceInfo.appVersion) (\(report.deviceInfo.appBuild))")
//        
//        // 堆栈信息
//        stackTraceTextView.text = report.callStack.joined(separator: "\n")
//    }
//    
//    // MARK: - 崩溃分析
//    private func analyzeCrash() {
//        let analysis = analyzer.analyze(report)
//        
//        if !analysis.isEmpty {
//            let analysisSection = DetailSection(title: "Analysis")
//            stackView.insertArrangedSubview(analysisSection, at: 1)
//            
//            analysis.forEach { item in
//                analysisSection.addRow(
//                    title: item.severity.icon,
//                    value: item.message,
//                    valueColor: item.severity.color
//                )
//            }
//        }
//    }
//    
//    // MARK: - 动作处理
//    @objc private func shareButtonTapped() {
//        let text = """
//        Crash Report
//        
//        Type: \(report.type.rawValue.capitalized)
//        Name: \(report.name)
//        Reason: \(report.reason)
//        Time: \(report.formattedTimestamp)
//        
//        Device Information:
//        Device: \(report.deviceInfo.deviceModel)
//        OS: \(report.deviceInfo.systemName) \(report.deviceInfo.systemVersion)
//        App Version: \(report.deviceInfo.appVersion) (\(report.deviceInfo.appBuild))
//        
//        Stack Trace:
//        \(report.callStack.joined(separator: "\n"))
//        """
//        
//        let activityVC = UIActivityViewController(
//            activityItems: [text],
//            applicationActivities: nil
//        )
//        present(activityVC, animated: true)
//    }
//}
//
//// MARK: - 崩溃分析器
//final class CrashAnalyzer {
//    
//    enum Severity {
//        case info
//        case warning
//        case error
//        
//        var icon: String {
//            switch self {
//            case .info: return "ℹ️"
//            case .warning: return "⚠️"
//            case .error: return "❌"
//            }
//        }
//        
//        var color: UIColor {
//            switch self {
//            case .info: return .systemBlue
//            case .warning: return .systemYellow
//            case .error: return .systemRed
//            }
//        }
//    }
//    
//    struct AnalysisItem {
//        let severity: Severity
//        let message: String
//    }
//    
//    func analyze(_ report: CrashReport) -> [AnalysisItem] {
//        var items: [AnalysisItem] = []
//        
//        // 分析崩溃类型
//        switch report.type {
//        case .exception:
//            if report.name.contains("NSInvalidArgumentException") {
//                items.append(AnalysisItem(
//                    severity: .error,
//                    message: "Invalid argument exception, possibly due to incorrect parameter passing"
//                ))
//            }
//        case .signal:
//            if report.name.contains("SIGSEGV") {
//                items.append(AnalysisItem(
//                    severity: .error,
//                    message: "Memory access violation, possibly due to accessing deallocated object"
//                ))
//            }
//        }
//        
//        // 分析堆栈信息
//        let stackTrace = report.callStack.joined(separator: " ")
//        if stackTrace.contains("pthread_kill") {
//            items.append(AnalysisItem(
//                severity: .warning,
//                message: "Thread termination detected, possible deadlock or timeout"
//            ))
//        }
//        
//        return items
//    }
//}
