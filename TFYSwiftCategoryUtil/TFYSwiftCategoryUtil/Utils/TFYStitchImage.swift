//
//  TFYStitchImage.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/7/27.
//  用途：图片拼接工具，支持网格、横向、纵向、瀑布流等多种布局。
//

import UIKit

/// 图片拼接布局类型
public enum TFYStitchLayoutType {
    /// 网格布局（自动计算行列数）
    case grid
    /// 固定列数的网格布局
    case fixedGrid(columns: Int)
    /// 横向布局
    case horizontal
    /// 纵向布局
    case vertical
    /// 瀑布流布局
    case waterfall(columns: Int)
    /// 自定义布局
    case custom(layout: (Int) -> [CGRect])
}

/// 图片拼接配置
public struct TFYStitchConfig {
    /// 图片间距
    public var gap: CGFloat = 4
    /// 背景颜色
    public var backgroundColor: UIColor = .white
    /// 布局类型
    public var layoutType: TFYStitchLayoutType = .grid
    /// 是否保持图片原始比例
    public var keepAspectRatio: Bool = true
    /// 最大图片数量（0表示无限制）
    public var maxImageCount: Int = 0
    /// 圆角大小
    public var cornerRadius: CGFloat = 0
    /// 边距
    public var contentInsets: UIEdgeInsets = .zero
    /// 每页最大数量（分页显示时使用）
    public var itemsPerPage: Int = 0
    
    public init() {}
}

/// 图片拼接工具类
public class TFYStitchImage: NSObject {
    
    // MARK: - 公共方法
    
    /// 拼接图片（支持分页）
    /// - Parameters:
    ///   - images: 待拼接的图片数组
    ///   - size: 最终图片尺寸
    ///   - config: 拼接配置
    /// - Returns: 拼接后的图片数组（如果配置了分页，则返回多张图片）
    public class func stitchImages(
        images: [UIImage],
        size: CGSize,
        config: TFYStitchConfig = TFYStitchConfig()
    ) -> [UIImage] {
        guard !images.isEmpty, size.width > 0, size.height > 0 else {
            return []
        }
        
        // 处理图片数量限制
        let validImages = config.maxImageCount > 0 ? 
            Array(images.prefix(config.maxImageCount)) : images
        if config.maxImageCount > 0 && images.count > config.maxImageCount {
            print("TFYStitchImage: 图片数量超出最大限制，已截断到\(config.maxImageCount)张")
        }
        
        // 是否需要分页
        if config.itemsPerPage > 0 {
            return splitAndStitchImages(
                images: validImages,
                size: size,
                config: config
            )
        } else {
            if let image = stitchImage(
                images: validImages,
                size: size,
                config: config
            ) {
                return [image]
            }
            return []
        }
    }
    
    // MARK: - 私有方法
    
    /// 分页拼接图片
    private class func splitAndStitchImages(
        images: [UIImage],
        size: CGSize,
        config: TFYStitchConfig
    ) -> [UIImage] {
        var result: [UIImage] = []
        
        // 手动分块，避免依赖扩展方法
        let pageSize = config.itemsPerPage
        let totalImages = images.count
        
        for startIndex in stride(from: 0, to: totalImages, by: pageSize) {
            let endIndex = min(startIndex + pageSize, totalImages)
            let chunk = Array(images[startIndex..<endIndex])
            
            if let image = stitchImage(
                images: chunk,
                size: size,
                config: config
            ) {
                result.append(image)
            }
        }
        
        return result
    }
    
    /// 单页拼接图片
    private class func stitchImage(
        images: [UIImage],
        size: CGSize,
        config: TFYStitchConfig
    ) -> UIImage? {
        // 创建图形上下文
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        // 绘制背景
        config.backgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // 获取图片位置
        let frames = getImageFrames(
            images: images,
            size: size,
            config: config
        )
        
        // 绘制图片
        for (index, image) in images.enumerated() {
            guard index < frames.count else { break }
            let frame = frames[index]
            
            if config.cornerRadius > 0 {
                drawImageWithCornerRadius(
                    image,
                    in: frame,
                    cornerRadius: config.cornerRadius
                )
            } else {
                drawImage(
                    image,
                    in: frame,
                    keepAspectRatio: config.keepAspectRatio
                )
            }
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 获取图片位置数组
    private class func getImageFrames(
        images: [UIImage],
        size: CGSize,
        config: TFYStitchConfig
    ) -> [CGRect] {
        // 计算可用区域
        let availableSize = CGSize(
            width: size.width - config.contentInsets.left - config.contentInsets.right,
            height: size.height - config.contentInsets.top - config.contentInsets.bottom
        )
        
        // 根据布局类型计算位置
        var frames = [CGRect]()
        switch config.layoutType {
        case .grid:
            frames = calculateGridLayout(
                count: images.count,
                size: availableSize,
                gap: config.gap
            )
            
        case .fixedGrid(let columns):
            frames = calculateFixedGridLayout(
                count: images.count,
                columns: columns,
                size: availableSize,
                gap: config.gap
            )
            
        case .horizontal:
            frames = calculateHorizontalLayout(
                images: images,
                size: availableSize,
                gap: config.gap,
                keepAspectRatio: config.keepAspectRatio
            )
            
        case .vertical:
            frames = calculateVerticalLayout(
                images: images,
                size: availableSize,
                gap: config.gap,
                keepAspectRatio: config.keepAspectRatio
            )
            
        case .waterfall(let columns):
            frames = calculateWaterfallLayout(
                images: images,
                columns: columns,
                size: availableSize,
                gap: config.gap
            )
            
        case .custom(let layout):
            frames = layout(images.count)
        }
        
        // 应用边距
        return frames.map { frame in
            CGRect(
                x: frame.minX + config.contentInsets.left,
                y: frame.minY + config.contentInsets.top,
                width: frame.width,
                height: frame.height
            )
        }
    }
    
    // MARK: - 私有方法
    
    /// 计算网格布局（自动计算行列数）
    private class func calculateGridLayout(
        count: Int,
        size: CGSize,
        gap: CGFloat
    ) -> [CGRect] {
        // 计算合适的列数
        let columns = Int(ceil(sqrt(Double(count))))
        let rows = Int(ceil(Double(count) / Double(columns)))
        
        // 计算单个item的尺寸
        let itemWidth = (size.width - gap * CGFloat(columns + 1)) / CGFloat(columns)
        let itemHeight = (size.height - gap * CGFloat(rows + 1)) / CGFloat(rows)
        
        var frames: [CGRect] = []
        for index in 0..<count {
            let row = index / columns
            let column = index % columns
            let frame = CGRect(
                x: gap + (itemWidth + gap) * CGFloat(column),
                y: gap + (itemHeight + gap) * CGFloat(row),
                width: itemWidth,
                height: itemHeight
            )
            frames.append(frame)
        }
        return frames
    }
    
    /// 计算横向布局
    private class func calculateHorizontalLayout(
        images: [UIImage],
        size: CGSize,
        gap: CGFloat,
        keepAspectRatio: Bool
    ) -> [CGRect] {
        var frames: [CGRect] = []
        var xOffset: CGFloat = gap
        
        for image in images {
            var itemWidth: CGFloat
            if keepAspectRatio {
                let aspectRatio = image.size.width / image.size.height
                itemWidth = (size.height - 2 * gap) * aspectRatio
            } else {
                itemWidth = (size.width - CGFloat(images.count + 1) * gap) / CGFloat(images.count)
            }
            
            let frame = CGRect(
                x: xOffset,
                y: gap,
                width: itemWidth,
                height: size.height - 2 * gap
            )
            frames.append(frame)
            
            xOffset += itemWidth + gap
        }
        return frames
    }
    
    /// 计算纵向布局
    private class func calculateVerticalLayout(
        images: [UIImage],
        size: CGSize,
        gap: CGFloat,
        keepAspectRatio: Bool
    ) -> [CGRect] {
        var frames: [CGRect] = []
        var yOffset: CGFloat = gap
        
        for image in images {
            var itemHeight: CGFloat
            if keepAspectRatio {
                let aspectRatio = image.size.width / image.size.height
                itemHeight = (size.width - 2 * gap) / aspectRatio
            } else {
                itemHeight = (size.height - CGFloat(images.count + 1) * gap) / CGFloat(images.count)
            }
            
            let frame = CGRect(
                x: gap,
                y: yOffset,
                width: size.width - 2 * gap,
                height: itemHeight
            )
            frames.append(frame)
            
            yOffset += itemHeight + gap
        }
        return frames
    }
    
    /// 计算固定列数的网格布局
    private class func calculateFixedGridLayout(
        count: Int,
        columns: Int,
        size: CGSize,
        gap: CGFloat
    ) -> [CGRect] {
        let rows = Int(ceil(Double(count) / Double(columns)))
        let itemWidth = (size.width - gap * CGFloat(columns + 1)) / CGFloat(columns)
        let itemHeight = (size.height - gap * CGFloat(rows + 1)) / CGFloat(rows)
        
        var frames: [CGRect] = []
        for index in 0..<count {
            let row = index / columns
            let column = index % columns
            let frame = CGRect(
                x: gap + (itemWidth + gap) * CGFloat(column),
                y: gap + (itemHeight + gap) * CGFloat(row),
                width: itemWidth,
                height: itemHeight
            )
            frames.append(frame)
        }
        return frames
    }
    
    /// 计算瀑布流布局
    private class func calculateWaterfallLayout(
        images: [UIImage],
        columns: Int,
        size: CGSize,
        gap: CGFloat
    ) -> [CGRect] {
        let itemWidth = (size.width - gap * CGFloat(columns + 1)) / CGFloat(columns)
        var columnHeights = Array(repeating: gap, count: columns)
        var frames: [CGRect] = []
        
        for image in images {
            // 找到最短的列
            let minHeight = columnHeights.min() ?? gap
            let columnIndex = columnHeights.firstIndex(of: minHeight) ?? 0
            
            // 计算图片高度
            let aspectRatio = image.size.width / image.size.height
            let itemHeight = itemWidth / aspectRatio
            
            // 创建frame
            let frame = CGRect(
                x: gap + (itemWidth + gap) * CGFloat(columnIndex),
                y: minHeight,
                width: itemWidth,
                height: itemHeight
            )
            frames.append(frame)
            
            // 更新列高度
            columnHeights[columnIndex] = frame.maxY + gap
        }
        
        return frames
    }
}

// MARK: - 便利方法
public extension TFYStitchImage {
    
    /// 创建九宫格布局
    class func createNineGrid(
        images: [UIImage],
        size: CGSize,
        gap: CGFloat = 4,
        cornerRadius: CGFloat = 0
    ) -> UIImage? {
        var config = TFYStitchConfig()
        config.layoutType = .fixedGrid(columns: 3)
        config.gap = gap
        config.cornerRadius = cornerRadius
        config.maxImageCount = 9
        
        return stitchImage(
            images: images,
            size: size,
            config: config
        )
    }
    
    /// 创建瀑布流布局
    class func createWaterfall(
        images: [UIImage],
        size: CGSize,
        columns: Int = 2,
        gap: CGFloat = 4
    ) -> UIImage? {
        var config = TFYStitchConfig()
        config.layoutType = .waterfall(columns: columns)
        config.gap = gap
        config.keepAspectRatio = true
        
        return stitchImage(
            images: images,
            size: size,
            config: config
        )
    }
}

// MARK: - 图片绘制方法
private extension TFYStitchImage {
    
    /// 绘制图片
    class func drawImage(
        _ image: UIImage,
        in rect: CGRect,
        keepAspectRatio: Bool
    ) {
        if keepAspectRatio {
            // 计算保持宽高比的绘制区域
            let imageRatio = image.size.width / image.size.height
            let rectRatio = rect.width / rect.height
            
            var drawRect = rect
            if imageRatio > rectRatio {
                // 图片较宽，以宽度为准
                let height = rect.width / imageRatio
                drawRect.origin.y += (rect.height - height) / 2
                drawRect.size.height = height
            } else {
                // 图片较高，以高度为准
                let width = rect.height * imageRatio
                drawRect.origin.x += (rect.width - width) / 2
                drawRect.size.width = width
            }
            image.draw(in: drawRect)
        } else {
            image.draw(in: rect)
        }
    }
    
    /// 绘制带圆角的图片
    class func drawImageWithCornerRadius(
        _ image: UIImage,
        in rect: CGRect,
        cornerRadius: CGFloat
    ) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // 创建圆角路径
        let path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: cornerRadius
        )
        path.addClip()
        
        // 绘制图片
        if image.size.width / image.size.height > rect.width / rect.height {
            // 图片较宽，以高度为准
            let width = rect.height * (image.size.width / image.size.height)
            let x = rect.minX + (rect.width - width) / 2
            image.draw(in: CGRect(x: x, y: rect.minY, width: width, height: rect.height))
        } else {
            // 图片较高，以宽度为准
            let height = rect.width * (image.size.height / image.size.width)
            let y = rect.minY + (rect.height - height) / 2
            image.draw(in: CGRect(x: rect.minX, y: y, width: rect.width, height: height))
        }
        
        context?.restoreGState()
    }
}
