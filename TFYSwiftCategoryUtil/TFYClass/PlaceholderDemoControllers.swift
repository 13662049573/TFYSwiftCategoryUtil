//
//  PlaceholderDemoControllers.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFYSwift on 2025/1/24.
//  占位符演示控制器
//

import UIKit

// MARK: - 瀑布流布局演示
class WaterfallLayoutDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "瀑布流布局"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...20).map { "瀑布流项目 \($0)" }
        collectionView.reloadData()
    }
}

extension WaterfallLayoutDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat.random(in: 100...200)
        return CGSize(width: (collectionView.bounds.width - 60) / 2, height: height)
    }
}

// MARK: - 水平滚动布局演示
class HorizontalLayoutDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "水平滚动布局"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func generateItems() {
        items = (1...10).map { "水平项目 \($0)" }
        collectionView.reloadData()
    }
}

extension HorizontalLayoutDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 12
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}

// MARK: - 卡片布局演示
class CardLayoutDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "卡片布局"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...8).map { "卡片项目 \($0)" }
        collectionView.reloadData()
    }
}

extension CardLayoutDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 16
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.layer.shadowRadius = 8
        cell.layer.shadowOpacity = 0.1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 40, height: 200)
    }
}

// MARK: - 高性能布局演示
class HighPerformanceLayoutDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "高性能布局"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...50).map { "高性能项目 \($0)" }
        collectionView.reloadData()
    }
}

extension HighPerformanceLayoutDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 60) / 3, height: 80)
    }
}

// MARK: - 自定义Cell演示
class CustomCellDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "自定义Cell"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...12).map { "自定义Cell \($0)" }
        collectionView.reloadData()
    }
}

extension CustomCellDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 12
        
        // 添加标签
        let label = UILabel()
        label.text = items[indexPath.item]
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 60) / 2, height: 100)
    }
}

// MARK: - 预取功能演示
class PrefetchingDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "预取功能"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...100).map { "预取项目 \($0)" }
        collectionView.reloadData()
    }
}

extension PrefetchingDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 60) / 3, height: 80)
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("预取项目: \(indexPaths.map { $0.item })")
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("取消预取项目: \(indexPaths.map { $0.item })")
    }
}

// MARK: - 拖拽排序演示
class DragDropDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "拖拽排序"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...20).map { "拖拽项目 \($0)" }
        collectionView.reloadData()
    }
}

extension DragDropDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemPink.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 8
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 60) / 3, height: 80)
    }
    
    // MARK: - UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = items[indexPath.item]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    // MARK: - UICollectionViewDropDelegate
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath else { return }
        
        let movedItem = items.remove(at: sourceIndexPath.item)
        items.insert(movedItem, at: destinationIndexPath.item)
        
        collectionView.performBatchUpdates({
            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        })
    }
}

// MARK: - 焦点支持演示
class FocusSupportDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "焦点支持"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...15).map { "焦点项目 \($0)" }
        collectionView.reloadData()
    }
}

extension FocusSupportDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 12
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 60) / 2, height: 100)
    }
}

// MARK: - 无障碍支持演示
class AccessibilityDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        generateItems()
    }
    
    private func setupUI() {
        title = "无障碍支持"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func generateItems() {
        items = (1...10).map { "无障碍项目 \($0)" }
        collectionView.reloadData()
    }
}

extension AccessibilityDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemBrown.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 12
        
        // 设置无障碍属性
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = items[indexPath.item]
        cell.accessibilityHint = "双击查看详情"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 60) / 2, height: 100)
    }
}

// MARK: - 性能监控演示
class PerformanceDemoController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var items: [String] = []
    private var performanceLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupPerformanceLabel()
        generateItems()
        startPerformanceMonitoring()
    }
    
    private func setupUI() {
        title = "性能监控"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPerformanceLabel() {
        performanceLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        performanceLabel.textColor = .white
        performanceLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        performanceLabel.textAlignment = .center
        performanceLabel.layer.cornerRadius = 8
        performanceLabel.clipsToBounds = true
        performanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(performanceLabel)
        
        NSLayoutConstraint.activate([
            performanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            performanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            performanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            performanceLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func generateItems() {
        items = (1...100).map { "性能项目 \($0)" }
        collectionView.reloadData()
    }
    
    private func startPerformanceMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updatePerformanceInfo()
        }
    }
    
    private func updatePerformanceInfo() {
        let visibleCellsCount = collectionView.visibleCells.count
        let isScrolling = collectionView.isScrolling
        let contentOffset = collectionView.contentOffset
        
        let info = """
        可见Cell: \(visibleCellsCount) | 滚动中: \(isScrolling ? "是" : "否") | 偏移: (\(Int(contentOffset.x)), \(Int(contentOffset.y)))
        """
        
        performanceLabel.text = info
    }
}

extension PerformanceDemoController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        cell.layer.cornerRadius = 6
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 60) / 4, height: 60)
    }
} 