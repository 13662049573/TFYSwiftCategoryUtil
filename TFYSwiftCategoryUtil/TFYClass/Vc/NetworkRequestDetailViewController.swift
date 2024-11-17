////
////  NetworkRequestDetailViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 网络请求详情视图控制器
//final class NetworkRequestDetailViewController: UIViewController {
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
//    private lazy var generalSection = DetailSection(title: "General")
//    private lazy var requestSection = DetailSection(title: "Request")
//    private lazy var responseSection = DetailSection(title: "Response")
//    
//    // MARK: - 属性
//    private let request: NetworkRequest
//    
//    // MARK: - 初始化
//    init(request: NetworkRequest) {
//        self.request = request
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
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        title = "Request Details"
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
//        [generalSection, requestSection, responseSection].forEach {
//            stackView.addArrangedSubview($0)
//        }
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
//            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
//        ])
//    }
//    
//    // MARK: - 数据设置
//    private func setupData() {
//        // General信息
//        generalSection.addRow(title: "URL", value: request.url)
//        generalSection.addRow(title: "Method", value: request.method)
//        generalSection.addRow(title: "Status", value: request.statusCode.map(String.init) ?? "N/A")
//        generalSection.addRow(title: "Duration", value: request.formattedDuration)
//        
//        if let error = request.error {
//            generalSection.addRow(title: "Error", value: error.localizedDescription)
//        }
//        
//        // Request信息
//        requestSection.addRow(title: "Headers", value: formatDictionary(request.requestHeaders))
//        if let body = request.formattedRequestBody {
//            requestSection.addRow(title: "Body", value: body)
//        }
//        
//        // Response信息
//        responseSection.addRow(title: "Headers", value: formatDictionary(request.responseHeaders))
//        if let body = request.formattedResponseBody {
//            responseSection.addRow(title: "Body", value: body)
//        }
//    }
//    
//    // MARK: - 辅助方法
//    private func formatDictionary(_ dict: [String: String]) -> String {
//        dict.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
//    }
//    
//    // MARK: - 动作处理
//    @objc private func shareButtonTapped() {
//        let text = """
//        URL: \(request.url)
//        Method: \(request.method)
//        Status: \(request.statusCode.map(String.init) ?? "N/A")
//        Duration: \(request.formattedDuration)
//        
//        Request Headers:
//        \(formatDictionary(request.requestHeaders))
//        
//        Request Body:
//        \(request.formattedRequestBody ?? "N/A")
//        
//        Response Headers:
//        \(formatDictionary(request.responseHeaders))
//        
//        Response Body:
//        \(request.formattedResponseBody ?? "N/A")
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
//// MARK: - 详情区域视图
//final class DetailSection: UIView {
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        return label
//    }()
//    
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.spacing = 8
//        return stack
//    }()
//    
//    init(title: String) {
//        super.init(frame: .zero)
//        titleLabel.text = title
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        addSubview(titleLabel)
//        addSubview(stackView)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//            
//            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//    
//    func addRow(title: String, value: String) {
//        let row = DetailRow(title: title, value: value)
//        stackView.addArrangedSubview(row)
//    }
//}
//
//// MARK: - 详情行视图
//final class DetailRow: UIView {
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .secondaryLabel
//        return label
//    }()
//    
//    private lazy var valueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .label
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    init(title: String, value: String) {
//        super.init(frame: .zero)
//        titleLabel.text = title
//        valueLabel.text = value
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            titleLabel.widthAnchor.constraint(equalToConstant: 80),
//            
//            valueLabel.topAnchor.constraint(equalTo: topAnchor),
//            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
//            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//}
