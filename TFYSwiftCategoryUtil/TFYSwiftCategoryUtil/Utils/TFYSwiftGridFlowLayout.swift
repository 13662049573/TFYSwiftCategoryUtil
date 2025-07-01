//
//  TFYSwiftGridFlowLayout.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2025/2/14.
//  用途：自定义 UICollectionView 网格流式布局，支持动态列数、间距、补充视图等。
//

import UIKit

protocol TFYSwiftGridFlowLayoutDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        columnsCountForSection section: Int) -> Int
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        insetForSection section: Int) -> UIEdgeInsets
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        lineSpacingForSection section: Int) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        interitemSpacingForSection section: Int) -> CGFloat
}

extension TFYSwiftGridFlowLayoutDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        columnsCountForSection section: Int) -> Int {
        return layout.columnsCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        insetForSection section: Int) -> UIEdgeInsets {
        return layout.edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        lineSpacingForSection section: Int) -> CGFloat {
        return layout.rowSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        interitemSpacingForSection section: Int) -> CGFloat {
        return layout.columnSpacing
    }
}

public class TFYSwiftGridFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - 配置属性
    public var columnsCount: Int = 2 {
        didSet { invalidateLayout() }
    }
    
    public var rowSpacing: CGFloat = 10 {
        didSet { invalidateLayout() }
    }
    
    public var columnSpacing: CGFloat = 10 {
        didSet { invalidateLayout() }
    }
    
    public var edgeInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) {
        didSet { invalidateLayout() }
    }
    
    public var isEqualHeight: Bool = true {
        didSet { invalidateLayout() }
    }
    
    public var maxItemHeight: CGFloat? {
        didSet { invalidateLayout() }
    }
    
    // MARK: - 布局属性
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var sectionColumnsHeights: [[CGFloat]] = []
    private var contentHeight: CGFloat = 0
    private weak var gridDelegate: TFYSwiftGridFlowLayoutDelegateFlowLayout? {
        return collectionView?.delegate as? TFYSwiftGridFlowLayoutDelegateFlowLayout
    }
    
    // MARK: - 布局计算
    public override func prepare() {
        guard let collectionView = collectionView else { return }
        
        resetLayoutState()
        
        let sectionsCount = collectionView.numberOfSections
        for section in 0..<sectionsCount {
            prepareSectionLayout(section: section, collectionView: collectionView)
        }
    }
    
    private func resetLayoutState() {
        cache.removeAll()
        sectionColumnsHeights.removeAll()
        contentHeight = 0
    }
    
    private func prepareSectionLayout(section: Int, collectionView: UICollectionView) {
        // Header处理
        let headerIndexPath = IndexPath(item: 0, section: section)
        if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: headerIndexPath),
           headerAttributes.frame.height > 0 {
            cache.append(headerAttributes)
            contentHeight = headerAttributes.frame.maxY
        }
        
        // Items布局
        let columnsCount = getColumnsCount(for: section)
        let sectionInset = getSectionInset(for: section)
        let lineSpacing = getLineSpacing(for: section)
        let interitemSpacing = getInteritemSpacing(for: section)
        
        let contentWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let itemWidth = (contentWidth - CGFloat(columnsCount - 1) * interitemSpacing) / CGFloat(columnsCount)
        
        if section >= sectionColumnsHeights.count {
            print("TFYSwiftGridFlowLayout: section越界，section=\(section)")
            sectionColumnsHeights.append(Array(repeating: contentHeight + sectionInset.top, count: columnsCount))
        }
        
        let itemsCount = collectionView.numberOfItems(inSection: section)
        for item in 0..<itemsCount {
            let indexPath = IndexPath(item: item, section: section)
            if let attributes = layoutAttributesForItem(at: indexPath,
                                                      itemWidth: itemWidth,
                                                      sectionInset: sectionInset,
                                                      lineSpacing: lineSpacing,
                                                      interitemSpacing: interitemSpacing) {
                cache.append(attributes)
            }
        }
        
        // Footer处理
        let footerIndexPath = IndexPath(item: 0, section: section)
        if let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: footerIndexPath),
           footerAttributes.frame.height > 0 {
            cache.append(footerAttributes)
            contentHeight = footerAttributes.frame.maxY
        } else {
            contentHeight = (sectionColumnsHeights[safe: section]?.max() ?? 0) + sectionInset.bottom
        }
    }
    
    // MARK: - 补充视图布局（关键修复）
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                            at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
                          ?? UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        guard let collectionView = collectionView else { return attributes }
        
        let section = indexPath.section
        let sectionInset = getSectionInset(for: section)
        var yPosition: CGFloat = 0
        var size: CGSize = .zero
        
        // 尺寸优先级：1.布局属性设置 2.代理方法 3.默认值
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            size = self.headerReferenceSize
            if size == .zero {
                size = gridDelegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? .zero
            }
            yPosition = section == 0 ? contentHeight : contentHeight + sectionInset.top
            
        case UICollectionView.elementKindSectionFooter:
            size = self.footerReferenceSize
            if size == .zero {
                size = gridDelegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? .zero
            }
            yPosition = (sectionColumnsHeights[safe: section]?.max() ?? 0) + sectionInset.bottom
            
        default:
            return nil
        }
        
        // 安全尺寸处理
        let safeContentWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let validWidth = max(safeContentWidth, 0)
        let validHeight = max(size.height, 0)
        
        // 仅当有有效尺寸时返回属性
        guard validWidth > 0 && validHeight > 0 else {
            return nil
        }
        
        attributes.frame = CGRect(
            x: sectionInset.left,
            y: yPosition,
            width: validWidth,
            height: validHeight
        )
        
        // 更新全局内容高度（仅对当前section有效）
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            contentHeight = attributes.frame.maxY
        case UICollectionView.elementKindSectionFooter:
            contentHeight = attributes.frame.maxY
        default: break
        }
        
        return attributes
    }
    
    // MARK: - 单元格布局
    private func layoutAttributesForItem(at indexPath: IndexPath,
                                       itemWidth: CGFloat,
                                       sectionInset: UIEdgeInsets,
                                       lineSpacing: CGFloat,
                                       interitemSpacing: CGFloat) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < sectionColumnsHeights.count else { return nil }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var columnHeights = sectionColumnsHeights[indexPath.section]
        
        guard let minHeight = columnHeights.min(),
              let minColumn = columnHeights.firstIndex(of: minHeight) else {
            return nil
        }
        
        let x = sectionInset.left + CGFloat(minColumn) * (itemWidth + interitemSpacing)
        let y = minHeight
        
        var itemHeight = calculateItemHeight(at: indexPath, itemWidth: itemWidth)
        
        if let maxHeight = maxItemHeight {
            itemHeight = min(itemHeight, maxHeight)
        }
        
        if let collectionView = collectionView {
            let availableHeight = collectionView.bounds.height - y - sectionInset.bottom
            itemHeight = min(itemHeight, availableHeight)
        }
        
        attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
        columnHeights[minColumn] = y + itemHeight + lineSpacing
        sectionColumnsHeights[indexPath.section] = columnHeights
        
        return attributes
    }
    
    private func calculateItemHeight(at indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        guard itemWidth > 0 else {
            fatalError("Item宽度必须大于0，当前值：\(itemWidth)，请检查列数和边距设置")
        }
        
        if isEqualHeight {
            return itemWidth
        }
        return gridDelegate?.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath).height ?? itemWidth
    }
    
    // MARK: - 代理方法封装
    private func getColumnsCount(for section: Int) -> Int {
        return gridDelegate?.collectionView(collectionView!, layout: self, columnsCountForSection: section) ?? columnsCount
    }
    
    private func getSectionInset(for section: Int) -> UIEdgeInsets {
        return gridDelegate?.collectionView(collectionView!, layout: self, insetForSection: section) ?? edgeInsets
    }
    
    private func getLineSpacing(for section: Int) -> CGFloat {
        return gridDelegate?.collectionView(collectionView!, layout: self, lineSpacingForSection: section) ?? rowSpacing
    }
    
    private func getInteritemSpacing(for section: Int) -> CGFloat {
        return gridDelegate?.collectionView(collectionView!, layout: self, interitemSpacingForSection: section) ?? columnSpacing
    }
    
    // MARK: - 布局系统重写
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: contentHeight)
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { rect.intersects($0.frame) }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return newBounds.width != collectionView.bounds.width
    }
    
    // MARK: - 调试支持
    @objc public func debugQuickLookObject() -> AnyObject? {
        var debugInfo = """
        === GridCollectionViewFlowLayout 调试信息 ===
        列数: \(columnsCount)
        行间距: \(rowSpacing)
        列间距: \(columnSpacing)
        边距: \(edgeInsets)
        等高模式: \(isEqualHeight)
        最大高度限制: \(maxItemHeight?.description ?? "无")
        缓存元素数量: \(cache.count)
        内容高度: \(contentHeight)
        """
        
        if let collectionView = collectionView {
            debugInfo += "\n容器尺寸: \(collectionView.bounds.size)"
        }
        
        return debugInfo as NSString
    }
}

// 安全访问扩展
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
