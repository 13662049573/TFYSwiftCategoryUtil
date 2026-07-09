//
//  BatchUpdatesDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFYSwift on 2025/1/24.
//  批量更新演示
//

import UIKit

// MARK: - 数据模型
struct BatchUpdateItem {
    let id: Int
    let title: String
    let color: UIColor
    var isSelected: Bool = false
}

// MARK: - 批量更新Cell
class BatchUpdateCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    private let containerView = UIView()
    
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
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with item: BatchUpdateItem) {
        titleLabel.text = item.title
        containerView.backgroundColor = item.color.withAlphaComponent(0.1)
        titleLabel.textColor = item.color
        
        if item.isSelected {
            containerView.layer.borderColor = item.color.cgColor
            containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } else {
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.transform = .identity
        }
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
        newFrame.size = size
        layoutAttributes.frame = newFrame
        
        return layoutAttributes
    }
}

// MARK: - 主控制器
class BatchUpdatesDemoController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    
    private var items: [BatchUpdateItem] = []
    private var nextId = 1
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupNavigationBar()
        generateInitialItems()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "批量更新演示"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "批量添加",
                style: .plain,
                target: self,
                action: #selector(batchAdd)
            ),
            UIBarButtonItem(
                title: "批量删除",
                style: .plain,
                target: self,
                action: #selector(batchDelete)
            ),
            UIBarButtonItem(
                title: "批量移动",
                style: .plain,
                target: self,
                action: #selector(batchMove)
            )
        ]
    }
    
    private func setupCollectionView() {
        // 创建FlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        // 创建CollectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // 注册Cell
        collectionView.register(BatchUpdateCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateInitialItems() {
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemPurple, .systemOrange, .systemRed, .systemTeal]
        let titles = ["项目A", "项目B", "项目C", "项目D", "项目E", "项目F"]
        
        for (index, title) in titles.enumerated() {
            let item = BatchUpdateItem(
                id: nextId,
                title: title,
                color: colors[index % colors.count]
            )
            items.append(item)
            nextId += 1
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func batchAdd() {
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemPurple, .systemOrange, .systemRed, .systemTeal]
        let newItems: [BatchUpdateItem] = (0..<3).map { _ in
            let item = BatchUpdateItem(
                id: nextId,
                title: "新项目 \(nextId)",
                color: colors.randomElement() ?? .systemBlue
            )
            nextId += 1
            return item
        }
        
        let startIndex = items.count
        items.append(contentsOf: newItems)
        
        let indexPaths = (startIndex..<items.count).map { IndexPath(item: $0, section: 0) }
        
        // 使用批量更新
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }) { _ in
            // 滚动到新添加的项目
            if let lastIndexPath = indexPaths.last {
                self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @objc private func batchDelete() {
        guard items.count >= 3 else {
            showAlert(title: "提示", message: "项目数量不足，无法删除")
            return
        }
        
        let deleteCount = min(3, items.count)
        let startIndex = items.count - deleteCount
        let endIndex = items.count - 1
        
        let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
        
        // 使用批量更新
        collectionView.performBatchUpdates({
            // 删除数据
            items.removeSubrange(startIndex...endIndex)
            // 删除UI
            collectionView.deleteItems(at: indexPaths)
        }) { _ in
            self.showAlert(title: "删除完成", message: "成功删除了 \(deleteCount) 个项目")
        }
    }
    
    @objc private func batchMove() {
        guard items.count >= 4 else {
            showAlert(title: "提示", message: "项目数量不足，无法移动")
            return
        }
        
        // 移动前3个项目到末尾
        let moveCount = min(3, items.count - 1)
        let fromIndexPaths = (0..<moveCount).map { IndexPath(item: $0, section: 0) }
        let toIndexPaths = (items.count - moveCount..<items.count).map { IndexPath(item: $0, section: 0) }
        
        // 使用批量更新
        collectionView.performBatchUpdates({
            // 移动数据
            let movedItems = Array(items.prefix(moveCount))
            items.removeFirst(moveCount)
            items.append(contentsOf: movedItems)
            
            // 移动UI
            for (fromIndex, toIndex) in zip(fromIndexPaths, toIndexPaths) {
                collectionView.moveItem(at: fromIndex, to: toIndex)
            }
        }) { _ in
            self.showAlert(title: "移动完成", message: "成功移动了 \(moveCount) 个项目")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension BatchUpdatesDemoController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BatchUpdateCell
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension BatchUpdatesDemoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 切换选中状态
        items[indexPath.item].isSelected.toggle()
        
        // 使用动画更新Cell
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) as? BatchUpdateCell {
                cell.configure(with: self.items[indexPath.item])
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BatchUpdatesDemoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let spacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - padding * 2 - spacing * 2 // 3列布局
        let itemWidth = availableWidth / 3
        
        return CGSize(width: itemWidth, height: 80)
    }
} 