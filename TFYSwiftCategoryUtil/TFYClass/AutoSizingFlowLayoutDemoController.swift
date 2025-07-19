//
//  AutoSizingFlowLayoutDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFYSwift on 2025/1/24.
//  FlowLayout自适应演示
//

import UIKit

// MARK: - 数据模型
struct FlowLayoutItem {
    let title: String
    let description: String
    let imageName: String
    let height: CGFloat
}

// MARK: - 自适应Cell
class AutoSizingFlowLayoutCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
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
        backgroundColor = .systemBackground
        layer.cornerRadius = 12.adap
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.adap)
        layer.shadowRadius = 4.adap
        layer.shadowOpacity = 0.1
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        titleLabel.font = .boldSystemFont(ofSize: 16.adap)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        descriptionLabel.font = .systemFont(ofSize: 14.adap)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.adap),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.adap),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.adap),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.adap),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120.adap),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12.adap),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.adap),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func configure(with item: FlowLayoutItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        
        // 使用系统图标作为占位符
        let config = UIImage.SymbolConfiguration(pointSize: 40.adap, weight: .medium)
        imageView.image = UIImage(systemName: "photo", withConfiguration: config)
        imageView.tintColor = .systemBlue
        imageView.backgroundColor = .systemGray6
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
class AutoSizingFlowLayoutDemoController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    
    private var items: [FlowLayoutItem] = [
        FlowLayoutItem(
            title: "自适应布局",
            description: "这是第一个项目，展示了UICollectionViewFlowLayout的自适应功能。内容会根据文字长度自动调整高度。",
            imageName: "photo",
            height: 120.adap
        ),
        FlowLayoutItem(
            title: "短标题",
            description: "短描述",
            imageName: "photo",
            height: 120.adap
        ),
        FlowLayoutItem(
            title: "这是一个很长的标题，用来测试自适应布局的效果",
            description: "这是一个很长的描述文本，用来测试UICollectionViewFlowLayout的自适应功能。当文字内容很长时，Cell会自动调整高度来适应内容。这样可以确保所有的文字都能正确显示，不会被截断。",
            imageName: "photo",
            height: 120.adap
        ),
        FlowLayoutItem(
            title: "性能优化",
            description: "FlowLayout自适应布局在iOS 10+中得到了很好的性能优化，支持自动计算Cell高度。",
            imageName: "photo",
            height: 120.adap
        ),
        FlowLayoutItem(
            title: "多行文本",
            description: "支持多行文本显示，自动换行，高度自适应。这是FlowLayout的一个重要特性。",
            imageName: "photo",
            height: 120.adap
        ),
        FlowLayoutItem(
            title: "动态内容",
            description: "这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。",
            imageName: "photo",
            height: 120.adap
        ),
        FlowLayoutItem(
            title: "响应式设计",
            description: "支持不同屏幕尺寸，在不同设备上都能正确显示。",
            imageName: "photo",
            height: 120.adap
        ),
        FlowLayoutItem(
            title: "用户体验",
            description: "提供流畅的用户体验，滚动性能优秀。",
            imageName: "photo",
            height: 120.adap
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
        title = "FlowLayout自适应"
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "添加",
                style: .plain,
                target: self,
                action: #selector(addItem)
            ),
            UIBarButtonItem(
                title: "刷新",
                style: .plain,
                target: self,
                action: #selector(refreshLayout)
            )
        ]
    }
    
    private func setupCollectionView() {
        // 创建FlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16.adap
        flowLayout.minimumInteritemSpacing = 16.adap
        flowLayout.sectionInset = UIEdgeInsets(top: 20.adap, left: 20.adap, bottom: 20.adap, right: 20.adap)
        
        // 设置预估尺寸，避免使用automaticSize导致的崩溃
        flowLayout.estimatedItemSize = CGSize(width: 100.adap, height: 200.adap)
        
        // 创建CollectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // 注册Cell
        collectionView.register(AutoSizingFlowLayoutCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func addItem() {
        let newItem = FlowLayoutItem(
            title: "新项目 \(items.count + 1)",
            description: "这是一个新添加的项目，按泛滥了放哪了啦舒服了吧album巴黎发表了啊播放啦吧啦别发了罢了罢了吧啦发不发了啊吧类发布了罢了方便啦吧啦吧用来演示动态添加内容的效果。",
            imageName: "photo",
            height: 120.adap
        )
        
        items.append(newItem)
        
        let indexPath = IndexPath(item: items.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        
        // 滚动到新项目
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc private func refreshLayout() {
        // 重新计算布局
        flowLayout.invalidateLayout()
        
        // 添加一些动画效果
        UIView.animate(withDuration: 0.3) {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AutoSizingFlowLayoutDemoController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AutoSizingFlowLayoutCell
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AutoSizingFlowLayoutDemoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        let alert = UIAlertController(
            title: item.title,
            message: item.description,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AutoSizingFlowLayoutDemoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 计算宽度（两列布局）
        let padding: CGFloat = 20.adap
        let spacing: CGFloat = 16.adap
        let availableWidth = max(collectionView.bounds.width - padding * 2 - spacing, 100.adap) // 确保最小宽度
        let itemWidth = availableWidth / 2
        
        // 使用预估高度而不是automaticSize.height
        return CGSize(width: itemWidth, height: 200.adap) // 设置一个合理的预估高度
    }
} 
