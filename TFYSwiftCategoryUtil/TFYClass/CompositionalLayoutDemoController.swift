//
//  CompositionalLayoutDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFYSwift on 2025/1/24.
//  CompositionalLayout演示
//

import UIKit

// MARK: - 数据模型
struct CompositionalItem {
    let title: String
    let subtitle: String
    let icon: String
    let color: UIColor
    let height: CGFloat
}

// MARK: - CompositionalLayout Cell
class CompositionalLayoutCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        iconLabel.font = .systemFont(ofSize: 32)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconLabel)
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 60),
            iconLabel.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with item: CompositionalItem) {
        iconLabel.text = item.icon
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        containerView.backgroundColor = item.color.withAlphaComponent(0.1)
        iconLabel.textColor = item.color
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(
            layoutAttributes.size,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        var newFrame = layoutAttributes.frame
        // 确保frame有效，避免CGRectNull或无效值
        if size.width > 0 && size.height > 0 {
            newFrame.size = size
            layoutAttributes.frame = newFrame
        }
        
        return layoutAttributes
    }
}

// MARK: - 主控制器
class CompositionalLayoutDemoController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    
    private var items: [CompositionalItem] = [
        CompositionalItem(
            title: "高性能布局",
            subtitle: "iOS 13+ 组合布局提供优秀的性能表现",
            icon: "⚡",
            color: .systemBlue,
            height: 120
        ),
        CompositionalItem(
            title: "灵活配置",
            subtitle: "支持复杂的布局配置和自定义",
            icon: "🎨",
            color: .systemPurple,
            height: 120
        ),
        CompositionalItem(
            title: "自适应尺寸",
            subtitle: "自动计算和调整Cell尺寸",
            icon: "📏",
            color: .systemGreen,
            height: 120
        ),
        CompositionalItem(
            title: "动画支持",
            subtitle: "流畅的布局切换动画",
            icon: "🎬",
            color: .systemOrange,
            height: 120
        ),
        CompositionalItem(
            title: "分组布局",
            subtitle: "支持复杂的嵌套分组结构",
            icon: "📦",
            color: .systemRed,
            height: 120
        ),
        CompositionalItem(
            title: "装饰视图",
            subtitle: "支持背景装饰和分割线",
            icon: "🎭",
            color: .systemTeal,
            height: 120
        ),
        CompositionalItem(
            title: "可见性回调",
            subtitle: "监控Cell的可见性变化",
            icon: "👁️",
            color: .systemIndigo,
            height: 120
        ),
        CompositionalItem(
            title: "正交滚动",
            subtitle: "支持水平和垂直滚动组合",
            icon: "🔄",
            color: .systemPink,
            height: 120
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupNavigationBar()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "CompositionalLayout"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "切换布局",
                style: .plain,
                target: self,
                action: #selector(toggleLayout)
            ),
            UIBarButtonItem(
                title: "添加项目",
                style: .plain,
                target: self,
                action: #selector(addItem)
            )
        ]
    }
    
    private func setupCollectionView() {
        // 创建CompositionalLayout
        let layout = createCompositionalLayout()
        
        // 创建CollectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // 注册Cell
        collectionView.register(CompositionalLayoutCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        // 创建Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 创建Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        
        // 创建Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 16
        
        // 创建Layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func createGridCompositionalLayout() -> UICollectionViewCompositionalLayout {
        // 创建Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 创建Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        
        // 创建Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 16
        
        // 创建Layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    // MARK: - Actions
    @objc private func toggleLayout() {
        let currentLayout = collectionView.collectionViewLayout
        
        let newLayout: UICollectionViewCompositionalLayout
        if currentLayout is UICollectionViewCompositionalLayout {
            // 切换到网格布局
            newLayout = createGridCompositionalLayout()
        } else {
            // 切换到列表布局
            newLayout = createCompositionalLayout()
        }
        
        collectionView.setCollectionViewLayout(newLayout, animated: true)
    }
    
    @objc private func addItem() {
        let colors: [UIColor] = [.systemBlue, .systemPurple, .systemGreen, .systemOrange, .systemRed, .systemTeal, .systemIndigo, .systemPink]
        let icons = ["🚀", "💡", "🔧", "📱", "🎯", "🌟", "💎", "🔥"]
        
        let randomColor = colors.randomElement() ?? .systemBlue
        let randomIcon = icons.randomElement() ?? "📦"
        
        let newItem = CompositionalItem(
            title: "新项目 \(items.count + 1)",
            subtitle: "动态添加的CompositionalLayout项目",
            icon: randomIcon,
            color: randomColor,
            height: 120
        )
        
        items.append(newItem)
        
        let indexPath = IndexPath(item: items.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        
        // 滚动到新项目
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension CompositionalLayoutDemoController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CompositionalLayoutCell
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CompositionalLayoutDemoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        let alert = UIAlertController(
            title: item.title,
            message: item.subtitle,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
} 