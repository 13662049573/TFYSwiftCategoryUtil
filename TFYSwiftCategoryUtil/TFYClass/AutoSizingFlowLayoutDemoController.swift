//
//  AutoSizingFlowLayoutDemoController.swift
//  TFYSwiftCategoryUtil
//
//  TFYSwiftRTLAlignedFlowLayout 全能力演示
//

import UIKit

private struct RTLItem {
    let title: String
    let detail: String
    let color: UIColor
}

private struct RTLSection {
    let title: String
    let desc: String
    var items: [RTLItem]
}

private final class RTLDemoCell: UICollectionViewCell {
    static let reuseID = "RTLDemoCell"
    private let card = UIView()
    private let dot = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 10.adap
        card.layer.borderWidth = 0.5
        card.layer.borderColor = UIColor.separator.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        
        dot.layer.cornerRadius = 5.adap
        dot.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dot)
        
        titleLabel.font = .boldSystemFont(ofSize: 14.adap)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        detailLabel.font = .systemFont(ofSize: 12.adap)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dot.topAnchor.constraint(equalTo: card.topAnchor, constant: 10.adap),
            dot.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10.adap),
            dot.widthAnchor.constraint(equalToConstant: 10.adap),
            dot.heightAnchor.constraint(equalToConstant: 10.adap),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 8.adap),
            titleLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 8.adap),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10.adap),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6.adap),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10.adap)
        ])
    }
    
    func fill(_ item: RTLItem) {
        titleLabel.text = item.title
        detailLabel.text = item.detail
        dot.backgroundColor = item.color
    }
}

private final class RTLHeaderFooterView: UICollectionReusableView {
    static let headerID = "RTLHeader"
    static let footerID = "RTLFooter"
    
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .boldSystemFont(ofSize: 15.adap)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        descLabel.font = .systemFont(ofSize: 12.adap)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2.adap),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2.adap),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.adap),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func fill(title: String, desc: String) {
        titleLabel.text = title
        descLabel.text = desc
    }
}

final class AutoSizingFlowLayoutDemoController: UIViewController {
    private enum SectionKind: Int, CaseIterable { case flowLeading, flowCenter, waterfall, groupedItemsOnly, groupedFull }
    
    private var alignment: TFYSwiftRTLAlignedFlowLayout.HorizontalAlignment = .leading
    private var forceRTL = false
    private var sections: [RTLSection] = []
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: buildLayout())
        view.backgroundColor = .systemGroupedBackground
        view.delegate = self
        view.dataSource = self
        view.alwaysBounceVertical = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(RTLDemoCell.self, forCellWithReuseIdentifier: RTLDemoCell.reuseID)
        view.register(RTLHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RTLHeaderFooterView.headerID)
        view.register(RTLHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RTLHeaderFooterView.footerID)
        return view
    }()
    
    private lazy var globalHeader: UIView = makeBanner("TFYSwiftRTLAlignedFlowLayout", "全局 Header（tableHeaderView 风格）+ 分区流式/瀑布流 + insetGrouped 渐变边框。")
    private lazy var globalFooter: UIView = makeBanner("Global Footer", "全局 Footer（tableFooterView 风格），用于展示布局收尾区域。")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RTLAligned 全面演示"
        view.backgroundColor = .systemBackground
        buildData()
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "对齐", style: .plain, target: self, action: #selector(toggleAlign)),
            UIBarButtonItem(title: "RTL", style: .plain, target: self, action: #selector(toggleRTL)),
            UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(reloadDemo))
        ]
    }
    
    private func buildLayout() -> TFYSwiftRTLAlignedFlowLayout {
        let layout = TFYSwiftRTLAlignedFlowLayout(horizontalAlignment: alignment, layoutMode: .flow, columnCount: 2)
        layout.sectionDelegate = self
        layout.minimumInteritemSpacing = 8.adap
        layout.minimumLineSpacing = 10.adap
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12.adap, bottom: 12.adap, right: 12.adap)
        layout.sectionGroupedBackgroundColor = .secondarySystemGroupedBackground
        layout.sectionGroupedBorderWidth = 1
        layout.sectionGroupedBorderColor = .separator
        layout.spacingBetweenGroupedSections = 12.adap
        layout.defaultGradientDirection = .vertical
        layout.defaultInsetGroupedContentMode = .full
        layout.shouldLimitHeaderFooterWidthByInset = true
        layout.enableCacheHeightValidation = true
        layout.enableWaterfallForSection(SectionKind.waterfall.rawValue)
        return layout
    }
    
    private func makeBanner(_ title: String, _ text: String) -> UIView {
        let container = UIView()
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 14.adap
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)
        
        let t = UILabel()
        t.text = title
        t.font = .boldSystemFont(ofSize: 20.adap)
        t.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(t)
        
        let d = UILabel()
        d.text = text
        d.numberOfLines = 0
        d.font = .systemFont(ofSize: 13.adap)
        d.textColor = .secondaryLabel
        d.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(d)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.adap),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.adap),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.adap),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8.adap),
            t.topAnchor.constraint(equalTo: card.topAnchor, constant: 12.adap),
            t.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12.adap),
            t.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12.adap),
            d.topAnchor.constraint(equalTo: t.bottomAnchor, constant: 8.adap),
            d.leadingAnchor.constraint(equalTo: t.leadingAnchor),
            d.trailingAnchor.constraint(equalTo: t.trailingAnchor),
            d.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12.adap)
        ])
        return container
    }
    
    private func applyLayout() {
        let layout = buildLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
    }
    
    @objc private func toggleAlign() {
        switch alignment { case .leading: alignment = .center; case .center: alignment = .trailing; case .trailing: alignment = .leading }
        applyLayout()
    }
    
    @objc private func toggleRTL() {
        forceRTL.toggle()
        collectionView.semanticContentAttribute = forceRTL ? .forceRightToLeft : .forceLeftToRight
        applyLayout()
    }
    
    @objc private func reloadDemo() {
        sections[SectionKind.waterfall.rawValue].items.shuffle()
        collectionView.reloadData()
    }
    
    private func buildData() {
        sections = [
            RTLSection(title: "Flow - Leading", desc: "默认流式 + leading/trailing/center 可切换，展示行对齐。", items: makeItems(prefix: "FlowA", count: 12)),
            RTLSection(title: "Flow - Center", desc: "同样是流式，但 item 宽度更离散，便于观察行内居中。", items: makeItems(prefix: "FlowB", count: 10)),
            RTLSection(title: "Waterfall", desc: "按 section 独立启用瀑布流，列数与高度由 delegate 提供。", items: makeItems(prefix: "Water", count: 20)),
            RTLSection(title: "InsetGrouped ItemsOnly", desc: "圆角背景仅包裹内容区，不含组头/组尾。", items: makeItems(prefix: "GroupI", count: 8)),
            RTLSection(title: "InsetGrouped Full + Gradient", desc: "全包裹 + 渐变背景 + 渐变边框 + 组间距。", items: makeItems(prefix: "GroupF", count: 9))
        ]
    }
    
    private func makeItems(prefix: String, count: Int) -> [RTLItem] {
        (0..<count).map { idx in
            let words = String(repeating: "文", count: (idx % 4 + 1) * 3)
            return RTLItem(title: "\(prefix) #\(idx + 1)", detail: "内容 \(words) / \(idx % 2 == 0 ? "短文案" : "这是一段用于测试自动高度和换行的描述文本。")", color: UIColor(hue: CGFloat(idx) / CGFloat(max(count, 1)), saturation: 0.55, brightness: 0.9, alpha: 1))
        }
    }
}

extension AutoSizingFlowLayoutDemoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { sections.count }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { sections[section].items.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RTLDemoCell.reuseID, for: indexPath) as! RTLDemoCell
        cell.fill(sections[indexPath.section].items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let id = kind == UICollectionView.elementKindSectionHeader ? RTLHeaderFooterView.headerID : RTLHeaderFooterView.footerID
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! RTLHeaderFooterView
        if kind == UICollectionView.elementKindSectionHeader {
            view.fill(title: sections[indexPath.section].title, desc: sections[indexPath.section].desc)
        } else {
            view.fill(title: "Section Footer", desc: "section \(indexPath.section + 1) footer")
        }
        return view
    }
}

extension AutoSizingFlowLayoutDemoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? TFYSwiftRTLAlignedFlowLayout else { return CGSize(width: 80, height: 80) }
        let inset = layout.effectiveSectionInset(for: indexPath.section)
        let section = SectionKind(rawValue: indexPath.section) ?? .flowLeading
        let spacing = self.layout(layout, interitemSpacingFor: indexPath.section) ?? 8.adap
        let available = max(120.adap, collectionView.bounds.width - inset.left - inset.right)
        let item = sections[indexPath.section].items[indexPath.item]
        
        switch section {
        case .flowLeading, .flowCenter:
            let textW = (item.title as NSString).size(withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14.adap)]).width
            let width = min(max(90.adap, textW + 40.adap), available * 0.7)
            let height = section == .flowLeading ? 86.adap : 98.adap
            return CGSize(width: width, height: height)
        case .waterfall:
            let cols: CGFloat = 2
            let width = floor((available - (cols - 1) * spacing) / cols)
            let base = 90.adap + CGFloat(indexPath.item % 5) * 22.adap
            return CGSize(width: width, height: base)
        case .groupedItemsOnly, .groupedFull:
            let cols: CGFloat = 2
            let width = floor((available - (cols - 1) * spacing) / cols)
            return CGSize(width: width, height: 106.adap)
        }
    }
}

extension AutoSizingFlowLayoutDemoController: TFYSwiftRTLAlignedFlowLayoutDelegate {
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, collectionHeaderViewIn collectionView: UICollectionView) -> UIView? { globalHeader }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, collectionHeaderHeightIn collectionView: UICollectionView) -> CGFloat? { 132.adap }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, collectionFooterViewIn collectionView: UICollectionView) -> UIView? { globalFooter }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, collectionFooterHeightIn collectionView: UICollectionView) -> CGFloat? { 72.adap }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, isWaterfallFor section: Int) -> Bool? {
        section == SectionKind.waterfall.rawValue
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, columnsFor section: Int, availableWidth: CGFloat) -> Int? {
        section == SectionKind.waterfall.rawValue ? 2 : nil
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, interitemSpacingFor section: Int) -> CGFloat? { 8.adap }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, lineSpacingFor section: Int) -> CGFloat? { 10.adap }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, sectionInsetFor section: Int) -> UIEdgeInsets? {
        UIEdgeInsets(top: 6.adap, left: 12.adap, bottom: 12.adap, right: 12.adap)
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, headerHeightFor section: Int, width: CGFloat) -> CGFloat? { 48.adap }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, footerHeightFor section: Int, width: CGFloat) -> CGFloat? { 24.adap }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedFor section: Int) -> Bool? {
        section == SectionKind.groupedItemsOnly.rawValue || section == SectionKind.groupedFull.rawValue
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedContentModeFor section: Int) -> TFYSwiftRTLAlignedFlowLayout.InsetGroupedContentMode? {
        section == SectionKind.groupedItemsOnly.rawValue ? .itemsOnly : .full
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedGroupInsetsFor section: Int) -> UIEdgeInsets? {
        UIEdgeInsets(top: 10.adap, left: 14.adap, bottom: 10.adap, right: 14.adap)
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedCornerRadiusFor section: Int) -> CGFloat? { 14.adap }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedGradientColorsFor section: Int) -> [UIColor]? {
        section == SectionKind.groupedFull.rawValue ? [.systemIndigo.withAlphaComponent(0.16), .systemTeal.withAlphaComponent(0.16)] : nil
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedBorderWidthFor section: Int) -> CGFloat? {
        section == SectionKind.groupedFull.rawValue ? 1.2 : 0.8
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedBorderGradientColorsFor section: Int) -> [UIColor]? {
        section == SectionKind.groupedFull.rawValue ? [.systemPurple, .systemBlue] : nil
    }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, insetGroupedBorderGradientDirectionFor section: Int) -> TFYSwiftRTLAlignedFlowLayout.GradientDirection? {
        section == SectionKind.groupedFull.rawValue ? .horizontal : .vertical
    }
}

