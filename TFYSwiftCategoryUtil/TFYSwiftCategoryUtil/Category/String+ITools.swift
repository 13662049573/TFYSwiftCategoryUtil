//
//  String+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/4/21.
//

import Foundation
import UIKit
import CommonCrypto

extension String {
    
    static func ~= (pattern:(String) -> Bool,value:String) -> Bool {
        pattern(value)
    }
}

public func hasPrefix(_ prefix:String) -> ((String) -> Bool) {
    { $0.hasPrefix(prefix) }
}

public func hasSuffix(_ suffix:String) -> ((String) -> Bool) {
    { $0.hasSuffix(suffix) }
}

/// MARK ---------------------------------------------------------------  String ---------------------------------------------------------------
extension TFY where Base: ExpressibleByStringLiteral {
    /// 检查是否手机号
    func isTelNumber() -> Bool
    {
        if (base as! String).count < 11 {
            return false
        }
        let mobile = "^1\\d{10}$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        return regextestmobile.evaluate(with: (base as! String))
    }
    
    /// 检查身份证号
    func isIdCardNumber() -> Bool {
        // 身份证号码为15位或者18位，15位时全为数字，18位前17位为数字，最后一位是校验位，可能为数字或字符X
        let reg = "^\\d{17}[0-9Xx]|\\d{15}"
        let regexIdCard = NSPredicate(format: "SELF MATCHES %@",reg)
        return regexIdCard.evaluate(with: (base as! String))
    }
    
    ///是否为纯数字
    func isDigital() -> Bool {
        let reg = "[0-9]*"
        let regexIdCard = NSPredicate(format: "SELF MATCHES %@",reg)
        return regexIdCard.evaluate(with: (base as! String))
    }
    
    ///是否为纯字母
    func isLetter() -> Bool {
        let reg = "[a-zA-Z]*"
        let regexIdCard = NSPredicate(format: "SELF MATCHES %@",reg)
        return regexIdCard.evaluate(with: (base as! String))
    }
    
    
    ///是否为数字和字母
    func isDigitalAndLetter() -> Bool {
        let reg = "[a-zA-Z0-9]*"
        let regexIdCard = NSPredicate(format: "SELF MATCHES %@",reg)
        return regexIdCard.evaluate(with: (base as! String))
    }
    
    ///是否为纯汉字
    func isChinese() -> Bool {
        let reg = "^[\u{4e00}-\u{9fa5}]+$"
        let regexIdCard = NSPredicate(format: "SELF MATCHES %@",reg)
        return regexIdCard.evaluate(with: (base as! String))
    }
    
    ///邮箱格式校验
    func isEmail() -> Bool {
        let reg = "([a-zA-Z0-9_-]+)@([a-zA-Z0-9_-]+)(\\.[a-zA-Z0-9_-]+)+$"
        let regexIdCard = NSPredicate(format: "SELF MATCHES %@",reg)
        return regexIdCard.evaluate(with: (base as! String))
    }

    /**
     根据字体、CGSize来计算字符串的高度
     */
    func calculateSize(with size: CGSize, font: UIFont) -> CGSize {
        return ((base as! String) as NSString).boundingRect(with: size,
                                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                                        attributes: [NSAttributedString.Key.font: font],
                                        context: nil).size
    }

   
    /// 字符串的匹配范围 方法二(推荐)
    ///
    /// - Parameters:
    /// - matchStr: 要匹配的字符串
    /// - Returns: 返回所有字符串范围
    @discardableResult
    func exMatchStrRange(_ matchStr: String) -> [NSRange] {
        var selfStr = (base as! String) as NSString
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
    
    /// 计算文本高度
    /// - Parameters:
    ///   - content: 文字内容
    ///   - font: 字体大小
    ///   - lineSpace: 行间距
    ///   - wordSpace: 字体间距
    ///   - width: 可显示的宽度
    ///   - maxHeight: 最大允许高度
    /// - Returns: 高度
     func getContentOfHeight(font: UIFont,lineSpace: CGFloat,wordSpace:CGFloat,width: CGFloat,maxHeight: CGFloat) -> CGFloat {
        
        let p = NSMutableParagraphStyle.init()
        p.lineSpacing = lineSpace
        
        let dic = [NSAttributedString.Key.font:font,NSAttributedString.Key.paragraphStyle:p,NSAttributedString.Key.kern:wordSpace] as [NSAttributedString.Key : Any]
        
        let size = (base as! String).boundingRect(with: CGSize(width: width, height: maxHeight), options: .usesLineFragmentOrigin, attributes: dic, context: nil).size
        
        return size.height
    }
    
    
    /// 默认获取内容高度（无行间距、文字间距）
    /// - Parameters:
    ///   - content: Label的文本内容
    ///   - font: Label字体大小
    ///   - width: Label可显示的宽度
    /// - Returns: Label高度
    func getHeight(font: UIFont, width: CGFloat) -> CGFloat {
        return getContentOfHeight(font: font, lineSpace: 0, wordSpace: 0, width: width, maxHeight: CGFloat.greatestFiniteMagnitude)
    }
    
    /// 计算Label文本内容宽度
    /// - Parameters:
    ///   - content: 文本内容
    ///   - font: Label字体大小
    ///   - lineSpace: 行间距
    ///   - wordSpace: 文字间距
    ///   - height: 可显示的高度
    ///   - maxWidth: 最大允许宽度
    /// - Returns: Label宽度
     func getContentOfWidth(font: UIFont,lineSpace: CGFloat,wordSpace:CGFloat,height: CGFloat,maxWidth: CGFloat) -> CGFloat {
        let p = NSMutableParagraphStyle.init()
        p.lineSpacing = lineSpace
        let dic = [NSAttributedString.Key.font:font,NSAttributedString.Key.paragraphStyle:p,NSAttributedString.Key.kern:wordSpace] as [NSAttributedString.Key : Any]
        let size = (base as! String).boundingRect(with: CGSize(width: maxWidth, height: height), options: .usesLineFragmentOrigin, attributes: dic, context: nil).size
        return size.width
    }
    /// 默认获取Label内容宽度（无行间距、文字间距）
    /// - Parameters:
    ///   - content: 文本内容
    ///   - font: 字体大小
    ///   - height: 行高
    ///   - maxWidth: 最大允许宽度
    /// - Returns: Label宽度
    func getWidth(font: UIFont,height: CGFloat,maxWidth: CGFloat) -> CGFloat {
        return getContentOfWidth(font: font, lineSpace: 0, wordSpace: 0, height: height, maxWidth: maxWidth)
    }
    
    /// urlEncode编码
     func urlEncodeStr() -> String? {
         let charactersToEscape = "?!@#$^&%*+,:;='\"`<>()[]{}/\\| "
         let allowedCharacters = CharacterSet(charactersIn: charactersToEscape).inverted
         let upSign = (base as! String).addingPercentEncoding(withAllowedCharacters: allowedCharacters)
         return upSign
     }
     
     /// urlEncode解码
     func decoderUrlEncodeStr() -> String? {
         var outputStr = (base as! String)
         if let subRange = Range<String.Index>(NSRange(location: 0, length: outputStr.count), in: outputStr) { outputStr = outputStr.replacingOccurrences(of: "+", with: "", options: .literal, range: subRange) }
         return outputStr.removingPercentEncoding
     }
    
     /// MARK: 字符串转字典
     func getDictionaryFromJSONString() -> NSDictionary{
      
         let jsonData:Data = (base as! String).data(using: .utf8)!
      
         let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
         if dict != nil {
             return dict as! NSDictionary
         }
         return NSDictionary()
     }
}
