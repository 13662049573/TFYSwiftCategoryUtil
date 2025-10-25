//
//  TFYSwiftRTLAlignedFlowLayout.swift
//  ZSShortPlay
//
//  Created by cchen on 2025/9/29.
//

import Foundation
import UIKit

// MARK: - Delegate
public protocol TFYSwiftRTLAlignedFlowLayoutDelegate: AnyObject {
    // 每组是否为瀑布流（优先级：全局layoutMode/enableWaterfall > delegate）
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, isWaterfallFor section: Int) -> Bool?
    // 每组列数（若返回 nil 且提供了 minimumItemWidth，将按最小宽度自适应列数）
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, columnsFor section: Int, availableWidth: CGFloat) -> Int?
    // 每组最小单元宽度，用于自适应列数
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, minimumItemWidthFor section: Int, availableWidth: CGFloat) -> CGFloat?
    // 每组间距与内边距
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, interitemSpacingFor section: Int) -> CGFloat?
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, lineSpacingFor section: Int) -> CGFloat?
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, sectionInsetFor section: Int) -> UIEdgeInsets?
    // Header/Footer 尺寸（仅高度，宽度为集合视图宽度减去 inset）
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, headerHeightFor section: Int, width: CGFloat) -> CGFloat?
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, footerHeightFor section: Int, width: CGFloat) -> CGFloat?
}

public extension TFYSwiftRTLAlignedFlowLayoutDelegate {
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, isWaterfallFor section: Int) -> Bool? { nil }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, columnsFor section: Int, availableWidth: CGFloat) -> Int? { nil }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, minimumItemWidthFor section: Int, availableWidth: CGFloat) -> CGFloat? { nil }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, interitemSpacingFor section: Int) -> CGFloat? { nil }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, lineSpacingFor section: Int) -> CGFloat? { nil }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, sectionInsetFor section: Int) -> UIEdgeInsets? { nil }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, headerHeightFor section: Int, width: CGFloat) -> CGFloat? { nil }
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, footerHeightFor section: Int, width: CGFloat) -> CGFloat? { nil }
}

public class TFYSwiftRTLAlignedFlowLayout: UICollectionViewFlowLayout {
    public enum HorizontalAlignment { case leading, center, trailing }
    public enum LayoutMode { case flow, waterfall }
    
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    private var lastContentSize = CGSize.zero
    private var lastCollectionViewWidth: CGFloat = 0 // 新增：跟踪宽度变化
    
    // 瀑布流相关属性
    private var columnHeights: [CGFloat] = []
    public private(set) var columnCount: Int = 2 // 默认2列，可通过初始化参数或delegate修改
    private var itemHeights: [IndexPath: (height: CGFloat, width: CGFloat)] = [:] // 缓存高度和对应的宽度
    private var waterfallSections: Set<Int> = [] // 支持瀑布流的section集合
    
    private(set) var horizontalAlignment: HorizontalAlignment
    private(set) var collectionViewWidth: CGFloat
    private(set) var isRTL: Bool = false
    private(set) var layoutMode: LayoutMode = .flow
    
    // 可选 delegate
    public weak var sectionDelegate: TFYSwiftRTLAlignedFlowLayoutDelegate?

    public init(horizontalAlignment: HorizontalAlignment = .leading,
                collectionViewWidth: CGFloat = UIScreen.main.bounds.width,
                layoutMode: LayoutMode = .flow,
                columnCount: Int = 2) { // 默认2列，适合大多数场景
        self.horizontalAlignment = horizontalAlignment
        self.collectionViewWidth = collectionViewWidth
        self.layoutMode = layoutMode
        self.columnCount = max(1, columnCount)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 新增：宽度变化时重新布局（如旋转屏幕）
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldWidth = collectionView?.bounds.width ?? 0
        return newBounds.width != oldWidth || super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 同步当前宽度，避免使用初始化时的固定宽度
        collectionViewWidth = collectionView.bounds.width
        
        isRTL = UIView.userInterfaceLayoutDirection(
            for: collectionView.semanticContentAttribute
        ) == .rightToLeft
        
        // 避免与重写的 collectionViewContentSize 相互依赖，使用父类尺寸进行变化判断
        let baseContentSize = super.collectionViewContentSize
        let currentWidth = collectionView.bounds.width
        let needUpdate = cachedAttributes.isEmpty
            || lastCollectionViewWidth != currentWidth
            || lastContentSize != baseContentSize
        
        if needUpdate {
            // 总是使用混合布局，支持每组独立配置
            prepareMixedLayout()
            lastContentSize = baseContentSize
            lastCollectionViewWidth = currentWidth
        }
    }
    
    private func arrangeAllItems() {
        var currentRow = [UICollectionViewLayoutAttributes]()
        var currentY: CGFloat = -1
        
        for attribute in cachedAttributes where attribute.representedElementCategory == .cell {
            // 优化：用微小差值判断换行（避免浮点数精度问题）
            if abs(attribute.frame.origin.y - currentY) > 0.1 {
                arrangeRow(currentRow)
                currentRow.removeAll()
                currentY = attribute.frame.origin.y
            }
            currentRow.append(attribute)
        }
        if !currentRow.isEmpty {
            arrangeRow(currentRow)
        }
    }
    
    private func arrangeRow(_ attributes: [UICollectionViewLayoutAttributes]) {
        guard !attributes.isEmpty else { return }
        
        let totalWidth = attributes.reduce(0) { $0 + $1.frame.width } +
                        minimumInteritemSpacing * CGFloat(attributes.count - 1)
        
        var xOffset: CGFloat
        switch (horizontalAlignment, isRTL) {
        case (.leading, false):
            // LTR-leading：从左侧内边距开始，不考虑总宽度（确保依次排列）
            xOffset = sectionInset.left
        case (.leading, true):
            // RTL-leading：从右侧内边距开始（右侧 = 总宽度 - 右内边距）
            xOffset = collectionViewWidth - sectionInset.right
        case (.center, _):
            xOffset = (collectionViewWidth - totalWidth) / 2
        case (.trailing, false):
            xOffset = collectionViewWidth - totalWidth - sectionInset.right
        case (.trailing, true):
            xOffset = sectionInset.left
        }
        
        // 关键修复：按数据原始顺序（indexPath.item）排序，避免受系统布局影响
        // RTL时反转顺序（确保第0个item在最右）
        let sortedAttributes = attributes.sorted { $0.indexPath.item < $1.indexPath.item }
        let finalAttributes = sortedAttributes
        
        // 排列单元格：LTR累加x，RTL递减x（确保依次紧凑排列）
        for attribute in finalAttributes {
            let itemWidth = attribute.frame.width
            // RTL时x是右侧边缘，需要减去宽度得到左边缘
            attribute.frame.origin.x = isRTL ? (xOffset - itemWidth) : xOffset
            // 更新偏移：LTR向右，RTL向左
            xOffset += isRTL ? -(itemWidth + minimumInteritemSpacing) : (itemWidth + minimumInteritemSpacing)
        }
    }

    // 基于指定的 section 参数对一行进行水平对齐与 RTL 处理
    private func arrangeRow(_ attributes: [UICollectionViewLayoutAttributes], sectionInset: UIEdgeInsets, interitemSpacing: CGFloat) {
        guard !attributes.isEmpty else { return }
        let totalWidth = attributes.reduce(0) { $0 + $1.frame.width } + interitemSpacing * CGFloat(attributes.count - 1)
        var xOffset: CGFloat
        switch (horizontalAlignment, isRTL) {
        case (.leading, false):
            xOffset = sectionInset.left
        case (.leading, true):
            xOffset = collectionViewWidth - sectionInset.right
        case (.center, _):
            xOffset = (collectionViewWidth - totalWidth) / 2
        case (.trailing, false):
            xOffset = collectionViewWidth - totalWidth - sectionInset.right
        case (.trailing, true):
            xOffset = sectionInset.left
        }
        let sortedAttributes = attributes.sorted { $0.indexPath.item < $1.indexPath.item }
        for attribute in sortedAttributes {
            let itemWidth = attribute.frame.width
            attribute.frame.origin.x = isRTL ? (xOffset - itemWidth) : xOffset
            xOffset += isRTL ? -(itemWidth + interitemSpacing) : (itemWidth + interitemSpacing)
        }
    }
    
    // 补充：返回缓存的布局属性（优化性能）
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { rect.intersects($0.frame) }
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes.first {
            $0.representedElementKind == elementKind && $0.indexPath == indexPath
        }
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes.first { $0.indexPath == indexPath }
    }
    
    // MARK: - 瀑布流布局方法
    
    private func prepareMixedLayout() {
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        
        let totalSections = collectionView.numberOfSections
        var yOffset: CGFloat = 0
        // 仅计算一次系统流式布局的基础属性，避免在每个 section 内重复计算
        let baseAttributesAllSections: [UICollectionViewLayoutAttributes] = (
            super.layoutAttributesForElements(
                in: CGRect(origin: .zero, size: super.collectionViewContentSize)
            )?.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        ) ?? []
        
        for section in 0..<totalSections {
            let availableWidth = collectionView.bounds.width
            let delegate = sectionDelegate
            let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
            
            // 读取每组配置（优先级：系统代理 > 自定义delegate > 默认值）
            let sectionInsetValue: UIEdgeInsets = {
                if let systemInset = systemDelegate?.collectionView?(collectionView, layout: self, insetForSectionAt: section) {
                    return systemInset
                }
                return delegate?.layout(self, sectionInsetFor: section) ?? sectionInset
            }()
            
            let interitem: CGFloat = {
                if let systemSpacing = systemDelegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
                    return systemSpacing
                }
                return delegate?.layout(self, interitemSpacingFor: section) ?? minimumInteritemSpacing
            }()
            
            let linespacing: CGFloat = {
                if let systemSpacing = systemDelegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) {
                    return systemSpacing
                }
                return delegate?.layout(self, lineSpacingFor: section) ?? minimumLineSpacing
            }()
            
            // 优先使用系统代理设置的高度，如果没有则使用自定义delegate
            let headerH: CGFloat = {
                // 首先检查系统代理是否提供了header尺寸
                if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                   let headerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section),
                   headerSize.height > 0 {
                    return headerSize.height
                }
                // 如果系统代理没有设置，则使用自定义delegate
                return delegate?.layout(self, headerHeightFor: section, width: availableWidth) ?? 0
            }()
            
            let footerH: CGFloat = {
                // 首先检查系统代理是否提供了footer尺寸
                if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                   let footerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section),
                   footerSize.height > 0 {
                    return footerSize.height
                }
                // 如果系统代理没有设置，则使用自定义delegate
                return delegate?.layout(self, footerHeightFor: section, width: availableWidth) ?? 0
            }()
            let isWaterfallSection: Bool = {
                if layoutMode == .waterfall || waterfallSections.contains(section) { return true }
                return delegate?.layout(self, isWaterfallFor: section) ?? false
            }()

            // Header（如有）：创建补充视图属性并堆叠
            if headerH > 0 {
                let headerIndex = IndexPath(item: 0, section: section)
                let headerAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndex)
                
                // 优先使用系统代理设置的宽度，否则使用可用宽度减去inset
                let headerWidth: CGFloat = {
                    if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                       let headerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section),
                       headerSize.width > 0 {
                        return min(headerSize.width, availableWidth - sectionInsetValue.left - sectionInsetValue.right)
                    }
                    return availableWidth - sectionInsetValue.left - sectionInsetValue.right
                }()
                
                headerAttr.frame = CGRect(x: sectionInsetValue.left, y: yOffset, width: max(0, headerWidth), height: headerH)
                headerAttr.zIndex = 1000 // 确保 header 在 cell 之上
                cachedAttributes.append(headerAttr)
                yOffset = headerAttr.frame.maxY
            }

            if isWaterfallSection {
                // 瀑布流：从当前 yOffset 开始排布
                yOffset = prepareWaterfallLayoutForSection(section, startY: yOffset, sectionInset: sectionInsetValue, interitemSpacing: interitem, lineSpacing: linespacing)
            } else {
                // 普通流式：使用系统计算的属性，但需要将该 section 的所有 frame 下移到当前 yOffset 之后，并按行进行水平对齐
                let sectionAttrs = baseAttributesAllSections.filter { $0.representedElementCategory == .cell && $0.indexPath.section == section }
                guard !sectionAttrs.isEmpty else {
                    // 如果没有找到系统计算的属性，手动创建流式布局
                    yOffset = prepareFlowLayoutForSection(section, startY: yOffset, sectionInset: sectionInsetValue, interitemSpacing: interitem, lineSpacing: linespacing)
                    continue
                }
                let minY = sectionAttrs.map { $0.frame.minY }.min() ?? 0
                let delta = (yOffset + sectionInsetValue.top) - minY
                var maxY: CGFloat = yOffset
                for attr in sectionAttrs {
                    attr.frame = attr.frame.offsetBy(dx: 0, dy: delta)
                    maxY = max(maxY, attr.frame.maxY)
                }
                // 按行分组并进行水平对齐
                let sorted = sectionAttrs.sorted { (a, b) in
                    if abs(a.frame.minY - b.frame.minY) > 0.1 { return a.frame.minY < b.frame.minY }
                    return a.indexPath.item < b.indexPath.item
                }
                var currentRow: [UICollectionViewLayoutAttributes] = []
                var currentYForRow: CGFloat = -1
                for attr in sorted {
                    if currentRow.isEmpty {
                        currentRow.append(attr)
                        currentYForRow = attr.frame.minY
                    } else {
                        if abs(attr.frame.minY - currentYForRow) <= 0.1 {
                            currentRow.append(attr)
                        } else {
                            arrangeRow(currentRow, sectionInset: sectionInsetValue, interitemSpacing: interitem)
                            currentRow.removeAll()
                            currentRow.append(attr)
                            currentYForRow = attr.frame.minY
                        }
                    }
                }
                if !currentRow.isEmpty {
                    arrangeRow(currentRow, sectionInset: sectionInsetValue, interitemSpacing: interitem)
                }
                cachedAttributes.append(contentsOf: sectionAttrs)
                yOffset = maxY + sectionInsetValue.bottom
            }

            // Footer（如有）：创建补充视图属性并堆叠
            if footerH > 0 {
                let footerIndex = IndexPath(item: 0, section: section)
                let footerAttr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: footerIndex)
                
                // 优先使用系统代理设置的宽度，否则使用可用宽度减去inset
                let footerWidth: CGFloat = {
                    if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                       let footerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section),
                       footerSize.width > 0 {
                        return min(footerSize.width, availableWidth - sectionInsetValue.left - sectionInsetValue.right)
                    }
                    return availableWidth - sectionInsetValue.left - sectionInsetValue.right
                }()
                
                footerAttr.frame = CGRect(x: sectionInsetValue.left, y: yOffset, width: max(0, footerWidth), height: footerH)
                footerAttr.zIndex = 500 // 确保 footer 在 cell 之上
                cachedAttributes.append(footerAttr)
                yOffset = footerAttr.frame.maxY
            }
        }
    }
    
    private func prepareFlowLayoutForSection(_ section: Int, startY: CGFloat, sectionInset: UIEdgeInsets, interitemSpacing: CGFloat, lineSpacing: CGFloat) -> CGFloat {
        guard let collectionView = collectionView else { return startY }
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        if numberOfItems == 0 {
            return startY + sectionInset.top + sectionInset.bottom
        }
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        var currentY = startY + sectionInset.top
        var currentX = sectionInset.left
        var currentRowAttributes: [UICollectionViewLayoutAttributes] = []
        var lastItemHeightInRow: CGFloat = 0
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)
            let size = getItemSize(for: indexPath, availableWidth: availableWidth)
            let itemWidth = size.width
            let itemHeight = size.height
            if currentRowAttributes.isEmpty == false && currentX + itemWidth > collectionView.bounds.width - sectionInset.right + 0.5 {
                arrangeRow(currentRowAttributes, sectionInset: sectionInset, interitemSpacing: interitemSpacing)
                currentRowAttributes.removeAll()
                currentX = sectionInset.left
                currentY += lastItemHeightInRow + lineSpacing
            }
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: currentX, y: currentY, width: itemWidth, height: itemHeight)
            cachedAttributes.append(attributes)
            currentRowAttributes.append(attributes)
            lastItemHeightInRow = itemHeight
            currentX += itemWidth + interitemSpacing
        }
        if !currentRowAttributes.isEmpty {
            arrangeRow(currentRowAttributes, sectionInset: sectionInset, interitemSpacing: interitemSpacing)
        }
        return (cachedAttributes.filter { $0.representedElementCategory == .cell && $0.indexPath.section == section }.map { $0.frame.maxY }.max() ?? (currentY)) + sectionInset.bottom
    }
    
    private func getItemSize(for indexPath: IndexPath, availableWidth: CGFloat) -> CGSize {
        // 优先从 delegate 获取尺寸
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
           let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) {
            return size
        }
        
        // 如果没有 delegate 提供尺寸，使用合理的默认值
        let defaultWidth = min(availableWidth * 0.3, 120) // 占可用宽度的30%，最大120
        let defaultHeight = defaultWidth * 1.2 // 1.2:1 的宽高比
        return CGSize(width: defaultWidth, height: defaultHeight)
    }
    
    @discardableResult
    private func prepareWaterfallLayoutForSection(_ section: Int, startY: CGFloat, sectionInset: UIEdgeInsets, interitemSpacing: CGFloat, lineSpacing: CGFloat) -> CGFloat {
        guard let collectionView = collectionView else { return startY }
        
        // 重置列高度，从 startY 开始
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        // 列数：优先 delegate.columns，再按最小宽度自适应，否则用全局列数
        let columns: Int = {
            if let cols = sectionDelegate?.layout(self, columnsFor: section, availableWidth: availableWidth), cols > 0 {
                return cols
            }
            if let minW = sectionDelegate?.layout(self, minimumItemWidthFor: section, availableWidth: availableWidth), minW > 0 {
                return max(1, Int( floor( (availableWidth + interitemSpacing) / (minW + interitemSpacing) ) ))
            }
            return max(1, columnCount)
        }()
        columnHeights = Array(repeating: startY + sectionInset.top, count: columns)
        
        let itemWidth = (availableWidth - CGFloat(columns - 1) * interitemSpacing) / CGFloat(columns)
        
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        if numberOfItems == 0 {
            return startY + sectionInset.top + sectionInset.bottom
        }
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 获取item高度
            let itemHeight = getItemHeight(for: indexPath, itemWidth: itemWidth)
            
            // 找到最短的列
            let shortestColumnIndex = findShortestColumn()
            
            // 计算位置
            let x = calculateXPosition(for: shortestColumnIndex, itemWidth: itemWidth, sectionInset: sectionInset, interitemSpacing: interitemSpacing)
            let y = columnHeights[shortestColumnIndex]
            
            attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            
            // 更新列高度
            columnHeights[shortestColumnIndex] += itemHeight + lineSpacing
            
            cachedAttributes.append(attributes)
        }
        // 本 section 的结束 y，去掉最后一次多加的行间距
        let endY = (columnHeights.max() ?? (startY + sectionInset.top)) - lineSpacing + sectionInset.bottom
        return endY
    }
    
    private func prepareWaterfallLayout() {
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        columnHeights = Array(repeating: sectionInset.top, count: columnCount)
        
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let itemWidth = (availableWidth - CGFloat(columnCount - 1) * minimumInteritemSpacing) / CGFloat(columnCount)
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 获取item高度（如果已缓存则使用缓存，否则使用默认高度）
            let itemHeight = getItemHeight(for: indexPath, itemWidth: itemWidth)
            
            // 找到最短的列
            let shortestColumnIndex = findShortestColumn()
            
            // 计算位置
            let x = calculateXPosition(for: shortestColumnIndex, itemWidth: itemWidth)
            let y = columnHeights[shortestColumnIndex]
            
            attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            
            // 更新列高度
            columnHeights[shortestColumnIndex] += itemHeight + minimumLineSpacing
            
            cachedAttributes.append(attributes)
        }
    }
    
    private func getItemHeight(for indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        // 检查是否已缓存高度，且宽度匹配（允许0.5像素误差）
        if let cached = itemHeights[indexPath], abs(cached.width - itemWidth) < 0.5 {
            return cached.height
        }
        
        // 尝试从delegate获取高度
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
           let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) {
            let height = size.height
            // 缓存高度和对应的宽度
            itemHeights[indexPath] = (height: height, width: itemWidth)
            return height
        }
        
        // 使用合理的默认高度（基于宽度比例）
        let defaultHeight = itemWidth * 1.2 // 1.2:1 的宽高比，更符合常见设计
        itemHeights[indexPath] = (height: defaultHeight, width: itemWidth)
        return defaultHeight
    }
    
    private func findShortestColumn() -> Int {
        var shortestIndex = 0
        var shortestHeight = columnHeights[0]
        
        for (index, height) in columnHeights.enumerated() {
            if height < shortestHeight {
                shortestHeight = height
                shortestIndex = index
            }
        }
        
        return shortestIndex
    }
    
    private func calculateXPosition(for columnIndex: Int, itemWidth: CGFloat, sectionInset: UIEdgeInsets? = nil, interitemSpacing: CGFloat? = nil) -> CGFloat {
        let inset = sectionInset ?? self.sectionInset
        let spacing = interitemSpacing ?? self.minimumInteritemSpacing
        let baseX = inset.left + CGFloat(columnIndex) * (itemWidth + spacing)
        
        // RTL支持：如果是RTL布局，需要调整x坐标
        if isRTL {
            return collectionViewWidth - baseX - itemWidth
        }
        
        return baseX
    }
    
    // MARK: - 公共接口方法
    
    /// 设置布局模式
    public func setLayoutMode(_ mode: LayoutMode, columnCount: Int = 2) { // 默认2列
        self.layoutMode = mode
        self.columnCount = max(1, columnCount)
        invalidateLayout()
    }
    
    /// 为指定section启用瀑布流布局
    public func enableWaterfallForSection(_ section: Int) {
        waterfallSections.insert(section)
        invalidateLayout()
    }
    
    /// 为指定section禁用瀑布流布局
    public func disableWaterfallForSection(_ section: Int) {
        waterfallSections.remove(section)
        invalidateLayout()
    }
    
    /// 为多个section启用瀑布流布局
    public func enableWaterfallForSections(_ sections: [Int]) {
        waterfallSections.formUnion(sections)
        invalidateLayout()
    }
    
    /// 清除所有瀑布流section设置
    public func clearWaterfallSections() {
        waterfallSections.removeAll()
        invalidateLayout()
    }
    
    /// 检查指定section是否使用瀑布流布局
    public func isWaterfallEnabledForSection(_ section: Int) -> Bool {
        return waterfallSections.contains(section) || layoutMode == .waterfall
    }
    
    /// 清除item高度缓存（当item高度可能变化时调用）
    public func clearItemHeightCache() {
        itemHeights.removeAll()
        invalidateLayout()
    }
    
    /// 为特定indexPath设置item高度和宽度
    public func setItemHeight(_ height: CGFloat, for indexPath: IndexPath, width: CGFloat) {
        itemHeights[indexPath] = (height: height, width: width)
    }
    
    /// 为特定indexPath设置item高度（使用当前计算的宽度）
    @available(*, deprecated, message: "请使用 setItemHeight(_:for:width:) 方法以确保高度与宽度匹配")
    public func setItemHeight(_ height: CGFloat, for indexPath: IndexPath) {
        // 尝试计算当前的 itemWidth
        guard let collectionView = collectionView else { return }
        let section = indexPath.section
        let availableWidth = collectionView.bounds.width
        
        let sectionInsetValue = sectionDelegate?.layout(self, sectionInsetFor: section) ?? sectionInset
        let interitem = sectionDelegate?.layout(self, interitemSpacingFor: section) ?? minimumInteritemSpacing
        let contentWidth = availableWidth - sectionInsetValue.left - sectionInsetValue.right
        
        let columns: Int = {
            if let cols = sectionDelegate?.layout(self, columnsFor: section, availableWidth: availableWidth), cols > 0 {
                return cols
            }
            if let minW = sectionDelegate?.layout(self, minimumItemWidthFor: section, availableWidth: availableWidth), minW > 0 {
                return max(1, Int(floor((contentWidth + interitem) / (minW + interitem))))
            }
            return max(1, columnCount)
        }()
        
        let itemWidth = (contentWidth - CGFloat(columns - 1) * interitem) / CGFloat(columns)
        itemHeights[indexPath] = (height: height, width: itemWidth)
    }
    
    override public var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        // 总是使用缓存属性计算内容尺寸
        let maxHeight = cachedAttributes.map { $0.frame.maxY }.max() ?? 0
        // 注意：各 section 的底部间距和 Footer 已在布局阶段计入 frame，避免重复累加额外的 bottom inset
        return CGSize(width: collectionView.bounds.width, height: maxHeight)
    }
}

// MARK: - 使用示例
/*

使用示例：

1. 基本使用（普通流式布局）：
```swift
let layout = TFYSwiftRTLAlignedFlowLayout(horizontalAlignment: .center)
collectionView.collectionViewLayout = layout
```

2. 全局瀑布流布局：
```swift
let layout = TFYSwiftRTLAlignedFlowLayout(layoutMode: .waterfall, columnCount: 3)
collectionView.collectionViewLayout = layout
```

3. 按组控制瀑布流（推荐用法）：
```swift
let layout = TFYSwiftRTLAlignedFlowLayout(horizontalAlignment: .leading)

// 为第1组启用瀑布流
layout.enableWaterfallForSection(1)

// 为第3、4组启用瀑布流
layout.enableWaterfallForSections([3, 4])

collectionView.collectionViewLayout = layout
```

4. 动态切换布局模式：
```swift
// 切换到瀑布流模式
layout.setLayoutMode(.waterfall, columnCount: 2)

// 切换回普通模式
layout.setLayoutMode(.flow)

// 清除所有瀑布流设置
layout.clearWaterfallSections()
```

5. 高度自适应设置：
```swift
// 为特定item设置高度（推荐：同时提供宽度）
let itemWidth: CGFloat = 100 // 实际的item宽度
layout.setItemHeight(150, for: IndexPath(item: 0, section: 0), width: itemWidth)

// 或使用自动计算宽度的方法（已过时，但仍可用）
layout.setItemHeight(150, for: IndexPath(item: 0, section: 0))

// 清除高度缓存（当数据更新或列数/宽度变化时）
layout.clearItemHeightCache()
```

6. 在UICollectionViewDelegateFlowLayout中提供高度：
```swift
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let layout = collectionViewLayout as! TFYSwiftRTLAlignedFlowLayout
    
    if layout.isWaterfallEnabledForSection(indexPath.section) {
        // 瀑布流模式：返回固定宽度，高度自适应
        let availableWidth = collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        let itemWidth = (availableWidth - CGFloat(layout.columnCount - 1) * layout.minimumInteritemSpacing) / CGFloat(layout.columnCount)
        
        // 根据内容计算高度
        let height = calculateHeightForItem(at: indexPath, width: itemWidth)
        return CGSize(width: itemWidth, height: height)
    } else {
        // 普通模式：返回固定尺寸
        return CGSize(width: 100, height: 100)
    }
}
```

7. RTL支持：
```swift
// 自动支持RTL布局，无需额外配置
// 在RTL环境下，瀑布流会自动从右到左排列
```

8. 使用 TFYSwiftRTLAlignedFlowLayoutDelegate 进行高级配置：
```swift
class MyViewController: UIViewController, TFYSwiftRTLAlignedFlowLayoutDelegate {
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, isWaterfallFor section: Int) -> Bool? {
        // 为特定section启用瀑布流
        return section % 2 == 1 // 奇数组使用瀑布流
    }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, columnsFor section: Int, availableWidth: CGFloat) -> Int? {
        // 为不同section设置不同列数
        switch section {
        case 0: return 2
        case 1: return 3
        default: return nil // 使用默认列数
        }
    }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, minimumItemWidthFor section: Int, availableWidth: CGFloat) -> CGFloat? {
        // 使用最小宽度自适应列数
        return availableWidth * 0.3 // 每个item最小占30%宽度
    }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, interitemSpacingFor section: Int) -> CGFloat? {
        // 为不同section设置不同间距
        return section % 2 == 0 ? 8 : 12
    }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, lineSpacingFor section: Int) -> CGFloat? {
        // 为不同section设置不同行间距
        return section % 2 == 0 ? 10 : 15
    }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, sectionInsetFor section: Int) -> UIEdgeInsets? {
        // 为不同section设置不同内边距
        let baseInset: CGFloat = 16
        return UIEdgeInsets(top: baseInset, left: baseInset, bottom: baseInset, right: baseInset)
    }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, headerHeightFor section: Int, width: CGFloat) -> CGFloat? {
        // 为不同section设置不同header高度
        // 注意：如果用户通过系统代理设置了header尺寸，系统代理的设置有更高优先级
        return section % 2 == 0 ? 40 : 60
    }
    
    func layout(_ layout: TFYSwiftRTLAlignedFlowLayout, footerHeightFor section: Int, width: CGFloat) -> CGFloat? {
        // 为不同section设置不同footer高度
        // 注意：如果用户通过系统代理设置了footer尺寸，系统代理的设置有更高优先级
        return section % 2 == 0 ? 20 : 30
    }
}
```

9. 混合布局示例（流式 + 瀑布流）：
```swift
let layout = TFYSwiftRTLAlignedFlowLayout(horizontalAlignment: .leading)
layout.sectionDelegate = self

// 设置混合布局
layout.enableWaterfallForSections([1, 3, 5]) // 第1、3、5组使用瀑布流
// 其他组使用普通流式布局

collectionView.collectionViewLayout = layout
```

10. 系统代理优先级示例：
```swift
// 系统代理的设置有最高优先级
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    // 这个方法返回的尺寸会覆盖 TFYSwiftRTLAlignedFlowLayoutDelegate 的设置
    return CGSize(width: collectionView.bounds.width, height: 50)
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    // 这个方法返回的尺寸会覆盖 TFYSwiftRTLAlignedFlowLayoutDelegate 的设置
    return CGSize(width: collectionView.bounds.width, height: 30)
}

// 如果系统代理返回 CGSize.zero 或没有实现这些方法，
// 则会使用 TFYSwiftRTLAlignedFlowLayoutDelegate 的设置
```

注意事项：
- 瀑布流模式下，建议在delegate中提供准确的item高度
- **高度缓存机制**：高度与对应的itemWidth一起缓存，宽度变化时会自动重新计算高度，避免高度显示异常
- 使用按组控制时，不同section可以有不同的布局模式
- 清除高度缓存后需要重新计算布局
- 支持屏幕旋转和动态内容更新（宽度变化时自动重新计算）
- 使用delegate可以实现更精细的布局控制
- 混合布局可以创建更丰富的视觉效果
- **Header/Footer 尺寸优先级**：系统代理 > TFYSwiftRTLAlignedFlowLayoutDelegate > 默认值
- 用户可以通过系统代理完全控制 header/footer 的显示和尺寸
- **建议使用新的 setItemHeight(_:for:width:) 方法**手动设置高度时同时提供宽度，确保高度与宽度匹配

*/

