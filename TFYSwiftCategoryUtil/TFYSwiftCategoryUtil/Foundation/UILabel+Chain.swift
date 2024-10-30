//
//  UILabel+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UILabel {

    @discardableResult
    func numberOfLines(_ numberOfLines: Int) -> TFY {
        base.numberOfLines = numberOfLines
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> TFY {
        base.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
    
    @discardableResult
    func sizeThatFits(size:CGSize) -> CGSize {
        let sizes:CGSize = base.sizeThatFits(size)
        return sizes
    }
}

public extension TFY where Base: UILabel {
    /// 改变字段间距
    func changeFontWithTextFont(font:UIFont) {
        self.changeFontWithTextFont(font: font, text: base.text ?? "")
    }
    /// 改变行间距
    func changeFontWithTextFont(font:UIFont,text:String) {
        self.attributedString(value: font, text: text, name: NSAttributedString.Key.font)
    }
    
    /// 改变行间距
    func changeSpaceWithTextSpace(textSpace:CGFloat) {
        self.changeSpaceWithTextSpace(textSpace: textSpace, text: base.text ?? "")
    }
    /// 改变行间距
    func changeSpaceWithTextSpace(textSpace:CGFloat,text:String) {
        self.attributedString(value: textSpace, text: text, name: NSAttributedString.Key.kern)
    }
    
    /// 改变行间距
    func changeLineSpaceWithTextLineSpace(textLineSpace:CGFloat) {
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = textLineSpace
        paragraphStyle.alignment = base.textAlignment
        self.changeParagraphStyleWithTextParagraphStyle(paragraphStyle: paragraphStyle)
    }

    /// 段落样式
    func changeParagraphStyleWithTextParagraphStyle(paragraphStyle:NSParagraphStyle) {
        let att:NSAttributedString = NSAttributedString(string: "")
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: base.attributedText ?? att)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, NSString(string: base.text ?? "").length))
        base.attributedText = attributedString
    }
    
    /// 改变字段颜色
    func changeColorWithTextColor(textColor:UIColor) {
        self.changeColorWithTextColor(textColor: textColor, text: base.text ?? "")
    }
    
    /// 改变字段颜色
    func changeColorWithTextColor(textColor:UIColor,text:String) {
        self.changeColorWithTextColor(textColor: textColor, texts: [text])
    }
    
    /// 改变字段颜色
    func changeColorWithTextColor(textColor:UIColor,texts:[String]) {
        let attributedString = NSMutableAttributedString(string: base.text ?? "")
        texts.forEach { textStr in
            let range = ((base.text ?? "") as NSString).range(of: textStr)
            attributedString.addAttribute(.foregroundColor, value: textColor, range: range)
        }
        base.attributedText = attributedString
    }
    
    /// 改变不同字段颜色
    func changeColorWithTextColors(textColors:[UIColor],texts:[String]) {
        if textColors.count == texts.count {
            let attributedString = NSMutableAttributedString(string: base.text ?? "")
            for (index,color) in textColors.enumerated() {
                let range = ((base.text ?? "") as NSString).range(of: texts[index])
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
            base.attributedText = attributedString
        }
    }
    
    /// 改变字段背景颜色
    func changeBgColorWithBgTextColor(bgTextColor:UIColor) {
        self.changeBgColorWithBgTextColor(bgTextColor: bgTextColor,text: base.text ?? "")
    }
    
    /// 改变字段背景颜色
    func changeBgColorWithBgTextColor(bgTextColor:UIColor,text:String) {
        self.attributedString(value: bgTextColor, text: text, name: NSAttributedString.Key.backgroundColor)
    }
    
    /// 改变字段连笔字 value值为1或者0
    func changeLigatureWithTextLigature(textLigature:NSNumber) {
        self.changeLigatureWithTextLigature(textLigature: textLigature, text: base.text ?? "")
    }
    
    /// 改变字段连笔字 value值为1或者0
    func changeLigatureWithTextLigature(textLigature:NSNumber,text:String) {
        self.attributedString(value: textLigature, text: text, name: NSAttributedString.Key.ligature)
    }
    
    /// 改变字间距
    func changeKernWithTextKern(textKern:NSNumber) {
        self.changeKernWithTextKern(textKern: textKern, text: base.text ?? "")
    }
    
    /// 改变字间距
    func changeKernWithTextKern(textKern:NSNumber,text:String) {
        self.attributedString(value: textKern, text: text, name: NSAttributedString.Key.kern)
    }
    
    /// 改变字的删除线
    func changeStrikethroughStyleWithTextStrikethroughStyle(textStrikethroughStyle:NSNumber) {
        self.changeStrikethroughStyleWithTextStrikethroughStyle(textStrikethroughStyle: textStrikethroughStyle, text: base.text ?? "")
    }
    
    /// 改变字的删除线
    func changeStrikethroughStyleWithTextStrikethroughStyle(textStrikethroughStyle:NSNumber,text:String) {
        self.attributedString(value: textStrikethroughStyle, text: text, name: NSAttributedString.Key.strikethroughStyle)
    }
    
    /// 改变字的删除线颜色
    func changeStrikethroughColorWithTextStrikethroughColor(textStrikethroughColor:UIColor) {
        self.changeStrikethroughColorWithTextStrikethroughColor(textStrikethroughColor: textStrikethroughColor, text: base.text ?? "")
    }
    
    /// 改变字的删除线颜色
    func changeStrikethroughColorWithTextStrikethroughColor(textStrikethroughColor:UIColor,text:String) {
        self.attributedString(value: textStrikethroughColor, text: text, name: NSAttributedString.Key.strikethroughColor)
    }
    
    /// 改变字的下划线
    func changeUnderlineStyleWithTextStrikethroughStyle(textUnderlineStyle:NSNumber) {
        self.changeUnderlineStyleWithTextStrikethroughStyle(textUnderlineStyle: textUnderlineStyle, text: base.text ?? "")
    }
    
    /// 改变字的下划线
    func changeUnderlineStyleWithTextStrikethroughStyle(textUnderlineStyle:NSNumber,text:String) {
        self.attributedString(value: textUnderlineStyle, text: text, name: NSAttributedString.Key.underlineStyle)
    }
    
    /// 改变字的下划线颜色
    func changeUnderlineColorWithTextStrikethroughColor(textUnderlineColor:UIColor) {
        self.changeUnderlineColorWithTextStrikethroughColor(textUnderlineColor: textUnderlineColor, text: base.text ?? "")
    }
    
    /// 改变字的下划线颜色
    func changeUnderlineColorWithTextStrikethroughColor(textUnderlineColor:UIColor,text:String) {
        self.attributedString(value: textUnderlineColor, text: text, name: NSAttributedString.Key.underlineColor)
    }
    
    /// 改变字的颜色
    func changeStrokeColorWithTextStrikethroughColor(textStrokeColor:UIColor) {
        self.changeStrokeColorWithTextStrikethroughColor(textStrokeColor: textStrokeColor, text: base.text ?? "")
    }
    
    /// 改变字的颜色
    func changeStrokeColorWithTextStrikethroughColor(textStrokeColor:UIColor,text:String) {
        self.attributedString(value: textStrokeColor, text: text, name: NSAttributedString.Key.strokeColor)
    }
    
    /// 改变字的描边
    func changeStrokeWidthWithTextStrikethroughWidth(textStrokeWidth:NSNumber) {
        self.changeStrokeWidthWithTextStrikethroughWidth(textStrokeWidth: textStrokeWidth, text: base.text ?? "")
    }
    
    /// 改变字的描边
    func changeStrokeWidthWithTextStrikethroughWidth(textStrokeWidth:NSNumber,text:String) {
        self.attributedString(value: textStrokeWidth, text: text, name: NSAttributedString.Key.strokeWidth)
    }
    
    
    /// 改变字的阴影
    func changeShadowWithTextShadow(textShadow:NSShadow) {
        self.changeShadowWithTextShadow(textShadow: textShadow, text: base.text ?? "")
    }
    
    /// 改变字的阴影
    func changeShadowWithTextShadow(textShadow:NSShadow,text:String) {
        self.attributedString(value: textShadow, text: text, name: NSAttributedString.Key.shadow)
    }
    
    /// 改变字的特殊效果
    func changeTextEffectWithTextEffect(textEffect:String) {
        self.changeTextEffectWithTextEffect(textEffect: textEffect, text: base.text ?? "")
    }
    
    
    /// 改变字的特殊效果
    func changeTextEffectWithTextEffect(textEffect:String,text:String) {
        self.attributedString(value: textEffect, text: text, name: NSAttributedString.Key.textEffect)
    }
    
    /// 改变字的文本附件
    func changeAttachmentWithTextAttachment(textAttachment:NSTextAttachment) {
        self.changeAttachmentWithTextAttachment(textAttachment: textAttachment, text: base.text ?? "")
    }
    
    /// 改变字的文本附件
    func changeAttachmentWithTextAttachment(textAttachment:NSTextAttachment,text:String) {
        self.attributedString(value: textAttachment, text: text, name: NSAttributedString.Key.attachment)
    }
    
    /// 改变字的链接
    func changeLinkWithTextLink(textLink:String) {
        self.changeLinkWithTextLink(textLink: textLink, text: base.text ?? "")
    }
    
    /// 改变字的链接
    func changeLinkWithTextLink(textLink:String,text:String) {
        self.attributedString(value: textLink, text: text, name: NSAttributedString.Key.link)
    }
    
    /// 改变字的基准线偏移 value>0坐标往上偏移 value<0坐标往下偏移
    func changeBaselineOffsetWithTextBaselineOffset(textBaselineOffset:NSNumber) {
        self.changeBaselineOffsetWithTextBaselineOffset(textBaselineOffset: textBaselineOffset, text: base.text ?? "")
    }
    
    /// 改变字的基准线偏移 value>0坐标往上偏移 value<0坐标往下偏移
    func changeBaselineOffsetWithTextBaselineOffset(textBaselineOffset:NSNumber,text:String) {
        self.attributedString(value: textBaselineOffset, text: text, name: NSAttributedString.Key.baselineOffset)
    }
    
    /// 改变字的倾斜 value>0向右倾斜 value<0向左倾斜
    func changeObliquenessWithTextObliqueness(textObliqueness:NSNumber) {
        self.changeObliquenessWithTextObliqueness(textObliqueness: textObliqueness, text: base.text ?? "")
    }
    
    /// 改变字的倾斜 value>0向右倾斜 value<0向左倾斜
    func changeObliquenessWithTextObliqueness(textObliqueness:NSNumber,text:String) {
        self.attributedString(value: textObliqueness, text: text, name: NSAttributedString.Key.obliqueness)
    }
    
    /// 改变字粗细 0就是不变 >0加粗 <0加细
    func changeExpansionsWithTextExpansion(textExpansion:NSNumber) {
        self.changeExpansionsWithTextExpansion(textExpansion: textExpansion, text:base.text ?? "")
    }
    
    /// 改变字粗细 0就是不变 >0加粗 <0加细
    func changeExpansionsWithTextExpansion(textExpansion:NSNumber,text:String) {
        self.attributedString(value: textExpansion, text: text, name: NSAttributedString.Key.expansion)
    }
    
    /// 改变字方向 NSWritingDirection
    func changeWritingDirectionWithTextExpansion(textWritingDirection:[Any],text:String) {
        self.attributedString(value: textWritingDirection, text: text, name: NSAttributedString.Key.writingDirection)
    }
    
    /// 改变字的水平或者竖直 1竖直 0水平
    func changeVerticalGlyphFormWithTextVerticalGlyphForm(textVerticalGlyphForm:NSNumber,text:String) {
        self.attributedString(value: textVerticalGlyphForm, text: text, name: NSAttributedString.Key.verticalGlyphForm)
    }
    
    /// 改变字的两端对齐
    func changeCTKernWithTextCTKern(textCTKern:NSNumber) {
        let att:NSAttributedString = NSAttributedString(string: "")
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: base.attributedText ?? att)
        attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: textCTKern, range: NSMakeRange(0, NSString(string: base.text ?? "").length-1))
        base.attributedText = attributedString
    }
    
    /// 为UILabel首部设置图片标签
    func changeImage(text:String,images:[UIImage],imageSpan:CGFloat) {
        
        let textAttrStr:NSMutableAttributedString = NSMutableAttributedString()
        images.forEach { image in
            let attach:NSTextAttachment = NSTextAttachment()
            attach.image = image
            let imgH:CGFloat = base.font.pointSize
            let imgW:CGFloat = (image.size.width / image.size.height) * imgH
            let textPaddingTop:CGFloat = (base.font.lineHeight - base.font.pointSize) / 2
            attach.bounds = CGRect(x: 0, y: -textPaddingTop, width: imgW, height: imgH)
            
            let imgStr:NSAttributedString = NSAttributedString(attachment: attach)
            textAttrStr.append(imgStr)
            textAttrStr.append(NSAttributedString(string: " "))
        }
        
        textAttrStr.append(NSAttributedString(string: text))
                           
        if imageSpan != 0 {
            textAttrStr.addAttribute(NSAttributedString.Key.kern, value: imageSpan, range: NSMakeRange(0, images.count * 2))
        }
        base.attributedText = textAttrStr
    }
    
    private func attributedString(value:Any,text:String,name:NSAttributedString.Key) {
        let att:NSAttributedString = NSAttributedString(string: "")
        let options: NSString.CompareOptions = [.caseInsensitive,.backwards,.diacriticInsensitive,.widthInsensitive]
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: base.attributedText ?? att)
        let textRange:NSRange = NSString(string: base.text ?? "").range(of: text, options: options)
        if textRange.location != NSNotFound {
            attributedString.addAttribute(name, value: value, range: textRange)
        }
        base.attributedText = attributedString
    }
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

private var isTapAction : Bool?
private var attributeStrings : [TFYSwiftAttributeModel]?
private var tapBlock : ((_ str : String ,_ range : NSRange ,_ index : Int) -> Void)?
private var isTapEffect : Bool = true
private var effectDic : Dictionary<String , NSAttributedString>?

class TFYSwiftAttributeModel : NSObject {
    var range : NSRange?
    var str : String?
}

public extension UILabel {
    
    var glyphIndexForString: Int? {
        guard let text = self.text else { return nil }
        let length = text.count
        let stringRange = NSRange(location: 0, length: length)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let glyphRange = layoutManager.glyphRange(forCharacterRange: stringRange, actualCharacterRange: nil)
        return glyphRange.location
    }
    
    /// 是否打开点击效果，默认是打开
    var enabledTapEffect : Bool {
        set {
            isTapEffect = newValue
        }
        get {
            return isTapEffect
        }
    }
    
    /**
     给文本添加点击事件
     - parameter strings:   需要点击的字符串数组
     - parameter tapAction: 点击事件回调
     */
    func addTapAction( _ strings : [String] , tapAction : @escaping ((String , NSRange , Int) -> Void)) -> Void {
        
        getRange(strings)
        
        tapBlock = tapAction
        
    }
    
    // MARK: - touchActions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTapAction == false {
            return
        }
        let touch = touches.first
        let point = touch?.location(in: self)
        getTapFrame(point!) { (String, NSRange, Int) -> Void in
            if tapBlock != nil {
                tapBlock! (String, NSRange , Int)
            }
            if isTapEffect {
                self.saveEffectDicWithRange(NSRange)
                self.tapEffectWithStatus(true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTapEffect {
            self.performSelector(onMainThread: #selector(self.tapEffectWithStatus(_:)), with: nil, waitUntilDone: false)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if isTapEffect {
            self.performSelector(onMainThread: #selector(self.tapEffectWithStatus(_:)), with: nil, waitUntilDone: false)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isTapAction == true {
            let result = getTapFrame(point, result: { (
                String, NSRange, Int) -> Void in
                
            })
            if result == true {
                return self
            }
        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: - getTapFrame
    @discardableResult
    fileprivate func getTapFrame(_ point : CGPoint , result : ((_ str : String ,_ range : NSRange ,_ index : Int) -> Void)) -> Bool {
        let framesetter = CTFramesetterCreateWithAttributedString(self.attributedText!)
        var path = CGMutablePath()
        path.addRect(self.bounds, transform: CGAffineTransform.identity)
        var frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        let range = CTFrameGetVisibleStringRange(frame)
        if self.attributedText?.length > range.length {
            var m_font : UIFont
            let n_font = self.attributedText?.attribute(.font, at: 0, effectiveRange: nil)
            if n_font != nil {
                m_font = n_font as! UIFont
            }else if (self.font != nil) {
                m_font = self.font
            }else {
                m_font = UIFont.systemFont(ofSize: 17)
            }
            path = CGMutablePath()
            path.addRect(CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height + m_font.lineHeight), transform: CGAffineTransform.identity)
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        }
        let lines = CTFrameGetLines(frame)
        if lines == [] as CFArray {
            return false
        }
        let count = CFArrayGetCount(lines)
        var origins = [CGPoint](repeating: CGPoint.zero, count: count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)
        let transform = CGAffineTransform(translationX: 0, y: self.bounds.size.height).scaledBy(x: 1.0, y: -1.0);
        let verticalOffset = 0.0
        for i : CFIndex in 0..<count {
            let linePoint = origins[i]
            let line = CFArrayGetValueAtIndex(lines, i)
            let lineRef = unsafeBitCast(line,to: CTLine.self)
            let flippedRect : CGRect = getLineBounds(lineRef , point: linePoint)
            var rect = flippedRect.applying(transform)
            rect = rect.insetBy(dx: 0, dy: 0)
            rect = rect.offsetBy(dx: 0, dy: CGFloat(verticalOffset))
            let style = self.attributedText?.attribute(.paragraphStyle, at: 0, effectiveRange: nil)
            var lineSpace : CGFloat = 0.0
            if (style != nil) {
                lineSpace = (style as! NSParagraphStyle).lineSpacing
            }else {
                lineSpace = 0.0
            }
            let lineOutSpace = (CGFloat(self.bounds.size.height) - CGFloat(lineSpace) * CGFloat(count - 1) - CGFloat(rect.size.height) * CGFloat(count)) / 2
            rect.origin.y = lineOutSpace + rect.size.height * CGFloat(i) + lineSpace * CGFloat(i)
            if rect.contains(point) {
                let relativePoint = CGPoint(x: point.x - rect.minX, y: point.y - rect.minY)
                var index = CTLineGetStringIndexForPosition(lineRef, relativePoint)
                var offset : CGFloat = 0.0
                CTLineGetOffsetForStringIndex(lineRef, index, &offset)
                if offset > relativePoint.x {
                    index = index - 1
                }
                let link_count = attributeStrings?.count
                if let count = link_count {
                    for j in 0 ..< count {
                        let model = attributeStrings![j]
                        let link_range = model.range
                        // 检查是否在位置范围
                        if NSLocationInRange(index, link_range!) {
                            result(model.str!,model.range!,j)
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    fileprivate func getLineBounds(_ line : CTLine , point : CGPoint) -> CGRect {
        var ascent : CGFloat = 0.0;
        var descent : CGFloat = 0.0;
        var leading  : CGFloat = 0.0;
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        let height = ascent + abs(descent) + leading
        return CGRect.init(x: point.x, y: point.y , width: CGFloat(width), height: height)
    }
    
    // MARK: - getRange
    fileprivate func getRange(_ strings :  [String]) -> Void {
        if self.attributedText?.length == 0 {
            return;
        }
        self.isUserInteractionEnabled = true
        isTapAction = true
        let totalString = self.attributedText?.string
        attributeStrings = [];
        var array = [TFYSwiftAttributeModel]()
        for str in strings {
            let ranges = totalString?.exMatchStrRange(str)
            if (ranges?.count ?? 0) > 0 {
                for i in 0..<(ranges?.count ?? 0) {
                    let range = ranges![i]
                    let model = TFYSwiftAttributeModel()
                    model.range = range
                    model.str = str
                    array.append(model)
                }
            }
        }
        if array.count > 1 {
            for i in 0..<array.count {
                for j in i..<array.count-1 {
                    if array[j].range?.location > array[j+1].range?.location {
                        let tmp = array[j]
                        array[j] = array[j+1]
                        array[j+1] = tmp
                    }
                }
            }
        }
        for model in array {
            attributeStrings?.append(model)
        }
    }
    
    fileprivate func getString(_ count : Int) -> String {
        var string = ""
        for _ in 0 ..< count {
            string = string + " "
        }
        return string
    }
    
    // MARK: - tapEffect
    fileprivate func saveEffectDicWithRange(_ range : NSRange) -> Void {
        effectDic = [:]
        let subAttribute = self.attributedText?.attributedSubstring(from: range)
        _ = effectDic?.updateValue(subAttribute!, forKey: NSStringFromRange(range))
    }
    
    @objc fileprivate func tapEffectWithStatus(_ status : Bool) -> Void {
        if isTapEffect && effectDic?.count > 0 {
            let attStr = NSMutableAttributedString.init(attributedString: self.attributedText!)
            let subAtt = NSMutableAttributedString.init(attributedString: (effectDic?.values.first)!)
            let range = NSRangeFromString(effectDic!.keys.first!)
            if status {
                subAtt.addAttribute(.backgroundColor, value: UIColor.lightGray, range: NSMakeRange(0, subAtt.length))
                attStr.replaceCharacters(in: range, with: subAtt)
            }else {
                attStr.replaceCharacters(in: range, with: subAtt)
            }
            self.attributedText = attStr
        }
    }
    
    /// 验证码倒计时显示
    func timerStart(_ interval: Int = 60) {
        var time = interval
        let codeTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.global())
        codeTimer.schedule(deadline: .now(), repeating: .milliseconds(1000))
        codeTimer.setEventHandler {
            
            time -= 1
            DispatchQueue.main.async {
                self.isEnabled = time <= 0
                if time > 0 {
                    self.text = "剩余\(time)s"
                    return
                }
                codeTimer.cancel()
                self.text = "发送验证码"
            }
        }
        codeTimer.resume()
    }
}

private extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range,in : self)
    }
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}

extension String {
    @discardableResult
    func exMatchStrRange(_ matchStr: String) -> [NSRange] {
        var selfStr = self as NSString
        var withStr = Array(repeating: "X", count: (matchStr as NSString).length).joined(separator: "") //辅助字符串
        if matchStr == withStr { withStr = withStr.lowercased() } //临时处理辅助字符串差错
        var allRange = [NSRange]()
        while selfStr.range(of: matchStr).location != NSNotFound {
            let range = selfStr.range(of: matchStr)
            allRange.append(NSRange(location: range.location,length: range.length))
            selfStr = selfStr.replacingCharacters(in: NSMakeRange(range.location, range.length), with: withStr) as NSString
        }
        return allRange
    }
}
