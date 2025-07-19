//
//  GridLayoutDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFYSwift on 2025/1/24.
//  网格布局演示
//

import UIKit

// MARK: - 数据模型
struct GridItem {
    let title: String
    let imageName: String
    let color: UIColor
}

// MARK: - 网格Cell
class GridLayoutCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
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
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: GridItem) {
        titleLabel.text = item.title
        
        // 使用系统图标作为占位符
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        imageView.image = UIImage(systemName: item.imageName, withConfiguration: config)
        imageView.tintColor = item.color
        imageView.backgroundColor = item.color.withAlphaComponent(0.1)
    }
}

// MARK: - 主控制器
class GridLayoutDemoController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var currentColumns: Int = 2
    
    private var items: [GridItem] = [
        GridItem(title: "照片", imageName: "photo", color: .systemBlue),
        GridItem(title: "视频", imageName: "video", color: .systemGreen),
        GridItem(title: "音乐", imageName: "music.note", color: .systemPurple),
        GridItem(title: "文档", imageName: "doc.text", color: .systemOrange),
        GridItem(title: "设置", imageName: "gear", color: .systemGray),
        GridItem(title: "搜索", imageName: "magnifyingglass", color: .systemTeal),
        GridItem(title: "收藏", imageName: "heart", color: .systemRed),
        GridItem(title: "分享", imageName: "square.and.arrow.up", color: .systemIndigo),
        GridItem(title: "下载", imageName: "arrow.down.circle", color: .systemPink),
        GridItem(title: "上传", imageName: "arrow.up.circle", color: .systemYellow),
        GridItem(title: "编辑", imageName: "pencil", color: .systemBrown),
        GridItem(title: "删除", imageName: "trash", color: .systemRed)
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
        title = "网格布局"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "列数",
                style: .plain,
                target: self,
                action: #selector(changeColumns)
            ),
            UIBarButtonItem(
                title: "添加",
                style: .plain,
                target: self,
                action: #selector(addItem)
            )
        ]
    }
    
    private func setupCollectionView() {
        // 创建FlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // 创建CollectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // 注册Cell
        collectionView.register(GridLayoutCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func changeColumns() {
        let alert = UIAlertController(title: "选择列数", message: nil, preferredStyle: .actionSheet)
        
        for columns in 1...4 {
            alert.addAction(UIAlertAction(title: "\(columns)列", style: .default) { _ in
                self.currentColumns = columns
                self.collectionView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func addItem() {
        let icons = ["star", "bookmark", "flag", "tag", "folder", "link", "person", "house"]
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemPurple, .systemOrange, .systemRed, .systemTeal, .systemIndigo, .systemPink]
        
        let randomIcon = icons.randomElement() ?? "star"
        let randomColor = colors.randomElement() ?? .systemBlue
        
        let newItem = GridItem(
            title: "新项目 \(items.count + 1)",
            imageName: randomIcon,
            color: randomColor
        )
        
        items.append(newItem)
        
        let indexPath = IndexPath(item: items.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        
        // 滚动到新项目
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension GridLayoutDemoController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GridLayoutCell
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GridLayoutDemoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        
        let alert = UIAlertController(
            title: item.title,
            message: "这是一个网格布局项目",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GridLayoutDemoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let spacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - padding * 2 - spacing * CGFloat(currentColumns - 1)
        let itemWidth = availableWidth / CGFloat(currentColumns)
        
        return CGSize(width: itemWidth, height: itemWidth + 60) // 额外高度用于标题
    }
} 