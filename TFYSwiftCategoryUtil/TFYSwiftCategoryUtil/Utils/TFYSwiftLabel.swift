//
//  TFYSwiftLabel.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFY on 2024
//
//  TFYSwiftLabel - 支持多语言点击检测的独立Label类
//
//  功能特性：
//  - 支持多语言文本点击检测（中文、英文、阿拉伯语、泰语、韩语、日语、俄语、法语、德语）
//  - 智能文本匹配算法，支持精确匹配、模糊匹配和部分匹配
//  - 支持RTL（从右到左）语言的正确显示和点击检测
//  - 可自定义点击高亮效果和样式
//  - 提供链式调用API，使用便捷
//  - 内置调试模式，便于开发和测试
//  - 支持富文本样式和颜色设置
//

import UIKit
import CoreText

/// 点击回调类型
public typealias TFYSwiftLabelClickCallback = (String, String?) -> Void

/// 文本匹配策略枚举
public enum TFYSwiftLabelMatchStrategy {
    case exact        // 精确匹配
    case insensitive  // 忽略大小写匹配
    case partial      // 部分匹配
    case smart        // 智能匹配（默认）
}

/// 点击高亮样式枚举
public enum TFYSwiftLabelHighlightStyle {
    case backgroundColor(UIColor)  // 背景色高亮
    case textColor(UIColor)       // 文字颜色高亮
    case underline(UIColor)       // 下划线高亮
    case border(UIColor, CGFloat) // 边框高亮
}

/// 支持多语言点击检测的独立Label类
public class TFYSwiftLabel: UILabel {
    
    // MARK: - 核心属性
    
    /// 可点击文本字典 [文本: 链接]
    private var clickableTexts: [String: String] = [:]
    
    /// 点击回调
    private var clickCallback: TFYSwiftLabelClickCallback?
    
    /// 是否启用点击检测
    public var isClickDetectionEnabled: Bool = true
    
    /// 点击高亮样式
    public var highlightStyle: TFYSwiftLabelHighlightStyle = .backgroundColor(UIColor.systemBlue.withAlphaComponent(0.3))
    
    /// 点击高亮持续时间
    public var clickHighlightDuration: TimeInterval = 0.2
    
    /// 文本匹配策略
    public var matchStrategy: TFYSwiftLabelMatchStrategy = .smart
    
    /// 防止死循环的标志
    private var isUpdatingAttributedText: Bool = false
    
    /// 调试模式 - 是否输出匹配过程
    public var debugMode: Bool = false
    
    /// 富文本属性缓存
    private var cachedAttributedString: NSAttributedString?
    
    /// 文本颜色映射 [文本: 颜色]
    private var textColorMap: [String: UIColor] = [:]
    
    /// 可点击文本的顺序（用于颜色与文本一一对应，保持外部传入顺序）
    private var clickableTextOrder: [String] = []
    
    // MARK: - 初始化
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    private func setupLabel() {
        isUserInteractionEnabled = true
        setupTapGesture()
    }
    
    // MARK: - 公开方法
    
    /// 设置可点击文本
    /// - Parameters:
    ///   - texts: 可点击文本字典 [文本: 链接]
    ///   - callback: 点击回调
    public func setClickableTexts(_ texts: [String: String],textColors:[UIColor], callback: @escaping TFYSwiftLabelClickCallback) {
        clickableTexts = texts
        // 记录外部传入的键顺序
        clickableTextOrder = texts.map { $0.key }
        changeTextLabelColors(textColors)
        clickCallback = callback
    }
    
    /// 清除所有可点击文本
    public func clearClickableTexts() {
        clickableTexts.removeAll()
        clickCallback = nil
        text = text // 重置为普通文本
    }
    
    /// 设置点击高亮样式
    /// - Parameters:
    ///   - color: 高亮颜色
    ///   - duration: 高亮持续时间
    public func setClickHighlight(color: UIColor, duration: TimeInterval = 0.2) {
        highlightStyle = .backgroundColor(color)
        clickHighlightDuration = duration
    }
    
    /// 设置点击高亮样式
    /// - Parameters:
    ///   - style: 高亮样式
    ///   - duration: 高亮持续时间
    public func setClickHighlight(style: TFYSwiftLabelHighlightStyle, duration: TimeInterval = 0.2) {
        highlightStyle = style
        clickHighlightDuration = duration
    }
    
    /// 设置文本颜色 - 为可点击文本设置颜色
    /// - Parameter colors: 颜色数组
    private func changeTextLabelColors(_ colors: [UIColor]) {
        // 清除之前的颜色映射
        textColorMap.removeAll()
        
        // 获取可点击文本的键数组（保持外部传入顺序）
        let clickableTextKeys = clickableTextOrder.isEmpty ? Array(clickableTexts.keys) : clickableTextOrder
        
        // 如果可点击文本为空，直接返回
        guard !clickableTextKeys.isEmpty else {
            updateAttributedText()
            return
        }
        
        // 检查当前显示文本
        guard let currentText = text, !currentText.isEmpty else {
            updateAttributedText()
            return
        }
        
        // 如果没有有效的可点击文本，直接返回
        guard !clickableTextKeys.isEmpty else {
            updateAttributedText()
            return
        }
        
        // 根据颜色数量进行不同的处理（严格按照顺序一一对应）
        if colors.count == 1 {
            // 如果只有一个颜色，所有可点击文本都使用这个颜色
            let singleColor = colors[0]
            for textKey in clickableTextKeys {
                textColorMap[textKey] = singleColor
            }
        } else if colors.count > 1 {
            // 如果有多个颜色，按顺序一一对应
            // 取颜色数量和可点击文本数量的较小值
            let pairCount = min(colors.count, clickableTextKeys.count)
            
            for index in 0..<pairCount {
                let textKey = clickableTextKeys[index]
                let color = colors[index]
                textColorMap[textKey] = color
            }
        }
        
        // 更新富文本
        updateAttributedText()
    }
    
    /// 清除所有文本颜色设置
    private func clearTextLabelColors() {
        textColorMap.removeAll()
        updateAttributedText()
    }
    
    /// 更新富文本
    private func updateAttributedText() {
        guard let text = text, !text.isEmpty else { return }
        
        isUpdatingAttributedText = true
        
        let attributedString = NSMutableAttributedString(string: text)
        
        // 设置基础属性
        let range = NSRange(location: 0, length: text.count)
        attributedString.addAttribute(.font, value: font ?? UIFont.systemFont(ofSize: 16), range: range)
        attributedString.addAttribute(.foregroundColor, value: textColor ?? .label, range: range)
        
        // 应用文本颜色 - 只对精确匹配的文本设置颜色，并按外部顺序应用
        let orderedKeys = clickableTextOrder.isEmpty ? Array(textColorMap.keys) : clickableTextOrder
        for searchText in orderedKeys {
            guard let color = textColorMap[searchText] else { continue }
            let ranges = findExactTextRanges(searchText, in: text)
            for range in ranges {
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        
        attributedText = attributedString
        cachedAttributedString = attributedString
        
        isUpdatingAttributedText = false
    }
    
    /// 查找文本在字符串中的所有范围
    /// - Parameters:
    ///   - searchText: 搜索文本
    ///   - fullText: 完整文本
    /// - Returns: 所有匹配的范围数组
    private func findTextRanges(_ searchText: String, in fullText: String) -> [NSRange] {
        var ranges: [NSRange] = []
        var searchRange = NSRange(location: 0, length: fullText.count)
        
        while searchRange.location < fullText.count {
            let range = findTextRangeInString(searchText, in: fullText, searchRange: searchRange)
            if range.location != NSNotFound {
                ranges.append(range)
                searchRange.location = range.location + range.length
                searchRange.length = fullText.count - searchRange.location
            } else {
                break
            }
        }
        
        return ranges
    }
    
    /// 查找文本在字符串中的所有范围 - 精确匹配版本
    /// - Parameters:
    ///   - searchText: 搜索文本
    ///   - fullText: 完整文本
    /// - Returns: 所有精确匹配的范围数组
    private func findExactTextRanges(_ searchText: String, in fullText: String) -> [NSRange] {
        var ranges: [NSRange] = []
        var searchRange = NSRange(location: 0, length: fullText.count)
        
        while searchRange.location < fullText.count {
            // 使用精确匹配，不使用智能匹配策略
            let range = (fullText as NSString).range(of: searchText, options: [], range: searchRange)
            if range.location != NSNotFound {
                ranges.append(range)
                searchRange.location = range.location + range.length
                searchRange.length = fullText.count - searchRange.location
            } else {
                break
            }
        }
        
        return ranges
    }
    
    // MARK: - 私有方法
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard isClickDetectionEnabled, !clickableTexts.isEmpty else { 
            if debugMode {
                print("❌ 点击检测未启用或没有可点击文本")
            }
            return 
        }
        
        let location = gesture.location(in: self)
        if debugMode {
            print("👆 点击位置: \(location)")
            print("📋 可点击文本: \(Array(clickableTexts.keys))")
        }
        
        // 在主线程执行点击检测
        if let (clickedText, link) = detectClickedText(at: location) {
            if debugMode {
                print("✅ 检测到点击: '\(clickedText)' -> '\(link ?? "无链接")'")
            }
            showClickHighlight(at: location)
            clickCallback?(clickedText, link)
        } else {
            if debugMode {
                print("❌ 未检测到有效点击")
            }
        }
    }
    
    private func detectClickedText(at location: CGPoint) -> (String, String?)? {
        guard let text = text, !text.isEmpty else { return nil }
        
        // 检查点击位置是否在标签范围内
        guard bounds.contains(location) else {
        if debugMode {
                print("❌ 点击位置超出标签范围")
            }
            return nil
        }
        
        // 使用缓存的富文本或创建新的
        let attributedText: NSAttributedString
        if let cached = cachedAttributedString {
            attributedText = cached
        } else {
            let mutableAttributedText = NSMutableAttributedString(string: text)
            mutableAttributedText.addAttribute(.font, value: font ?? UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: text.count))
            attributedText = mutableAttributedText
        }
        
        // 创建文本布局管理器
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        // 配置布局
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // 配置文本容器
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        // 强制布局计算
        textContainer.size = bounds.size
        layoutManager.ensureLayout(for: textContainer)
        
        // 计算点击位置的字符索引
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // 确保字符索引在有效范围内
        let safeCharacterIndex = min(max(characterIndex, 0), text.count - 1)
        
        if debugMode {
            print("📍 点击位置: \(location)")
            print("📏 Label bounds: \(bounds)")
            print("📦 文本容器大小: \(textContainer.size)")
            print("🔢 原始字符索引: \(characterIndex)")
            print("🔢 安全字符索引: \(safeCharacterIndex)")
            print("📝 文本总长度: \(text.count)")
            
            // 检查文本容器的行数
            let glyphRange = layoutManager.glyphRange(for: textContainer)
            print("🔤 字形范围: \(glyphRange)")
            
            // 检查点击位置是否在有效范围内
            if characterIndex != NSNotFound {
                let textRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: min(characterIndex, text.count)), in: textContainer)
                print("📐 文本矩形: \(textRect)")
            }
        }
        
        if characterIndex != NSNotFound {
            // 检查点击位置是否在可点击文本范围内
            for (clickableText, link) in clickableTexts {
                let range = findTextRangeInString(clickableText, in: text)
                if debugMode {
                    print("🔍 检查文本: '\(clickableText)'")
                    print("📊 匹配范围: \(range)")
                    print("🎯 原始字符索引在范围内: \(NSLocationInRange(characterIndex, range))")
                    print("🎯 安全字符索引在范围内: \(NSLocationInRange(safeCharacterIndex, range))")
                }
                
                if range.location != NSNotFound && (NSLocationInRange(characterIndex, range) || NSLocationInRange(safeCharacterIndex, range)) {
                    if debugMode {
                        print("✅ 找到匹配的点击文本: '\(clickableText)'")
                    }
                    return (clickableText, link)
                }
            }
        } else {
            if debugMode {
                print("❌ 无法计算字符索引")
            }
        }
        
        return nil
    }
    
    private func findTextRangeInString(_ searchText: String, in fullText: String, searchRange: NSRange = NSRange(location: 0, length: 0)) -> NSRange {
        let actualSearchRange = searchRange.length == 0 ? NSRange(location: 0, length: fullText.count) : searchRange
        
        if debugMode {
            print("🔍 TFYSwiftLabel 搜索: '\(searchText)'")
            print("📝 在文本中: '\(fullText.prefix(100))...'")
            print("🎯 搜索范围: \(actualSearchRange)")
        }
        
        // 根据匹配策略选择不同的匹配方式
        switch matchStrategy {
        case .exact:
            return findExactMatch(searchText: searchText, in: fullText, searchRange: actualSearchRange)
        case .insensitive:
            return findInsensitiveMatch(searchText: searchText, in: fullText, searchRange: actualSearchRange)
        case .partial:
            return findPartialMatch(searchText: searchText, in: fullText, searchRange: actualSearchRange)
        case .smart:
            return findSmartMatch(searchText: searchText, in: fullText, searchRange: actualSearchRange)
        }
    }
    
    /// 精确匹配
    private func findExactMatch(searchText: String, in fullText: String, searchRange: NSRange) -> NSRange {
        let range = (fullText as NSString).range(of: searchText, options: [], range: searchRange)
        if debugMode && range.location != NSNotFound {
            print("✅ 精确匹配成功: 位置 \(range.location), 长度 \(range.length)")
        }
        return range
    }
    
    /// 忽略大小写匹配
    private func findInsensitiveMatch(searchText: String, in fullText: String, searchRange: NSRange) -> NSRange {
        let searchOptions: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]
        let range = (fullText as NSString).range(of: searchText, options: searchOptions, range: searchRange)
        if debugMode && range.location != NSNotFound {
            print("✅ 忽略大小写匹配成功: 位置 \(range.location), 长度 \(range.length)")
        }
        return range
    }
    
    /// 部分匹配
    private func findPartialMatch(searchText: String, in fullText: String, searchRange: NSRange) -> NSRange {
        let partialOptions: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]
        
        // 尝试匹配搜索文本的主要部分（去除空格）
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearchText.isEmpty {
            let range = (fullText as NSString).range(of: trimmedSearchText, options: partialOptions, range: searchRange)
            if range.location != NSNotFound {
        if debugMode {
                    print("✅ 部分匹配成功: 位置 \(range.location), 长度 \(range.length)")
                }
                return range
            }
        }
        
        return NSRange(location: NSNotFound, length: 0)
    }
    
    /// 智能匹配
    private func findSmartMatch(searchText: String, in fullText: String, searchRange: NSRange) -> NSRange {
        // 1. 首先尝试精确匹配
        let exactRange = findExactMatch(searchText: searchText, in: fullText, searchRange: searchRange)
        if exactRange.location != NSNotFound {
            return exactRange
        }
        
        // 2. 尝试忽略大小写和变音符号的匹配
        let insensitiveRange = findInsensitiveMatch(searchText: searchText, in: fullText, searchRange: searchRange)
        if insensitiveRange.location != NSNotFound {
            return insensitiveRange
        }
        
        // 3. 对于阿拉伯语等RTL语言，尝试反向搜索
        let reverseOptions: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .widthInsensitive, .backwards]
        let reverseRange = (fullText as NSString).range(of: searchText, options: reverseOptions, range: searchRange)
        if reverseRange.location != NSNotFound {
            if debugMode {
                print("✅ 反向搜索匹配成功: 位置 \(reverseRange.location), 长度 \(reverseRange.length)")
            }
            return reverseRange
        }
        
        // 4. 智能部分匹配 - 处理复杂语言
        let partialResult = findAdvancedPartialMatch(searchText: searchText, in: fullText, searchRange: searchRange)
        if debugMode {
            if partialResult.location != NSNotFound {
                print("✅ 智能部分匹配成功: 位置 \(partialResult.location), 长度 \(partialResult.length)")
            } else {
                print("❌ 所有匹配方式都失败")
            }
        }
        return partialResult
    }
    
    /// 高级智能部分匹配算法，支持多语言
    private func findAdvancedPartialMatch(searchText: String, in fullText: String, searchRange: NSRange) -> NSRange {
        let partialOptions: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]
        
        // 1. 尝试匹配搜索文本的主要部分（去除空格）
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearchText.isEmpty {
            let trimmedRange = (fullText as NSString).range(of: trimmedSearchText, options: partialOptions, range: searchRange)
            if trimmedRange.location != NSNotFound {
                return trimmedRange
            }
        }
        
        // 2. 按单词分割进行智能匹配
        let words = searchText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        // 如果只有一个词，直接匹配
        if words.count == 1 {
            let word = words[0]
            if word.count > 1 { // 至少2个字符
                let wordRange = (fullText as NSString).range(of: word, options: partialOptions, range: searchRange)
                if wordRange.location != NSNotFound {
                    return wordRange
                }
            }
            return NSRange(location: NSNotFound, length: 0)
        }
        
        // 3. 多词匹配 - 寻找最长的连续匹配
        var bestMatch = NSRange(location: NSNotFound, length: 0)
        var maxMatchedWords = 0
        
        for i in 0..<words.count {
            let word = words[i]
            if word.count <= 1 { continue } // 跳过单字符词
            
            let wordRange = (fullText as NSString).range(of: word, options: partialOptions, range: searchRange)
            if wordRange.location != NSNotFound {
                // 检查后续词是否也匹配（连续匹配）
                var matchedWords = 1
                var currentRange = wordRange
                
                for j in (i+1)..<words.count {
                    let nextWord = words[j]
                    if nextWord.count <= 1 { continue }
                    
                    // 在当前位置附近查找下一个词
                    let searchStart = currentRange.location + currentRange.length
                    let remainingText = (fullText as NSString).substring(from: searchStart)
                    let nextWordRange = (remainingText as NSString).range(of: nextWord, options: partialOptions)
                    
                    if nextWordRange.location != NSNotFound {
                        // 检查是否在合理距离内（避免跨段落匹配）
                        let actualLocation = searchStart + nextWordRange.location
                        let distance = actualLocation - (currentRange.location + currentRange.length)
                        
                        if distance <= 50 { // 在50个字符内认为是连续的
                            matchedWords += 1
                            currentRange = NSRange(location: currentRange.location, 
                                                length: actualLocation + nextWordRange.length - currentRange.location)
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
                
                // 如果找到更长的匹配，更新最佳匹配
                if matchedWords > maxMatchedWords {
                    maxMatchedWords = matchedWords
                    bestMatch = currentRange
                }
            }
        }
        
        // 4. 如果找到了至少2个词的匹配，返回结果
        if maxMatchedWords >= 2 {
            return bestMatch
        }
        
        // 5. 最后尝试：匹配最重要的词（通常是第一个或最长的词）
        let importantWords = words.sorted { $0.count > $1.count }
        for word in importantWords {
            if word.count > 2 {
                let wordRange = (fullText as NSString).range(of: word, options: partialOptions, range: searchRange)
                if wordRange.location != NSNotFound {
                    return wordRange
                }
            }
        }
        
        return NSRange(location: NSNotFound, length: 0)
    }
    
    private func showClickHighlight(at location: CGPoint) {
        // 检测被点击的具体文字
        guard let (clickedText, _) = detectClickedText(at: location) else { return }
        
        // 根据高亮样式显示不同的高亮效果
        switch highlightStyle {
        case .backgroundColor(let color):
            showTextBackgroundHighlight(for: clickedText, color: color)
        case .textColor(let color):
            showTextColorHighlight(for: clickedText, color: color)
        case .underline(let color):
            showTextUnderlineHighlight(for: clickedText, color: color)
        case .border(let color, let width):
            showTextBorderHighlight(for: clickedText, color: color, width: width)
        }
    }
    
    /// 文字背景色高亮 - 只高亮被点击的文字部分
    private func showTextBackgroundHighlight(for clickedText: String, color: UIColor) {
        guard let text = text, !text.isEmpty else { return }
        
        // 创建富文本
        let attributedString = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(string: text))
        
        // 找到被点击文字的所有位置 - 使用精确匹配
        let ranges = findExactTextRanges(clickedText, in: text)
        
        // 保存原始背景色
        var originalBackgroundColors: [NSRange: UIColor] = [:]
        
        // 应用高亮背景色
        for range in ranges {
            // 保存原始背景色
            if let originalColor = attributedString.attribute(.backgroundColor, at: range.location, effectiveRange: nil) as? UIColor {
                originalBackgroundColors[range] = originalColor
            }
            
            // 设置高亮背景色
            attributedString.addAttribute(.backgroundColor, value: color, range: range)
        }
        
        // 更新显示
        attributedText = attributedString
        
        // 延迟恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + clickHighlightDuration) { [weak self] in
            guard let self = self else { return }
            
            // 恢复原始背景色
            for range in ranges {
                if let originalColor = originalBackgroundColors[range] {
                    attributedString.addAttribute(.backgroundColor, value: originalColor, range: range)
                } else {
                    attributedString.removeAttribute(.backgroundColor, range: range)
                }
            }
            
            self.attributedText = attributedString
        }
    }
    
    /// 文字颜色高亮 - 只高亮被点击的文字部分
    private func showTextColorHighlight(for clickedText: String, color: UIColor) {
        guard let text = text, !text.isEmpty else { return }
        
        // 创建富文本
        let attributedString = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(string: text))
        
        // 找到被点击文字的所有位置 - 使用精确匹配
        let ranges = findExactTextRanges(clickedText, in: text)
        
        // 保存原始文字颜色
        var originalTextColors: [NSRange: UIColor] = [:]
        
        // 应用高亮文字颜色
        for range in ranges {
            // 保存原始文字颜色
            if let originalColor = attributedString.attribute(.foregroundColor, at: range.location, effectiveRange: nil) as? UIColor {
                originalTextColors[range] = originalColor
            }
            
            // 设置高亮文字颜色
            attributedString.addAttribute(.foregroundColor, value: color, range: range)
        }
        
        // 更新显示
        attributedText = attributedString
        
        // 延迟恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + clickHighlightDuration) { [weak self] in
            guard let self = self else { return }
            
            // 恢复原始文字颜色
            for range in ranges {
                if let originalColor = originalTextColors[range] {
                    attributedString.addAttribute(.foregroundColor, value: originalColor, range: range)
                } else {
                    attributedString.addAttribute(.foregroundColor, value: self.textColor ?? .label, range: range)
                }
            }
            
            self.attributedText = attributedString
        }
    }
    
    /// 文字下划线高亮 - 只高亮被点击的文字部分
    private func showTextUnderlineHighlight(for clickedText: String, color: UIColor) {
        guard let text = text, !text.isEmpty else { return }
        
        // 创建富文本
        let attributedString = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(string: text))
        
        // 找到被点击文字的所有位置 - 使用精确匹配
        let ranges = findExactTextRanges(clickedText, in: text)
        
        // 保存原始下划线样式
        var originalUnderlineStyles: [NSRange: Any] = [:]
        var originalUnderlineColors: [NSRange: UIColor] = [:]
        
        // 应用下划线高亮
        for range in ranges {
            // 保存原始下划线样式
            if let originalStyle = attributedString.attribute(.underlineStyle, at: range.location, effectiveRange: nil) {
                originalUnderlineStyles[range] = originalStyle
            }
            if let originalColor = attributedString.attribute(.underlineColor, at: range.location, effectiveRange: nil) as? UIColor {
                originalUnderlineColors[range] = originalColor
            }
            
            // 设置下划线高亮
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: range)
            attributedString.addAttribute(.underlineColor, value: color, range: range)
        }
        
        // 更新显示
        attributedText = attributedString
        
        // 延迟恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + clickHighlightDuration) { [weak self] in
            guard let self = self else { return }
            
            // 恢复原始下划线样式
            for range in ranges {
                if let originalStyle = originalUnderlineStyles[range] {
                    attributedString.addAttribute(.underlineStyle, value: originalStyle, range: range)
                } else {
                    attributedString.removeAttribute(.underlineStyle, range: range)
                }
                
                if let originalColor = originalUnderlineColors[range] {
                    attributedString.addAttribute(.underlineColor, value: originalColor, range: range)
                } else {
                    attributedString.removeAttribute(.underlineColor, range: range)
                }
            }
            
            self.attributedText = attributedString
        }
    }
    
    /// 文字边框高亮 - 只高亮被点击的文字部分
    private func showTextBorderHighlight(for clickedText: String, color: UIColor, width: CGFloat) {
        guard let text = text, !text.isEmpty else { return }
        
        // 创建富文本
        let attributedString = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString(string: text))
        
        // 找到被点击文字的所有位置 - 使用精确匹配
        let ranges = findExactTextRanges(clickedText, in: text)
        
        // 保存原始描边样式
        var originalStrokeColors: [NSRange: UIColor] = [:]
        var originalStrokeWidths: [NSRange: NSNumber] = [:]
        
        // 应用描边高亮
        for range in ranges {
            // 保存原始描边样式
            if let originalColor = attributedString.attribute(.strokeColor, at: range.location, effectiveRange: nil) as? UIColor {
                originalStrokeColors[range] = originalColor
            }
            if let originalWidth = attributedString.attribute(.strokeWidth, at: range.location, effectiveRange: nil) as? NSNumber {
                originalStrokeWidths[range] = originalWidth
            }
            
            // 设置描边高亮
            attributedString.addAttribute(.strokeColor, value: color, range: range)
            attributedString.addAttribute(.strokeWidth, value: width, range: range)
        }
        
        // 更新显示
        attributedText = attributedString
        
        // 延迟恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + clickHighlightDuration) { [weak self] in
            guard let self = self else { return }
            
            // 恢复原始描边样式
            for range in ranges {
                if let originalColor = originalStrokeColors[range] {
                    attributedString.addAttribute(.strokeColor, value: originalColor, range: range)
                } else {
                    attributedString.removeAttribute(.strokeColor, range: range)
                }
                
                if let originalWidth = originalStrokeWidths[range] {
                    attributedString.addAttribute(.strokeWidth, value: originalWidth, range: range)
                } else {
                    attributedString.removeAttribute(.strokeWidth, range: range)
                }
            }
            
            self.attributedText = attributedString
        }
    }
}

// MARK: - 便捷方法扩展

public extension TFYSwiftLabel {
    
    /// 便捷设置方法 - 链式调用
    @discardableResult
    func clickableTexts(_ texts: [String: String],textColors:[UIColor], callback: @escaping TFYSwiftLabelClickCallback) -> Self {
        setClickableTexts(texts,textColors: textColors, callback: callback)
        return self
    }
    
    /// 便捷设置方法 - 启用点击检测
    @discardableResult
    func enableClickDetection(_ enabled: Bool = true) -> Self {
        isClickDetectionEnabled = enabled
        return self
    }
    
    /// 便捷设置方法 - 点击高亮样式（颜色）
    @discardableResult
    func clickHighlight(color: UIColor, duration: TimeInterval = 0.2) -> Self {
        setClickHighlight(color: color, duration: duration)
        return self
    }
    
    /// 便捷设置方法 - 点击高亮样式（样式）
    @discardableResult
    func clickHighlight(style: TFYSwiftLabelHighlightStyle, duration: TimeInterval = 0.2) -> Self {
        setClickHighlight(style: style, duration: duration)
        return self
    }
    
    /// 便捷设置方法 - 调试模式
    @discardableResult
    func debugMode(_ enabled: Bool = true) -> Self {
        debugMode = enabled
        return self
    }
    
    /// 便捷设置方法 - 匹配策略
    @discardableResult
    func matchStrategy(_ strategy: TFYSwiftLabelMatchStrategy) -> Self {
        matchStrategy = strategy
        return self
    }
    
    /// 便捷设置方法 - 清除所有可点击文本
    @discardableResult
    func clearClickableTexts() -> Self {
        clearTextLabelColors()
        return self
    }
    
    /// 便捷设置方法 - 重置所有设置
    @discardableResult
    func reset() -> Self {
        clearTextLabelColors()
        isClickDetectionEnabled = true
        highlightStyle = .backgroundColor(UIColor.systemBlue.withAlphaComponent(0.3))
        clickHighlightDuration = 0.2
        matchStrategy = .smart
        debugMode = false
        return self
    }
}

