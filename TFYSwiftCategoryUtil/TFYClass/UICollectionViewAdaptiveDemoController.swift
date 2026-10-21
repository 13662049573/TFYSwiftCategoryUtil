//
//  UICollectionViewAdaptiveDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFYSwift on 2025/1/24.
//  UICollectionView自适应功能展示容器
//

import UIKit

// MARK: - 演示项目模型
struct CollectionDemoItem {
    let title: String
    let description: String
    let action: CollectionDemoAction
    let icon: String
}

enum CollectionDemoAction {
    case autoSizingFlowLayout
    case compositionalLayout
    case gridLayout
    case waterfallLayout
    case horizontalLayout
    case cardLayout
    case highPerformanceLayout
    case customCell
    case batchUpdates
    case prefetching
    case dragDrop
    case focusSupport
    case accessibility
    case performance
}

// MARK: - 主控制器
class UICollectionViewAdaptiveDemoController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private let demoItems: [CollectionDemoItem] = [
        // 基础自适应布局
        CollectionDemoItem(
            title: "FlowLayout自适应",
            description: "使用UICollectionViewFlowLayout实现自适应高度",
            action: .autoSizingFlowLayout,
            icon: "📱"
        ),
        CollectionDemoItem(
            title: "CompositionalLayout",
            description: "iOS 13+ 高性能组合布局",
            action: .compositionalLayout,
            icon: "🎨"
        ),
        CollectionDemoItem(
            title: "网格布局",
            description: "多列网格自适应布局",
            action: .gridLayout,
            icon: "🔲"
        ),
        CollectionDemoItem(
            title: "瀑布流布局",
            description: "Pinterest风格的瀑布流布局",
            action: .waterfallLayout,
            icon: "🌊"
        ),
        CollectionDemoItem(
            title: "水平滚动布局",
            description: "水平滚动的卡片布局",
            action: .horizontalLayout,
            icon: "➡️"
        ),
        CollectionDemoItem(
            title: "卡片布局",
            description: "大卡片式布局展示",
            action: .cardLayout,
            icon: "🃏"
        ),
        
        // 高级功能
        CollectionDemoItem(
            title: "高性能布局",
            description: "iOS 16+ 优化性能的布局",
            action: .highPerformanceLayout,
            icon: "⚡"
        ),
        CollectionDemoItem(
            title: "自定义Cell",
            description: "展示自定义自适应Cell",
            action: .customCell,
            icon: "🎯"
        ),
        CollectionDemoItem(
            title: "批量更新",
            description: "安全的批量更新操作",
            action: .batchUpdates,
            icon: "🔄"
        ),
        CollectionDemoItem(
            title: "预取功能",
            description: "iOS 16+ 数据预取优化",
            action: .prefetching,
            icon: "🚀"
        ),
        CollectionDemoItem(
            title: "拖拽排序",
            description: "拖拽重新排序功能",
            action: .dragDrop,
            icon: "✋"
        ),
        CollectionDemoItem(
            title: "焦点支持",
            description: "tvOS和键盘焦点支持",
            action: .focusSupport,
            icon: "🎮"
        ),
        CollectionDemoItem(
            title: "无障碍支持",
            description: "VoiceOver等无障碍功能",
            action: .accessibility,
            icon: "♿"
        ),
        CollectionDemoItem(
            title: "性能监控",
            description: "实时性能指标监控",
            action: .performance,
            icon: "📊"
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "UICollectionView自适应演示"
        view.backgroundColor = .systemGroupedBackground
        
        setupScrollView()
        setupContentView()
        setupStackView()
        addDemoItems()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "设置",
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
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
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func addDemoItems() {
        // 添加标题
        let titleLabel = UILabel()
        titleLabel.text = "UICollectionView自适应功能演示"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        stackView.addArrangedSubview(titleContainer)
        
        // 添加演示项目
        for (index, item) in demoItems.enumerated() {
            let cardView = createDemoCard(for: item, at: index)
            stackView.addArrangedSubview(cardView)
        }
    }
    
    private func createDemoCard(for item: CollectionDemoItem, at index: Int) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = item.icon
        iconLabel.font = .systemFont(ofSize: 32)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = item.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("演示", for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 8
        actionButton.tag = index
        actionButton.addTarget(self, action: #selector(demoButtonTapped(_:)), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(iconLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            iconLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            iconLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            iconLabel.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),
            
            actionButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            actionButton.widthAnchor.constraint(equalToConstant: 60),
            actionButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return cardView
    }
    
    // MARK: - Actions
    @objc private func demoButtonTapped(_ sender: UIButton) {
        let item = demoItems[sender.tag]
        performDemoAction(item.action)
    }
    
    @objc private func showSettings() {
        let settingsVC = CollectionViewSettingsController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    private func performDemoAction(_ action: CollectionDemoAction) {
        switch action {
        case .autoSizingFlowLayout:
            showAutoSizingFlowLayoutDemo()
        case .compositionalLayout:
            showCompositionalLayoutDemo()
        case .gridLayout:
            showGridLayoutDemo()
        case .waterfallLayout:
            showWaterfallLayoutDemo()
        case .horizontalLayout:
            showHorizontalLayoutDemo()
        case .cardLayout:
            showCardLayoutDemo()
        case .highPerformanceLayout:
            showHighPerformanceLayoutDemo()
        case .customCell:
            showCustomCellDemo()
        case .batchUpdates:
            showBatchUpdatesDemo()
        case .prefetching:
            showPrefetchingDemo()
        case .dragDrop:
            showDragDropDemo()
        case .focusSupport:
            showFocusSupportDemo()
        case .accessibility:
            showAccessibilityDemo()
        case .performance:
            showPerformanceDemo()
        }
    }
    
    // MARK: - Demo Methods (第一部分)
    private func showAutoSizingFlowLayoutDemo() {
        let demoVC = AutoSizingFlowLayoutDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showCompositionalLayoutDemo() {
        let demoVC = CompositionalLayoutDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showGridLayoutDemo() {
        let demoVC = GridLayoutDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showWaterfallLayoutDemo() {
        let demoVC = WaterfallLayoutDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showHorizontalLayoutDemo() {
        let demoVC = HorizontalLayoutDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showCardLayoutDemo() {
        let demoVC = CardLayoutDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showHighPerformanceLayoutDemo() {
        let demoVC = HighPerformanceLayoutDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showCustomCellDemo() {
        let demoVC = CustomCellDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showBatchUpdatesDemo() {
        let demoVC = BatchUpdatesDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showPrefetchingDemo() {
        let demoVC = PrefetchingDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showDragDropDemo() {
        let demoVC = DragDropDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showFocusSupportDemo() {
        let demoVC = FocusSupportDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showAccessibilityDemo() {
        let demoVC = AccessibilityDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
    
    private func showPerformanceDemo() {
        let demoVC = PerformanceDemoController()
        navigationController?.pushViewController(demoVC, animated: true)
    }
}

// MARK: - 设置控制器
class CollectionViewSettingsController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "设置"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "完成",
            style: .done,
            target: self,
            action: #selector(dismissController)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissController() {
        dismiss(animated: true)
    }
}

extension CollectionViewSettingsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "启用动画"
            cell.detailTextLabel?.text = "布局切换时使用动画"
            cell.accessoryType = .checkmark
        case 1:
            cell.textLabel?.text = "预取数据"
            cell.detailTextLabel?.text = "启用数据预取功能"
            cell.accessoryType = .checkmark
        case 2:
            cell.textLabel?.text = "拖拽排序"
            cell.detailTextLabel?.text = "允许拖拽重新排序"
            cell.accessoryType = .checkmark
        case 3:
            cell.textLabel?.text = "性能监控"
            cell.detailTextLabel?.text = "显示性能指标"
            cell.accessoryType = .none
        case 4:
            cell.textLabel?.text = "调试模式"
            cell.detailTextLabel?.text = "显示调试信息"
            cell.accessoryType = .none
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = cell?.accessoryType == .checkmark ? .none : .checkmark
    }
} 
