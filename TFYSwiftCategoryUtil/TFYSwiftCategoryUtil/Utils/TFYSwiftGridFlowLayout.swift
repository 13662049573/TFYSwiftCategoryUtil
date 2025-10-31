//
//  TFYSwiftGridFlowLayout.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2025/2/14.
//  用途：自定义 UICollectionView 网格流式布局，支持动态列数、间距、补充视图等。
//  优化：支持单行多列水平滚动和多行多列垂直滚动
//

import UIKit

// MARK: - 布局模式枚举
public enum TFYSwiftGridLayoutMode {
    case vertical   // 垂直瀑布流（多行多列）
    case horizontal // 水平单行滚动（一行多列）
}

protocol TFYSwiftGridFlowLayoutDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        columnsCountForSection section: Int) -> Int
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        rowsCountForSection section: Int) -> Int

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
    func collectionView(_: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        columnsCountForSection _: Int) -> Int
    {
        return layout.columnsCount
    }
    
    func collectionView(_: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        rowsCountForSection _: Int) -> Int
    {
        return layout.rowsCount
    }

    func collectionView(_: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        insetForSection _: Int) -> UIEdgeInsets
    {
        return layout.edgeInsets
    }

    func collectionView(_: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        lineSpacingForSection _: Int) -> CGFloat
    {
        return layout.rowSpacing
    }

    func collectionView(_: UICollectionView,
                        layout: TFYSwiftGridFlowLayout,
                        interitemSpacingForSection _: Int) -> CGFloat
    {
        return layout.columnSpacing
    }
}

public class TFYSwiftGridFlowLayout: UICollectionViewFlowLayout {
    // MARK: - 配置属性

    /// 列数（用于垂直布局和水平布局）
    public var columnsCount: Int = 2 {
        didSet { invalidateLayout() }
    }
    
    /// 行数（用于判断布局模式：1为单行水平滚动，>1为多行垂直滚动）
    public var rowsCount: Int = 0 {
        didSet { invalidateLayout() }
    }

    /// 行间距
    public var rowSpacing: CGFloat = 10 {
        didSet { invalidateLayout() }
    }

    /// 列间距
    public var columnSpacing: CGFloat = 10 {
        didSet { invalidateLayout() }
    }

    /// 边距
    public var edgeInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) {
        didSet { invalidateLayout() }
    }

    /// 是否等高（仅对垂直布局有效）
    public var isEqualHeight: Bool = true {
        didSet { invalidateLayout() }
    }

    /// 最大item高度限制
    public var maxItemHeight: CGFloat? {
        didSet { invalidateLayout() }
    }
    
    /// 最大item宽度限制（用于水平布局）
    public var maxItemWidth: CGFloat? {
        didSet { invalidateLayout() }
    }

    // MARK: - 布局属性

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var sectionColumnsHeights: [[CGFloat]] = []
    private var sectionRowWidths: [[CGFloat]] = [] // 用于水平布局
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0 // 用于水平布局
    
    private weak var gridDelegate: TFYSwiftGridFlowLayoutDelegateFlowLayout? {
        return collectionView?.delegate as? TFYSwiftGridFlowLayoutDelegateFlowLayout
    }
    
    /// 当前布局模式（根据rowsCount自动判断）
    private var layoutMode: TFYSwiftGridLayoutMode {
        // 如果rowsCount为1，使用水平滚动；否则使用垂直瀑布流
        return rowsCount == 1 ? .horizontal : .vertical
    }
    
    /// 是否为RTL布局（从右到左）
    private var isRTL: Bool {
        guard let collectionView = collectionView else { return false }
        return UIView.userInterfaceLayoutDirection(for: collectionView.semanticContentAttribute) == .rightToLeft
    }

    // MARK: - 布局计算

    override public func prepare() {
        guard let collectionView = collectionView else { return }

        resetLayoutState()

        let sectionsCount = collectionView.numberOfSections
        for section in 0 ..< sectionsCount {
            let sectionRowsCount = getRowsCount(for: section)
            if sectionRowsCount == 1 {
                // 单行水平滚动布局
                prepareSectionLayoutHorizontal(section: section, collectionView: collectionView)
            } else {
                // 多行垂直瀑布流布局
                prepareSectionLayoutVertical(section: section, collectionView: collectionView)
            }
        }
    }

    private func resetLayoutState() {
        cache.removeAll()
        sectionColumnsHeights.removeAll()
        sectionRowWidths.removeAll()
        contentHeight = 0
        contentWidth = 0
    }

    // MARK: - 垂直布局（多行多列瀑布流）
    
    private func prepareSectionLayoutVertical(section: Int, collectionView: UICollectionView) {
        // Header处理
        let headerIndexPath = IndexPath(item: 0, section: section)
        if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: headerIndexPath),
           headerAttributes.frame.height > 0
        {
            cache.append(headerAttributes)
            contentHeight = headerAttributes.frame.maxY
        }

        // Items布局
        let columnsCount = getColumnsCount(for: section)
        let sectionInset = getSectionInset(for: section)
        let lineSpacing = getLineSpacing(for: section)
        let interitemSpacing = getInteritemSpacing(for: section)

        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        guard columnsCount > 0 else {
            print("⚠️ TFYSwiftGridFlowLayout: 列数必须大于0，section=\(section)")
            return
        }
        
        let itemWidth = (availableWidth - CGFloat(columnsCount - 1) * interitemSpacing) / CGFloat(columnsCount)
        guard itemWidth > 0 else {
            print("⚠️ TFYSwiftGridFlowLayout: Item宽度计算结果<=0，请检查边距和列数设置，section=\(section)")
            return
        }

        // 初始化列高度数组
        if section >= sectionColumnsHeights.count {
            sectionColumnsHeights.append(Array(repeating: contentHeight + sectionInset.top, count: columnsCount))
        }

        let itemsCount = collectionView.numberOfItems(inSection: section)
        for item in 0 ..< itemsCount {
            let indexPath = IndexPath(item: item, section: section)
            if let attributes = layoutAttributesForItemVertical(at: indexPath,
                                                        itemWidth: itemWidth,
                                                        sectionInset: sectionInset,
                                                        lineSpacing: lineSpacing,
                                                        interitemSpacing: interitemSpacing)
            {
                cache.append(attributes)
            }
        }

        // Footer处理
        let footerIndexPath = IndexPath(item: 0, section: section)
        if let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: footerIndexPath),
           footerAttributes.frame.height > 0
        {
            cache.append(footerAttributes)
            contentHeight = footerAttributes.frame.maxY
        } else {
            contentHeight = (sectionColumnsHeights[safe: section]?.max() ?? contentHeight) + sectionInset.bottom
        }
    }
    
    // MARK: - 水平布局（单行多列横向滚动）
    
    private func prepareSectionLayoutHorizontal(section: Int, collectionView: UICollectionView) {
        let sectionInset = getSectionInset(for: section)
        
        // RTL模式下需要调整处理顺序：Footer -> Items -> Header
        if isRTL {
            // RTL模式：Footer在左边（items之前）
            let footerIndexPath = IndexPath(item: 0, section: section)
            if let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: footerIndexPath),
               footerAttributes.frame.width > 0
            {
                cache.append(footerAttributes)
                contentWidth = footerAttributes.frame.maxX
            } else {
                contentWidth = section == 0 ? 0 : contentWidth + sectionInset.left
            }
            
            // Items处理
            let interitemSpacing = getInteritemSpacing(for: section)
            let availableHeight = collectionView.bounds.height - sectionInset.top - sectionInset.bottom
            guard availableHeight > 0 else {
                print("⚠️ TFYSwiftGridFlowLayout: Item高度计算结果<=0，请检查边距设置，section=\(section)")
                return
            }
            
            let itemHeight = availableHeight
            
            // 初始化行宽度（RTL模式：从Footer结束位置开始）
            if section >= sectionRowWidths.count {
                sectionRowWidths.append([contentWidth + sectionInset.left])
            }
            
            let itemsCount = collectionView.numberOfItems(inSection: section)
            for item in 0 ..< itemsCount {
                let indexPath = IndexPath(item: item, section: section)
                if let attributes = layoutAttributesForItemHorizontal(at: indexPath,
                                                              itemHeight: itemHeight,
                                                              sectionInset: sectionInset,
                                                              interitemSpacing: interitemSpacing)
                {
                    cache.append(attributes)
                }
            }
            
            // Header处理（RTL模式：Header在右边，items之后）
            let headerIndexPath = IndexPath(item: 0, section: section)
            if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: headerIndexPath),
               headerAttributes.frame.width > 0
            {
                cache.append(headerAttributes)
                contentWidth = headerAttributes.frame.maxX
            } else {
                contentWidth = (sectionRowWidths[safe: section]?.first ?? contentWidth) + sectionInset.right
            }
        } else {
            // LTR模式：Header -> Items -> Footer
            let headerIndexPath = IndexPath(item: 0, section: section)
            if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: headerIndexPath),
               headerAttributes.frame.width > 0
            {
                cache.append(headerAttributes)
                contentWidth = headerAttributes.frame.maxX
            }

            let interitemSpacing = getInteritemSpacing(for: section)
            let availableHeight = collectionView.bounds.height - sectionInset.top - sectionInset.bottom
            guard availableHeight > 0 else {
                print("⚠️ TFYSwiftGridFlowLayout: Item高度计算结果<=0，请检查边距设置，section=\(section)")
                return
            }
            
            let itemHeight = availableHeight
            
            // 初始化行宽度（单行模式）
            if section >= sectionRowWidths.count {
                sectionRowWidths.append([contentWidth + sectionInset.left])
            }

            let itemsCount = collectionView.numberOfItems(inSection: section)
            for item in 0 ..< itemsCount {
                let indexPath = IndexPath(item: item, section: section)
                if let attributes = layoutAttributesForItemHorizontal(at: indexPath,
                                                              itemHeight: itemHeight,
                                                              sectionInset: sectionInset,
                                                              interitemSpacing: interitemSpacing)
                {
                    cache.append(attributes)
                }
            }

            // Footer处理（水平布局的Footer显示在右侧）
            let footerIndexPath = IndexPath(item: 0, section: section)
            if let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: footerIndexPath),
               footerAttributes.frame.width > 0
            {
                cache.append(footerAttributes)
                contentWidth = footerAttributes.frame.maxX
            } else {
                contentWidth = (sectionRowWidths[safe: section]?.first ?? contentWidth) + sectionInset.right
            }
        }
    }

    // MARK: - 补充视图布局（支持垂直和水平布局）

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                              at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
            ?? UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)

        guard let collectionView = collectionView else { return attributes }

        let section = indexPath.section
        let sectionInset = getSectionInset(for: section)
        let sectionRowsCount = getRowsCount(for: section)
        
        // 根据布局模式处理
        if sectionRowsCount == 1 {
            // 水平布局模式
            return layoutAttributesForSupplementaryViewHorizontal(attributes: attributes,
                                                                 elementKind: elementKind,
                                                                 section: section,
                                                                 sectionInset: sectionInset,
                                                                 collectionView: collectionView)
        } else {
            // 垂直布局模式
            return layoutAttributesForSupplementaryViewVertical(attributes: attributes,
                                                               elementKind: elementKind,
                                                               section: section,
                                                               sectionInset: sectionInset,
                                                               collectionView: collectionView)
        }
    }
    
    private func layoutAttributesForSupplementaryViewVertical(attributes: UICollectionViewLayoutAttributes,
                                                             elementKind: String,
                                                             section: Int,
                                                             sectionInset: UIEdgeInsets,
                                                             collectionView: UICollectionView) -> UICollectionViewLayoutAttributes?
    {
        var yPosition: CGFloat = 0
        var size: CGSize = .zero

        // 尺寸优先级：1.布局属性设置 2.代理方法 3.默认值
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            size = headerReferenceSize
            if size == .zero {
                size = gridDelegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? .zero
            }
            yPosition = section == 0 ? contentHeight : contentHeight + sectionInset.top

        case UICollectionView.elementKindSectionFooter:
            size = footerReferenceSize
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

        // 垂直布局的Header/Footer通常是全宽的，x坐标始终从左边开始
        // RTL模式下，宽度计算已经考虑了边距，所以x坐标保持sectionInset.left即可
        attributes.frame = CGRect(
            x: sectionInset.left,
            y: yPosition,
            width: validWidth,
            height: validHeight
        )

        // 更新全局内容高度
        if elementKind == UICollectionView.elementKindSectionHeader {
            contentHeight = attributes.frame.maxY
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            contentHeight = attributes.frame.maxY
        }

        return attributes
    }
    
    private func layoutAttributesForSupplementaryViewHorizontal(attributes: UICollectionViewLayoutAttributes,
                                                               elementKind: String,
                                                               section: Int,
                                                               sectionInset: UIEdgeInsets,
                                                               collectionView: UICollectionView) -> UICollectionViewLayoutAttributes?
    {
        var xPosition: CGFloat = 0
        var size: CGSize = .zero

        // 尺寸优先级：1.布局属性设置 2.代理方法 3.默认值
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            size = headerReferenceSize
            if size == .zero {
                size = gridDelegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? .zero
            }
            if isRTL {
                // RTL模式：Header在右边（items之后）
                // 在prepareSectionLayoutHorizontal中，Header在Items之后处理
                let itemsEndX = (sectionRowWidths[safe: section]?.first ?? contentWidth) + sectionInset.right
                xPosition = itemsEndX
            } else {
                // LTR模式：Header在左边（items之前）
                xPosition = section == 0 ? contentWidth : contentWidth + sectionInset.left
            }

        case UICollectionView.elementKindSectionFooter:
            size = footerReferenceSize
            if size == .zero {
                size = gridDelegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? .zero
            }
            if isRTL {
                // RTL模式：Footer在左边（items之前）
                // 在prepareSectionLayoutHorizontal中，Footer在Items之前处理
                xPosition = section == 0 ? 0 : contentWidth + sectionInset.left
            } else {
                // LTR模式：Footer在右边（items之后）
                xPosition = (sectionRowWidths[safe: section]?.first ?? 0) + sectionInset.right
            }

        default:
            return nil
        }

        // 安全尺寸处理
        let safeContentHeight = collectionView.bounds.height - sectionInset.top - sectionInset.bottom
        let validWidth = max(size.width, 0)
        let validHeight = max(safeContentHeight, 0)

        // 仅当有有效尺寸时返回属性
        guard validWidth > 0 && validHeight > 0 else {
            return nil
        }

        attributes.frame = CGRect(
            x: xPosition,
            y: sectionInset.top,
            width: validWidth,
            height: validHeight
        )

        // 更新全局内容宽度
        if elementKind == UICollectionView.elementKindSectionHeader {
            if isRTL {
                // RTL模式：Header在右边，contentWidth增加
                contentWidth = attributes.frame.maxX
            } else {
                // LTR模式：Header在左边，contentWidth增加
                contentWidth = attributes.frame.maxX
            }
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            if isRTL {
                // RTL模式：Footer在左边，contentWidth不变（Footer已经在左边了）
                // 但如果Footer宽度较大，需要更新
                contentWidth = max(contentWidth, attributes.frame.maxX)
            } else {
                // LTR模式：Footer在右边，contentWidth增加
                contentWidth = attributes.frame.maxX
            }
        }

        return attributes
    }

    // MARK: - 单元格布局（垂直）

    private func layoutAttributesForItemVertical(at indexPath: IndexPath,
                                         itemWidth: CGFloat,
                                         sectionInset: UIEdgeInsets,
                                         lineSpacing: CGFloat,
                                         interitemSpacing: CGFloat) -> UICollectionViewLayoutAttributes?
    {
        guard indexPath.section < sectionColumnsHeights.count else { return nil }

        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var columnHeights = sectionColumnsHeights[indexPath.section]
        
        let columnsCount = columnHeights.count
        
        if isEqualHeight {
            // 规则网格布局：按行列顺序排列（item 0, 1, 2 在第一行，3, 4, 5 在第二行...）
            let column = indexPath.item % columnsCount
            let row = indexPath.item / columnsCount
            
            // 计算 item 高度
            let itemHeight = calculateItemHeight(at: indexPath, itemWidth: itemWidth)
            var finalItemHeight = itemHeight
            if let maxHeight = maxItemHeight {
                finalItemHeight = min(itemHeight, maxHeight)
            }
            
            // 计算 x 坐标：RTL模式下需要镜像列顺序
            let x: CGFloat
            if isRTL {
                // RTL模式：从右边开始，列顺序反转
                let rtlColumn = columnsCount - 1 - column
                let availableWidth = (collectionView?.bounds.width ?? 0) - sectionInset.left - sectionInset.right
                x = sectionInset.left + CGFloat(rtlColumn) * (itemWidth + interitemSpacing)
            } else {
                // LTR模式：从左边开始
                x = sectionInset.left + CGFloat(column) * (itemWidth + interitemSpacing)
            }
            
            // 计算 y 坐标：使用初始高度 + 行索引 * (item高度 + 行间距)
            // 使用 columnHeights[0] 作为section的起始高度
            let sectionStartY = sectionColumnsHeights[indexPath.section][0]
            let y = sectionStartY + CGFloat(row) * (finalItemHeight + lineSpacing)
            
            attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: finalItemHeight)
            
            // 只在最后一个item时更新section的结束高度
            let totalItems = collectionView!.numberOfItems(inSection: indexPath.section)
            if indexPath.item == totalItems - 1 {
                let totalRows = Int(ceil(Double(totalItems) / Double(columnsCount)))
                let finalY = sectionStartY + CGFloat(totalRows - 1) * (finalItemHeight + lineSpacing) + finalItemHeight
                // 更新所有列的高度到section结束位置
                for i in 0..<columnsCount {
                    columnHeights[i] = finalY
                }
                sectionColumnsHeights[indexPath.section] = columnHeights
            }
            
        } else {
            // 瀑布流布局：找最短列放置
            guard let minHeight = columnHeights.min(),
                  let minColumn = columnHeights.firstIndex(of: minHeight)
            else {
                return nil
            }

            // RTL模式下需要镜像列索引
            let x: CGFloat
            if isRTL {
                let rtlColumn = columnsCount - 1 - minColumn
                x = sectionInset.left + CGFloat(rtlColumn) * (itemWidth + interitemSpacing)
            } else {
                x = sectionInset.left + CGFloat(minColumn) * (itemWidth + interitemSpacing)
            }
            let y = minHeight

            var itemHeight = calculateItemHeight(at: indexPath, itemWidth: itemWidth)

            // 应用最大高度限制
            if let maxHeight = maxItemHeight {
                itemHeight = min(itemHeight, maxHeight)
            }

            attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            columnHeights[minColumn] = y + itemHeight + lineSpacing
            sectionColumnsHeights[indexPath.section] = columnHeights
        }

        return attributes
    }
    
    // MARK: - 单元格布局（水平）
    
    private func layoutAttributesForItemHorizontal(at indexPath: IndexPath,
                                          itemHeight: CGFloat,
                                          sectionInset: UIEdgeInsets,
                                          interitemSpacing: CGFloat) -> UICollectionViewLayoutAttributes?
    {
        guard indexPath.section < sectionRowWidths.count else { return nil }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var currentWidth = sectionRowWidths[indexPath.section][0]
        
        var itemWidth = calculateItemWidth(at: indexPath, itemHeight: itemHeight)
        
        // 应用最大宽度限制
        if let maxWidth = maxItemWidth {
            itemWidth = min(itemWidth, maxWidth)
        }
        
        let y = sectionInset.top
        
        // RTL模式下需要镜像items的位置
        let x: CGFloat
        if isRTL {
            // RTL模式：从右边开始排列，item 0在最右边
            // 需要先计算当前位置右边的所有items的总宽度
            guard let collectionView = collectionView else { return nil }
            let itemsCount = collectionView.numberOfItems(inSection: indexPath.section)
            
            // 计算当前item右边所有items的总宽度
            var itemsWidthAfter: CGFloat = 0
            for i in (indexPath.item + 1)..<itemsCount {
                let tempIndexPath = IndexPath(item: i, section: indexPath.section)
                var tempWidth = calculateItemWidth(at: tempIndexPath, itemHeight: itemHeight)
                if let maxWidth = maxItemWidth {
                    tempWidth = min(tempWidth, maxWidth)
                }
                itemsWidthAfter += tempWidth + interitemSpacing
            }
            
            // 从右边开始计算：Footer结束位置 + sectionInset.left + 右边items宽度
            // RTL模式下，Footer在左边，items从Footer右边开始排列
            let startX = currentWidth + sectionInset.left
            x = startX + itemsWidthAfter
        } else {
            // LTR模式：从左到右排列
            x = currentWidth
            currentWidth = x + itemWidth + interitemSpacing
            sectionRowWidths[indexPath.section][0] = currentWidth
        }
        
        attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
        
        // RTL模式下需要更新总宽度（使用最右边的item位置）
        if isRTL {
            guard let collectionView = collectionView else { return attributes }
            let itemsCount = collectionView.numberOfItems(inSection: indexPath.section)
            if indexPath.item == 0 {
                // 第一个item（最右边），更新总宽度
                sectionRowWidths[indexPath.section][0] = x + itemWidth + sectionInset.right
            }
        }
        
        return attributes
    }

    private func calculateItemHeight(at indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        guard itemWidth > 0 else {
            print("⚠️ TFYSwiftGridFlowLayout: Item宽度必须大于0，当前值：\(itemWidth)")
            return itemWidth
        }

        guard let collectionView = collectionView else { return itemWidth }
        
        // 优先使用标准的 UICollectionViewDelegateFlowLayout 代理方法返回的高度
        if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
           let delegateSize = flowDelegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return delegateSize.height
        }
        
        // 如果标准代理方法未实现，尝试使用自定义的 gridDelegate
        if let delegateHeight = gridDelegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath).height {
            return delegateHeight
        }
        
        // 如果代理方法未实现，且isEqualHeight=true，则返回正方形（高度=宽度）
        if isEqualHeight {
            return itemWidth
        }
        
        return itemWidth
    }
    
    private func calculateItemWidth(at indexPath: IndexPath, itemHeight: CGFloat) -> CGFloat {
        guard itemHeight > 0 else {
            print("⚠️ TFYSwiftGridFlowLayout: Item高度必须大于0，当前值：\(itemHeight)")
            return itemHeight
        }
        
        guard let collectionView = collectionView else { return itemHeight }
        
        // 优先使用标准的 UICollectionViewDelegateFlowLayout 代理方法返回的宽度
        if let flowDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
           let delegateSize = flowDelegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return delegateSize.width
        }
        
        // 如果标准代理方法未实现，尝试使用自定义的 gridDelegate
        if let delegateSize = gridDelegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return delegateSize.width
        }
        
        // 如果都未实现，返回等高比例（宽度=高度）
        return itemHeight
    }

    // MARK: - 代理方法封装

    private func getColumnsCount(for section: Int) -> Int {
        guard let collectionView = collectionView else { return columnsCount }
        return gridDelegate?.collectionView(collectionView, layout: self, columnsCountForSection: section) ?? columnsCount
    }
    
    private func getRowsCount(for section: Int) -> Int {
        guard let collectionView = collectionView else { return rowsCount }
        return gridDelegate?.collectionView(collectionView, layout: self, rowsCountForSection: section) ?? rowsCount
    }

    private func getSectionInset(for section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView else { return edgeInsets }
        return gridDelegate?.collectionView(collectionView, layout: self, insetForSection: section) ?? edgeInsets
    }

    private func getLineSpacing(for section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return rowSpacing }
        return gridDelegate?.collectionView(collectionView, layout: self, lineSpacingForSection: section) ?? rowSpacing
    }

    private func getInteritemSpacing(for section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return columnSpacing }
        return gridDelegate?.collectionView(collectionView, layout: self, interitemSpacingForSection: section) ?? columnSpacing
    }

    // MARK: - 布局系统重写

    override public var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        // 根据布局模式返回不同的内容大小
        if layoutMode == .horizontal {
            // 水平滚动：宽度为内容宽度，高度为容器高度
            return CGSize(width: contentWidth, height: collectionView.bounds.height)
        } else {
            // 垂直滚动：宽度为容器宽度，高度为内容高度
            return CGSize(width: collectionView.bounds.width, height: contentHeight)
        }
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { rect.intersects($0.frame) }
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath && $0.representedElementCategory == .cell }
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        
        // 根据布局模式判断是否需要重新布局
        if layoutMode == .horizontal {
            // 水平布局：高度变化时需要重新布局
            return newBounds.height != collectionView.bounds.height
        } else {
            // 垂直布局：宽度变化时需要重新布局
            return newBounds.width != collectionView.bounds.width
        }
    }

    // MARK: - 调试支持

    @objc public func debugQuickLookObject() -> AnyObject? {
        var debugInfo = """
        === TFYSwiftGridFlowLayout 调试信息 ===
        布局模式: \(layoutMode == .horizontal ? "水平滚动" : "垂直瀑布流")
        RTL布局: \(isRTL ? "是" : "否")
        列数: \(columnsCount)
        行数: \(rowsCount) (1=单行水平滚动, >1或0=多行垂直滚动)
        行间距: \(rowSpacing)
        列间距: \(columnSpacing)
        边距: \(edgeInsets)
        等高模式: \(isEqualHeight)
        最大高度限制: \(maxItemHeight?.description ?? "无")
        最大宽度限制: \(maxItemWidth?.description ?? "无")
        缓存元素数量: \(cache.count)
        内容高度: \(contentHeight)
        内容宽度: \(contentWidth)
        """

        if let collectionView = collectionView {
            debugInfo += "\n容器尺寸: \(collectionView.bounds.size)"
            debugInfo += "\nSection数量: \(collectionView.numberOfSections)"
        }

        return debugInfo as NSString
    }
    
    /// 打印详细的布局调试信息
    public func printDebugInfo() {
        print(debugQuickLookObject() as? String ?? "无法获取调试信息")
        
        print("\n=== Section详细信息 ===")
        for (index, heights) in sectionColumnsHeights.enumerated() {
            print("Section \(index) - 列高度: \(heights)")
        }
        
        for (index, widths) in sectionRowWidths.enumerated() {
            print("Section \(index) - 行宽度: \(widths)")
        }
        
        print("\n=== 缓存的布局属性 ===")
        for (index, attributes) in cache.enumerated() {
            let kind: String
            if attributes.representedElementCategory == .cell {
                kind = "Cell"
            } else if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                kind = "Header"
            } else if attributes.representedElementKind == UICollectionView.elementKindSectionFooter {
                kind = "Footer"
            } else {
                kind = "Unknown"
            }
            print("[\(index)] \(kind) - IndexPath: \(attributes.indexPath), Frame: \(attributes.frame)")
        }
    }
}

// 安全访问扩展
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
