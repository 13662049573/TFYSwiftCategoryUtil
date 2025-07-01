//
//  UILabel+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//  优化：参数安全性检查、注释补全、健壮性提升
//

import UIKit

public extension TFY where Base: UILabel {
    /// 设置行数
    @discardableResult
    func numberOfLines(_ numberOfLines: Int) -> Self {
        base.numberOfLines = max(0, numberOfLines)
        return self
    }
    /// 设置是否自动调整字体大小以适应宽度
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
        base.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
    /// 获取适合指定大小的尺寸
    @discardableResult
    func sizeThatFits(size:CGSize) -> CGSize {
        let sizes:CGSize = base.sizeThatFits(size)
        return sizes
    }
}

public extension UILabel {
    /// 改变字体
    func changeFontWithTextFont(font:UIFont) {
        self.changeFontWithTextFont(font: font, text: self.text ?? "")
    }
    /// 改变字体
    func changeFontWithTextFont(font:UIFont,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: font, text: text, name: NSAttributedString.Key.font)
    }
    
    /// 改变字间距
    func changeSpaceWithTextSpace(textSpace:CGFloat) {
        self.changeSpaceWithTextSpace(textSpace: textSpace, text: self.text ?? "")
    }
    /// 改变字间距
    func changeSpaceWithTextSpace(textSpace:CGFloat,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textSpace, text: text, name: NSAttributedString.Key.kern)
    }
    
    /// 改变行间距
    func changeLineSpaceWithTextLineSpace(textLineSpace:CGFloat) {
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = textLineSpace
        paragraphStyle.alignment = self.textAlignment
        self.changeParagraphStyleWithTextParagraphStyle(paragraphStyle: paragraphStyle)
    }

    /// 段落样式
    func changeParagraphStyleWithTextParagraphStyle(paragraphStyle:NSParagraphStyle) {
        let att:NSAttributedString = NSAttributedString(string: "")
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText ?? att)
        let textLength = NSString(string: self.text ?? "").length
        if textLength > 0 {
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, textLength))
        }
        self.attributedText = attributedString
    }
    
    /// 改变字段颜色
    func changeColorWithTextColor(textColor:UIColor) {
        self.changeColorWithTextColor(textColor: textColor, text: self.text ?? "")
    }
    
    /// 改变字段颜色
    func changeColorWithTextColor(textColor:UIColor,text:String) {
        guard !text.isEmpty else { return }
        self.changeColorWithTextColor(textColor: textColor, texts: [text])
    }
    
    /// 改变字段颜色
    func changeColorWithTextColor(textColor:UIColor,texts:[String]) {
        guard !texts.isEmpty else { return }
        let attributedString = NSMutableAttributedString(string: self.text ?? "")
        texts.forEach { textStr in
            guard !textStr.isEmpty else { return }
            let range = ((self.text ?? "") as NSString).range(of: textStr)
            if range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: textColor, range: range)
            }
        }
        self.attributedText = attributedString
    }
    
    /// 改变不同字段颜色
    func changeColorWithTextColors(textColors:[UIColor],texts:[String]) {
        guard textColors.count == texts.count, !textColors.isEmpty else { return }
        let attributedString = NSMutableAttributedString(string: self.text ?? "")
        for (index,color) in textColors.enumerated() {
            guard index < texts.count, !texts[index].isEmpty else { continue }
            let range = ((self.text ?? "") as NSString).range(of: texts[index])
            if range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        self.attributedText = attributedString
    }
    
    /// 改变字段背景颜色
    func changeBgColorWithBgTextColor(bgTextColor:UIColor) {
        self.changeBgColorWithBgTextColor(bgTextColor: bgTextColor,text: self.text ?? "")
    }
    
    /// 改变字段背景颜色
    func changeBgColorWithBgTextColor(bgTextColor:UIColor,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: bgTextColor, text: text, name: NSAttributedString.Key.backgroundColor)
    }
    
    /// 改变字段连笔字 value值为1或者0
    func changeLigatureWithTextLigature(textLigature:NSNumber) {
        self.changeLigatureWithTextLigature(textLigature: textLigature, text: self.text ?? "")
    }
    
    /// 改变字段连笔字 value值为1或者0
    func changeLigatureWithTextLigature(textLigature:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textLigature, text: text, name: NSAttributedString.Key.ligature)
    }
    
    /// 改变字间距
    func changeKernWithTextKern(textKern:NSNumber) {
        self.changeKernWithTextKern(textKern: textKern, text: self.text ?? "")
    }
    
    /// 改变字间距
    func changeKernWithTextKern(textKern:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textKern, text: text, name: NSAttributedString.Key.kern)
    }
    
    /// 改变字的删除线
    func changeStrikethroughStyleWithTextStrikethroughStyle(textStrikethroughStyle:NSNumber) {
        self.changeStrikethroughStyleWithTextStrikethroughStyle(textStrikethroughStyle: textStrikethroughStyle, text: self.text ?? "")
    }
    
    /// 改变字的删除线
    func changeStrikethroughStyleWithTextStrikethroughStyle(textStrikethroughStyle:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textStrikethroughStyle, text: text, name: NSAttributedString.Key.strikethroughStyle)
    }
    
    /// 改变字的删除线颜色
    func changeStrikethroughColorWithTextStrikethroughColor(textStrikethroughColor:UIColor) {
        self.changeStrikethroughColorWithTextStrikethroughColor(textStrikethroughColor: textStrikethroughColor, text: self.text ?? "")
    }
    
    /// 改变字的删除线颜色
    func changeStrikethroughColorWithTextStrikethroughColor(textStrikethroughColor:UIColor,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textStrikethroughColor, text: text, name: NSAttributedString.Key.strikethroughColor)
    }
    
    /// 改变字的下划线
    func changeUnderlineStyleWithTextStrikethroughStyle(textUnderlineStyle:NSNumber) {
        self.changeUnderlineStyleWithTextStrikethroughStyle(textUnderlineStyle: textUnderlineStyle, text: self.text ?? "")
    }
    
    /// 改变字的下划线
    func changeUnderlineStyleWithTextStrikethroughStyle(textUnderlineStyle:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textUnderlineStyle, text: text, name: NSAttributedString.Key.underlineStyle)
    }
    
    /// 改变字的下划线颜色
    func changeUnderlineColorWithTextStrikethroughColor(textUnderlineColor:UIColor) {
        self.changeUnderlineColorWithTextStrikethroughColor(textUnderlineColor: textUnderlineColor, text: self.text ?? "")
    }
    
    /// 改变字的下划线颜色
    func changeUnderlineColorWithTextStrikethroughColor(textUnderlineColor:UIColor,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textUnderlineColor, text: text, name: NSAttributedString.Key.underlineColor)
    }
    
    /// 改变字的描边颜色
    func changeStrokeColorWithTextStrikethroughColor(textStrokeColor:UIColor) {
        self.changeStrokeColorWithTextStrikethroughColor(textStrokeColor: textStrokeColor, text: self.text ?? "")
    }
    
    /// 改变字的描边颜色
    func changeStrokeColorWithTextStrikethroughColor(textStrokeColor:UIColor,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textStrokeColor, text: text, name: NSAttributedString.Key.strokeColor)
    }
    
    /// 改变字的描边宽度
    func changeStrokeWidthWithTextStrikethroughWidth(textStrokeWidth:NSNumber) {
        self.changeStrokeWidthWithTextStrikethroughWidth(textStrokeWidth: textStrokeWidth, text: self.text ?? "")
    }
    
    /// 改变字的描边宽度
    func changeStrokeWidthWithTextStrikethroughWidth(textStrokeWidth:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textStrokeWidth, text: text, name: NSAttributedString.Key.strokeWidth)
    }
    
    /// 改变字的阴影
    func changeShadowWithTextShadow(textShadow:NSShadow) {
        self.changeShadowWithTextShadow(textShadow: textShadow, text: self.text ?? "")
    }
    
    /// 改变字的阴影
    func changeShadowWithTextShadow(textShadow:NSShadow,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textShadow, text: text, name: NSAttributedString.Key.shadow)
    }
    
    /// 改变字的特殊效果
    func changeTextEffectWithTextEffect(textEffect:String) {
        self.changeTextEffectWithTextEffect(textEffect: textEffect, text: self.text ?? "")
    }
    
    /// 改变字的特殊效果
    func changeTextEffectWithTextEffect(textEffect:String,text:String) {
        guard !text.isEmpty, !textEffect.isEmpty else { return }
        self.attributedString(value: textEffect, text: text, name: NSAttributedString.Key.textEffect)
    }
    
    /// 改变字的文本附件
    func changeAttachmentWithTextAttachment(textAttachment:NSTextAttachment) {
        self.changeAttachmentWithTextAttachment(textAttachment: textAttachment, text: self.text ?? "")
    }
    
    /// 改变字的文本附件
    func changeAttachmentWithTextAttachment(textAttachment:NSTextAttachment,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textAttachment, text: text, name: NSAttributedString.Key.attachment)
    }
    
    /// 改变字的链接
    func changeLinkWithTextLink(textLink:String) {
        self.changeLinkWithTextLink(textLink: textLink, text: self.text ?? "")
    }
    
    /// 改变字的链接
    func changeLinkWithTextLink(textLink:String,text:String) {
        guard !text.isEmpty, !textLink.isEmpty else { return }
        self.attributedString(value: textLink, text: text, name: NSAttributedString.Key.link)
    }
    
    /// 改变字的基准线偏移 value>0坐标往上偏移 value<0坐标往下偏移
    func changeBaselineOffsetWithTextBaselineOffset(textBaselineOffset:NSNumber) {
        self.changeBaselineOffsetWithTextBaselineOffset(textBaselineOffset: textBaselineOffset, text: self.text ?? "")
    }
    
    /// 改变字的基准线偏移 value>0坐标往上偏移 value<0坐标往下偏移
    func changeBaselineOffsetWithTextBaselineOffset(textBaselineOffset:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textBaselineOffset, text: text, name: NSAttributedString.Key.baselineOffset)
    }
    
    /// 改变字的倾斜 value>0向右倾斜 value<0向左倾斜
    func changeObliquenessWithTextObliqueness(textObliqueness:NSNumber) {
        self.changeObliquenessWithTextObliqueness(textObliqueness: textObliqueness, text: self.text ?? "")
    }
    
    /// 改变字的倾斜 value>0向右倾斜 value<0向左倾斜
    func changeObliquenessWithTextObliqueness(textObliqueness:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textObliqueness, text: text, name: NSAttributedString.Key.obliqueness)
    }
    
    /// 改变字粗细 0就是不变 >0加粗 <0加细
    func changeExpansionsWithTextExpansion(textExpansion:NSNumber) {
        self.changeExpansionsWithTextExpansion(textExpansion: textExpansion, text:self.text ?? "")
    }
    
    /// 改变字粗细 0就是不变 >0加粗 <0加细
    func changeExpansionsWithTextExpansion(textExpansion:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textExpansion, text: text, name: NSAttributedString.Key.expansion)
    }
    
    /// 改变字方向 NSWritingDirection
    func changeWritingDirectionWithTextExpansion(textWritingDirection:[Any],text:String) {
        guard !text.isEmpty, !textWritingDirection.isEmpty else { return }
        self.attributedString(value: textWritingDirection, text: text, name: NSAttributedString.Key.writingDirection)
    }
    
    /// 改变字的水平或者竖直 1竖直 0水平
    func changeVerticalGlyphFormWithTextVerticalGlyphForm(textVerticalGlyphForm:NSNumber,text:String) {
        guard !text.isEmpty else { return }
        self.attributedString(value: textVerticalGlyphForm, text: text, name: NSAttributedString.Key.verticalGlyphForm)
    }
    
    /// 改变字的两端对齐
    func changeCTKernWithTextCTKern(textCTKern:NSNumber) {
        let att:NSAttributedString = NSAttributedString(string: "")
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText ?? att)
        let textLength = NSString(string: self.text ?? "").length
        if textLength > 1 {
            attributedString.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: textCTKern, range: NSMakeRange(0, textLength-1))
        }
        self.attributedText = attributedString
    }
    
    /// 为UILabel首部设置图片标签
    func changeImage(text:String,images:[UIImage],imageSpan:CGFloat) {
        guard !images.isEmpty else { return }
        
        let textAttrStr:NSMutableAttributedString = NSMutableAttributedString()
        images.forEach { image in
            let attach:NSTextAttachment = NSTextAttachment()
            attach.image = image
            let imgH:CGFloat = self.font.pointSize
            let imgW:CGFloat = (image.size.width / image.size.height) * imgH
            let textPaddingTop:CGFloat = (self.font.lineHeight - self.font.pointSize) / 2
            attach.bounds = CGRect(x: 0, y: -textPaddingTop, width: imgW, height: imgH)
            
            let imgStr:NSAttributedString = NSAttributedString(attachment: attach)
            textAttrStr.append(imgStr)
            textAttrStr.append(NSAttributedString(string: " "))
        }
        
        textAttrStr.append(NSAttributedString(string: text))
                           
        if imageSpan != 0 {
            textAttrStr.addAttribute(NSAttributedString.Key.kern, value: imageSpan, range: NSMakeRange(0, images.count * 2))
        }
        self.attributedText = textAttrStr
    }
    
    private func attributedString(value:Any,text:String,name:NSAttributedString.Key) {
        guard !text.isEmpty else { return }
        let att:NSAttributedString = NSAttributedString(string: "")
        let options: NSString.CompareOptions = [.caseInsensitive,.backwards,.diacriticInsensitive,.widthInsensitive]
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText ?? att)
        let textRange:NSRange = NSString(string: self.text ?? "").range(of: text, options: options)
        if textRange.location != NSNotFound {
            attributedString.addAttribute(name, value: value, range: textRange)
        }
        self.attributedText = attributedString
    }
}
