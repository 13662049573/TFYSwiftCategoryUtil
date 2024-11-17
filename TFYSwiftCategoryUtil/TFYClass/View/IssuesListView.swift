////
////  IssuesListView.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// MARK: - 问题列表视图
//final class IssuesListView: UIView {
//    
//    // MARK: - UI组件
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.text = "Detected Issues"
//        return label
//    }()
//    
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.spacing = 12
//        return stack
//    }()
//    
//    // MARK: - 初始化
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        backgroundColor = .secondarySystemBackground
//        layer.cornerRadius = 12
//        
//        addSubview(titleLabel)
//        addSubview(stackView)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            
//            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
//        ])
//    }
//    
//    // MARK: - 更新
//    func update(with issues: [PerformanceIssue]) {
//        // 清除现有视图
//        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        if issues.isEmpty {
//            let emptyLabel = UILabel()
//            emptyLabel.text = "No issues detected"
//            emptyLabel.textColor = .secondaryLabel
//            emptyLabel.textAlignment = .center
//            stackView.addArrangedSubview(emptyLabel)
//        } else {
//            issues.forEach { issue in
//                let issueView = IssueItemView(issue: issue)
//                stackView.addArrangedSubview(issueView)
//            }
//        }
//    }
//}
//
//// MARK: - 问题项视图
//final class IssueItemView: UIView {
//    
//    // MARK: - UI组件
//    private lazy var containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.layer.cornerRadius = 8
//        return view
//    }()
//    
//    private lazy var severityIndicator: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 4
//        return view
//    }()
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    private lazy var descriptionLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .secondaryLabel
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    // MARK: - 初始化
//    init(issue: PerformanceIssue) {
//        super.init(frame: .zero)
//        setupUI()
//        configure(with: issue)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - UI设置
//    private func setupUI() {
//        addSubview(containerView)
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        
//        [severityIndicator, titleLabel, descriptionLabel].forEach {
//            containerView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: topAnchor),
//            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            
//            severityIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
//            severityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
//            severityIndicator.widthAnchor.constraint(equalToConstant: 8),
//            severityIndicator.heightAnchor.constraint(equalToConstant: 8),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: severityIndicator.trailingAnchor, constant: 12),
//            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
//            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
//            
//            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
//        ])
//    }
//    
//    // MARK: - 配置
//    private func configure(with issue: PerformanceIssue) {
//        titleLabel.text = issue.title
//        descriptionLabel.text = issue.description
//        
//        severityIndicator.backgroundColor = {
//            switch issue.severity {
//            case .low: return .systemYellow
//            case .medium: return .systemOrange
//            case .high: return .systemRed
//            }
//        }()
//        
//        // 添加阴影效果
//        containerView.layer.shadowColor = UIColor.black.cgColor
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        containerView.layer.shadowRadius = 4
//        containerView.layer.shadowOpacity = 0.1
//    }
//}
//
//// MARK: - 性能问题模型
//struct PerformanceIssue {
//    enum Severity {
//        case low
//        case medium
//        case high
//    }
//    
//    let title: String
//    let description: String
//    let severity: Severity
//    let timestamp: Date
//    let metric: String
//    let value: Double
//    let threshold: Double
//}
