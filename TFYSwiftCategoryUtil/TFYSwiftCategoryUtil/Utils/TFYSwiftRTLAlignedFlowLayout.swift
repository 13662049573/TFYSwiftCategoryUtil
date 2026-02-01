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

// MARK: - Main Layout Class
public class TFYSwiftRTLAlignedFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - Constants
    
    /// 用于浮点数比较的最小差值阈值（避免精度问题）
    private static let floatComparisonThreshold: CGFloat = 0.1
    /// 宽度匹配的误差范围
    private static let widthMatchTolerance: CGFloat = 0.5
    /// Header 视图的 zIndex
    private static let headerZIndex: Int = 1000
    /// Footer 视图的 zIndex
    private static let footerZIndex: Int = 500
    
    // MARK: - Enums
    
    public enum HorizontalAlignment { case leading, center, trailing }
    public enum LayoutMode { case flow, waterfall }
    
    // MARK: - Properties
    
    /// 缓存的布局属性
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    /// 上次的内容尺寸（用于检测变化）
    private var lastContentSize = CGSize.zero
    /// 上次的集合视图宽度（用于检测旋转等变化）
    private var lastCollectionViewWidth: CGFloat = 0
    
    // 瀑布流相关属性
    /// 当前各列的高度
    private var columnHeights: [CGFloat] = []
    /// 默认列数（可通过初始化参数或delegate修改）
    public private(set) var columnCount: Int = 2
    /// 缓存的item高度和对应的宽度
    private var itemHeights: [IndexPath: (height: CGFloat, width: CGFloat)] = [:]
    /// 启用瀑布流的section集合
    private var waterfallSections: Set<Int> = []
    
    /// 水平对齐方式
    private(set) var horizontalAlignment: HorizontalAlignment
    /// 集合视图宽度（会在prepare中同步）
    private(set) var collectionViewWidth: CGFloat
    /// 是否为RTL布局
    private(set) var isRTL: Bool = false
    /// 布局模式
    private(set) var layoutMode: LayoutMode = .flow
    
    /// 自定义delegate（用于按section配置布局）
    public weak var sectionDelegate: TFYSwiftRTLAlignedFlowLayoutDelegate?
    
    /// 当系统代理设置了header/footer宽度时，是否限制宽度不超过可用宽度减去inset
    /// 默认值为 true，保持原有行为（限制宽度）
    /// 设置为 false 时，完全使用系统代理设置的宽度，不减去inset
    public var shouldLimitHeaderFooterWidthByInset: Bool = false

    // MARK: - Initialization
    
    public init(horizontalAlignment: HorizontalAlignment = .leading,
                collectionViewWidth: CGFloat = UIScreen.main.bounds.width,
                layoutMode: LayoutMode = .flow,
                columnCount: Int = 2) {
        self.horizontalAlignment = horizontalAlignment
        self.collectionViewWidth = collectionViewWidth
        self.layoutMode = layoutMode
        self.columnCount = max(1, columnCount)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Lifecycle
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // 宽度变化时重新布局（如旋转屏幕）
        guard let collectionView = collectionView else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        return newBounds.width != collectionView.bounds.width || super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 同步当前宽度，避免使用初始化时的固定宽度
        collectionViewWidth = collectionView.bounds.width
        
        // 检测RTL布局
        isRTL = UIView.userInterfaceLayoutDirection(
            for: collectionView.semanticContentAttribute
        ) == .rightToLeft
        
        // 判断是否需要更新布局
        let baseContentSize = super.collectionViewContentSize
        let currentWidth = collectionView.bounds.width
        let needUpdate = cachedAttributes.isEmpty
            || lastCollectionViewWidth != currentWidth
            || lastContentSize != baseContentSize
        
        if needUpdate {
            prepareMixedLayout()
            lastContentSize = baseContentSize
            lastCollectionViewWidth = currentWidth
        }
    }
    
    // MARK: - Private Layout Methods
    
    /// 对一行中的 items 进行水平对齐与 RTL 处理
    /// - Parameters:
    ///   - attributes: 需要排列的布局属性数组
    ///   - sectionInset: section 的内边距
    ///   - interitemSpacing: item 间距
    private func arrangeRow(_ attributes: [UICollectionViewLayoutAttributes],
                           sectionInset: UIEdgeInsets,
                           interitemSpacing: CGFloat) {
        guard !attributes.isEmpty else { return }
        
        // 计算总宽度
        let totalWidth = attributes.reduce(0) { $0 + $1.frame.width } + interitemSpacing * CGFloat(attributes.count - 1)
        
        // 根据对齐方式和RTL设置计算起始x坐标
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
        
        // 按 indexPath.item 排序，确保顺序正确
        let sortedAttributes = attributes.sorted { $0.indexPath.item < $1.indexPath.item }
        
        // 依次设置每个 item 的 x 坐标
        for attribute in sortedAttributes {
            let itemWidth = attribute.frame.width
            // RTL时x是右侧边缘，需要减去宽度得到左边缘
            attribute.frame.origin.x = isRTL ? (xOffset - itemWidth) : xOffset
            // 更新偏移：LTR向右累加，RTL向左递减
            xOffset += isRTL ? -(itemWidth + interitemSpacing) : (itemWidth + interitemSpacing)
        }
    }
    
    /// 计算指定 section 的列数
    /// - Parameters:
    ///   - section: section 索引
    ///   - availableWidth: 可用宽度
    ///   - interitemSpacing: item 间距
    /// - Returns: 列数
    private func calculateColumnCount(for section: Int,
                                     availableWidth: CGFloat,
                                     interitemSpacing: CGFloat) -> Int {
        // 优先级：delegate.columns > delegate.minimumItemWidth > 全局 columnCount
        if let cols = sectionDelegate?.layout(self, columnsFor: section, availableWidth: availableWidth), cols > 0 {
            return cols
        }
        
        if let minW = sectionDelegate?.layout(self, minimumItemWidthFor: section, availableWidth: availableWidth), minW > 0 {
            return max(1, Int(floor((availableWidth + interitemSpacing) / (minW + interitemSpacing))))
        }
        
        return max(1, columnCount)
    }
    
    // MARK: - Override Methods
    
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
    
    override public var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let maxHeight = cachedAttributes.map { $0.frame.maxY }.max() ?? 0
        return CGSize(width: collectionView.bounds.width, height: maxHeight)
    }
    
    // MARK: - Mixed Layout (Flow + Waterfall)
    
    /// 准备混合布局（支持每个 section 独立配置流式或瀑布流）
    private func prepareMixedLayout() {
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        
        let totalSections = collectionView.numberOfSections
        var yOffset: CGFloat = 0
        
        // 判断是否需要计算系统流式布局（仅当有非瀑布流 section 时）
        let needsSystemLayout = (0..<totalSections).contains { section in
            let isWaterfall = layoutMode == .waterfall ||
                             waterfallSections.contains(section) ||
                             (sectionDelegate?.layout(self, isWaterfallFor: section) ?? false)
            return !isWaterfall
        }
        
        // 按需计算系统流式布局的基础属性（性能优化）
        let baseAttributesAllSections: [UICollectionViewLayoutAttributes]
        if needsSystemLayout {
            baseAttributesAllSections = (
                super.layoutAttributesForElements(
                    in: CGRect(origin: .zero, size: super.collectionViewContentSize)
                )?.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
            ) ?? []
        } else {
            baseAttributesAllSections = []
        }
        
        for section in 0..<totalSections {
            let availableWidth = collectionView.bounds.width
            let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
            
            // 读取每组配置（优先级：系统代理 > 自定义delegate > 默认值）
            let sectionInsetValue: UIEdgeInsets = {
                if let systemInset = systemDelegate?.collectionView?(collectionView, layout: self, insetForSectionAt: section) {
                    return systemInset
                }
                return sectionDelegate?.layout(self, sectionInsetFor: section) ?? sectionInset
            }()
            
            let interitem: CGFloat = {
                if let systemSpacing = systemDelegate?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
                    return systemSpacing
                }
                return sectionDelegate?.layout(self, interitemSpacingFor: section) ?? minimumInteritemSpacing
            }()
            
            let lineSpacing: CGFloat = {
                if let systemSpacing = systemDelegate?.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) {
                    return systemSpacing
                }
                return sectionDelegate?.layout(self, lineSpacingFor: section) ?? minimumLineSpacing
            }()
            
            // 优先使用系统代理设置的高度，如果没有则使用自定义delegate
            let headerH: CGFloat = {
                if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                   let headerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section),
                   headerSize.height > 0 {
                    return headerSize.height
                }
                return sectionDelegate?.layout(self, headerHeightFor: section, width: availableWidth) ?? 0
            }()
            
            let footerH: CGFloat = {
                if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                   let footerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section),
                   footerSize.height > 0 {
                    return footerSize.height
                }
                return sectionDelegate?.layout(self, footerHeightFor: section, width: availableWidth) ?? 0
            }()
            
            let isWaterfallSection: Bool = {
                if layoutMode == .waterfall || waterfallSections.contains(section) { return true }
                return sectionDelegate?.layout(self, isWaterfallFor: section) ?? false
            }()

            // Header（如有）：创建补充视图属性并堆叠
            if headerH > 0 {
                let headerIndex = IndexPath(item: 0, section: section)
                let headerAttr = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: headerIndex
                )
                
                // 优先使用系统代理设置的宽度，否则使用可用宽度减去inset
                let headerWidth: CGFloat = {
                    if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                       let headerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section),
                       headerSize.width > 0 {
                        // 根据开关决定是否限制宽度
                        if shouldLimitHeaderFooterWidthByInset {
                            return min(headerSize.width, availableWidth - sectionInsetValue.left - sectionInsetValue.right)
                        } else {
                            return headerSize.width
                        }
                    }
                    return availableWidth - sectionInsetValue.left - sectionInsetValue.right
                }()
                
                headerAttr.frame = CGRect(x: shouldLimitHeaderFooterWidthByInset ? sectionInsetValue.left : 0, y: yOffset, width: max(0, headerWidth), height: headerH)
                headerAttr.zIndex = Self.headerZIndex
                cachedAttributes.append(headerAttr)
                yOffset = headerAttr.frame.maxY
            }

            if isWaterfallSection {
                // 瀑布流：从当前 yOffset 开始排布
                yOffset = prepareWaterfallLayoutForSection(
                    section,
                    startY: yOffset,
                    sectionInset: sectionInsetValue,
                    interitemSpacing: interitem,
                    lineSpacing: lineSpacing
                )
            } else {
                // 普通流式：使用系统计算的属性，但需要将该 section 的所有 frame 下移到当前 yOffset 之后，并按行进行水平对齐
                let sectionAttrs = baseAttributesAllSections.filter {
                    $0.representedElementCategory == .cell && $0.indexPath.section == section
                }
                guard !sectionAttrs.isEmpty else {
                    // 如果没有找到系统计算的属性，手动创建流式布局
                    yOffset = prepareFlowLayoutForSection(
                        section,
                        startY: yOffset,
                        sectionInset: sectionInsetValue,
                        interitemSpacing: interitem,
                        lineSpacing: lineSpacing
                    )
                    continue
                }
                
                // 调整 section 内所有 item 的 y 坐标
                let minY = sectionAttrs.map { $0.frame.minY }.min() ?? 0
                let delta = (yOffset + sectionInsetValue.top) - minY
                var maxY: CGFloat = yOffset
                for attr in sectionAttrs {
                    attr.frame = attr.frame.offsetBy(dx: 0, dy: delta)
                    maxY = max(maxY, attr.frame.maxY)
                }
                
                // 按行分组并进行水平对齐
                let sorted = sectionAttrs.sorted { (a, b) in
                    if abs(a.frame.minY - b.frame.minY) > Self.floatComparisonThreshold {
                        return a.frame.minY < b.frame.minY
                    }
                    return a.indexPath.item < b.indexPath.item
                }
                
                var currentRow: [UICollectionViewLayoutAttributes] = []
                var currentYForRow: CGFloat = -1
                for attr in sorted {
                    if currentRow.isEmpty {
                        currentRow.append(attr)
                        currentYForRow = attr.frame.minY
                    } else {
                        if abs(attr.frame.minY - currentYForRow) <= Self.floatComparisonThreshold {
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
                let footerAttr = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    with: footerIndex
                )
                
                // 优先使用系统代理设置的宽度，否则使用可用宽度减去inset
                let footerWidth: CGFloat = {
                    if let systemDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
                       let footerSize = systemDelegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section),
                       footerSize.width > 0 {
                        // 根据开关决定是否限制宽度
                        if shouldLimitHeaderFooterWidthByInset {
                            return min(footerSize.width, availableWidth - sectionInsetValue.left - sectionInsetValue.right)
                        } else {
                            return footerSize.width
                        }
                    }
                    return availableWidth - sectionInsetValue.left - sectionInsetValue.right
                }()
                
                footerAttr.frame = CGRect(x: shouldLimitHeaderFooterWidthByInset ? sectionInsetValue.left : 0, y: yOffset, width: max(0, footerWidth), height: footerH)
                footerAttr.zIndex = Self.footerZIndex
                cachedAttributes.append(footerAttr)
                yOffset = footerAttr.frame.maxY
            }
        }
    }
    
    /// 为指定 section 准备流式布局（当系统布局不可用时手动创建）
    /// - Parameters:
    ///   - section: section 索引
    ///   - startY: 起始 y 坐标
    ///   - sectionInset: section 内边距
    ///   - interitemSpacing: item 间距
    ///   - lineSpacing: 行间距
    /// - Returns: 布局结束后的 y 坐标
    private func prepareFlowLayoutForSection(_ section: Int,
                                            startY: CGFloat,
                                            sectionInset: UIEdgeInsets,
                                            interitemSpacing: CGFloat,
                                            lineSpacing: CGFloat) -> CGFloat {
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
            
            // 检查是否需要换行（允许0.5像素误差）
            if !currentRowAttributes.isEmpty &&
               currentX + itemWidth > collectionView.bounds.width - sectionInset.right + Self.widthMatchTolerance {
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
        
        let maxY = cachedAttributes
            .filter { $0.representedElementCategory == .cell && $0.indexPath.section == section }
            .map { $0.frame.maxY }
            .max() ?? currentY
        
        return maxY + sectionInset.bottom
    }
    
    /// 获取 item 的尺寸（优先从 delegate 获取，否则使用默认值）
    /// - Parameters:
    ///   - indexPath: item 的 indexPath
    ///   - availableWidth: 可用宽度
    /// - Returns: item 尺寸
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
    
    // MARK: - Waterfall Layout
    
    /// 为指定 section 准备瀑布流布局
    /// - Parameters:
    ///   - section: section 索引
    ///   - startY: 起始 y 坐标
    ///   - sectionInset: section 内边距
    ///   - interitemSpacing: item 间距
    ///   - lineSpacing: 行间距
    /// - Returns: 布局结束后的 y 坐标
    @discardableResult
    private func prepareWaterfallLayoutForSection(_ section: Int,
                                                 startY: CGFloat,
                                                 sectionInset: UIEdgeInsets,
                                                 interitemSpacing: CGFloat,
                                                 lineSpacing: CGFloat) -> CGFloat {
        guard let collectionView = collectionView else { return startY }
        
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        
        // 使用提取的方法计算列数
        let columns = calculateColumnCount(for: section, availableWidth: availableWidth, interitemSpacing: interitemSpacing)
        
        // 重置列高度，从 startY + sectionInset.top 开始
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
            let x = calculateXPosition(
                for: shortestColumnIndex,
                itemWidth: itemWidth,
                sectionInset: sectionInset,
                interitemSpacing: interitemSpacing
            )
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
    
    /// 获取 item 的高度（带缓存机制）
    /// - Parameters:
    ///   - indexPath: item 的 indexPath
    ///   - itemWidth: item 的宽度
    /// - Returns: item 高度
    private func getItemHeight(for indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        // 检查是否已缓存高度，且宽度匹配（避免宽度变化后高度失效）
        if let cached = itemHeights[indexPath], abs(cached.width - itemWidth) < Self.widthMatchTolerance {
            return cached.height
        }
        
        // 尝试从 delegate 获取高度
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
           let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) {
            let height = size.height
            // 缓存高度和对应的宽度
            itemHeights[indexPath] = (height: height, width: itemWidth)
            return height
        }
        
        // 使用合理的默认高度（基于宽度比例）
        let defaultHeight = itemWidth * 1.2 // 1.2:1 的宽高比
        itemHeights[indexPath] = (height: defaultHeight, width: itemWidth)
        return defaultHeight
    }
    
    /// 找到瀑布流中最短的列
    /// - Returns: 最短列的索引
    private func findShortestColumn() -> Int {
        guard !columnHeights.isEmpty else { return 0 }
        
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
    
    /// 计算瀑布流中指定列的 x 坐标
    /// - Parameters:
    ///   - columnIndex: 列索引
    ///   - itemWidth: item 宽度
    ///   - sectionInset: section 内边距（可选，默认使用全局设置）
    ///   - interitemSpacing: item 间距（可选，默认使用全局设置）
    /// - Returns: x 坐标
    private func calculateXPosition(for columnIndex: Int,
                                    itemWidth: CGFloat,
                                    sectionInset: UIEdgeInsets? = nil,
                                    interitemSpacing: CGFloat? = nil) -> CGFloat {
        let inset = sectionInset ?? self.sectionInset
        let spacing = interitemSpacing ?? self.minimumInteritemSpacing
        let baseX = inset.left + CGFloat(columnIndex) * (itemWidth + spacing)
        
        // RTL支持：如果是RTL布局，需要调整x坐标
        if isRTL {
            return collectionViewWidth - baseX - itemWidth
        }
        
        return baseX
    }
    
    // MARK: - Public API
    
    /// 设置布局模式
    /// - Parameters:
    ///   - mode: 布局模式（flow 或 waterfall）
    ///   - columnCount: 瀑布流列数（默认2列）
    public func setLayoutMode(_ mode: LayoutMode, columnCount: Int = 2) {
        self.layoutMode = mode
        self.columnCount = max(1, columnCount)
        invalidateLayout()
    }
    
    /// 为指定 section 启用瀑布流布局
    /// - Parameter section: section 索引
    public func enableWaterfallForSection(_ section: Int) {
        waterfallSections.insert(section)
        invalidateLayout()
    }
    
    /// 为指定 section 禁用瀑布流布局
    /// - Parameter section: section 索引
    public func disableWaterfallForSection(_ section: Int) {
        waterfallSections.remove(section)
        invalidateLayout()
    }
    
    /// 为多个 section 启用瀑布流布局
    /// - Parameter sections: section 索引数组
    public func enableWaterfallForSections(_ sections: [Int]) {
        waterfallSections.formUnion(sections)
        invalidateLayout()
    }
    
    /// 清除所有瀑布流 section 设置
    public func clearWaterfallSections() {
        waterfallSections.removeAll()
        invalidateLayout()
    }
    
    /// 检查指定 section 是否使用瀑布流布局
    /// - Parameter section: section 索引
    /// - Returns: 是否启用瀑布流
    public func isWaterfallEnabledForSection(_ section: Int) -> Bool {
        return waterfallSections.contains(section) || layoutMode == .waterfall
    }
    
    /// 清除 item 高度缓存（当 item 高度可能变化或列数/宽度变化时调用）
    public func clearItemHeightCache() {
        itemHeights.removeAll()
        invalidateLayout()
    }
    
    /// 为特定 indexPath 设置 item 高度和宽度
    /// - Parameters:
    ///   - height: item 高度
    ///   - indexPath: item 的 indexPath
    ///   - width: item 宽度
    public func setItemHeight(_ height: CGFloat, for indexPath: IndexPath, width: CGFloat) {
        itemHeights[indexPath] = (height: height, width: width)
    }
    
    /// 为特定 indexPath 设置 item 高度（自动计算宽度）
    /// - Parameters:
    ///   - height: item 高度
    ///   - indexPath: item 的 indexPath
    @available(*, deprecated, message: "请使用 setItemHeight(_:for:width:) 方法以确保高度与宽度匹配")
    public func setItemHeight(_ height: CGFloat, for indexPath: IndexPath) {
        guard let collectionView = collectionView else { return }
        let section = indexPath.section
        let availableWidth = collectionView.bounds.width
        
        let sectionInsetValue = sectionDelegate?.layout(self, sectionInsetFor: section) ?? sectionInset
        let interitem = sectionDelegate?.layout(self, interitemSpacingFor: section) ?? minimumInteritemSpacing
        let contentWidth = availableWidth - sectionInsetValue.left - sectionInsetValue.right
        
        // 使用提取的方法计算列数
        let columns = calculateColumnCount(for: section, availableWidth: availableWidth, interitemSpacing: interitem)
        let itemWidth = (contentWidth - CGFloat(columns - 1) * interitem) / CGFloat(columns)
        
        itemHeights[indexPath] = (height: height, width: itemWidth)
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

11. Header/Footer宽度控制开关：
```swift
let layout = TFYSwiftRTLAlignedFlowLayout()

// 默认行为（true）：当系统代理设置了header/footer宽度时，会限制宽度不超过可用宽度减去inset
layout.shouldLimitHeaderFooterWidthByInset = true

// 设置为false：完全使用系统代理设置的宽度，不减去inset
layout.shouldLimitHeaderFooterWidthByInset = false

// 例如：如果系统代理返回 CGSize(width: 400, height: 50)，可用宽度为375，inset为(left: 16, right: 16)
// shouldLimitHeaderFooterWidthByInset = true: 实际宽度为 min(400, 375-16-16) = 343
// shouldLimitHeaderFooterWidthByInset = false: 实际宽度为 400（可能超出屏幕边界）
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
- **Header/Footer 宽度控制**：默认情况下，即使系统代理设置了宽度，也会限制为可用宽度减去inset。可通过 `shouldLimitHeaderFooterWidthByInset` 开关控制此行为。设置为 `false` 时，完全使用系统代理设置的宽度（可能超出屏幕边界）
- **建议使用新的 setItemHeight(_:for:width:) 方法**手动设置高度时同时提供宽度，确保高度与宽度匹配

*/

