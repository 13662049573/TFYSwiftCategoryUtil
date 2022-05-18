//
//  String+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/13.
//

import Foundation
import UIKit
import CommonCrypto

public extension String {
    
    /// - Returns:  md5 加密
    var md5 : String {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
     }
    
    /// - Returns: md5j加密返回data
     func md5_data(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    /// - Returns: 返回文件的 md5 值
    func md5_File() -> String? {
        guard let fileHandle = FileHandle(forReadingAtPath: self) else {
            return nil
        }
        
        let ctx = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: MemoryLayout<CC_MD5_CTX>.size)
        
        CC_MD5_Init(ctx)
        
        var done = false
        
        while !done {
            let fileData = fileHandle.readData(ofLength: 256)
            fileData.withUnsafeBytes {(bytes: UnsafePointer<CChar>) -> () in
                /// Use `bytes` inside this closure
                CC_MD5_Update(ctx, bytes, CC_LONG(fileData.count))
            }
            
            if fileData.count == 0 {
                done = true
            }
        }
        
        let digest = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digest)
        CC_MD5_Final(result, ctx);
        
        var hash = ""
        for i in 0..<digest {
            hash +=  String(format: "%02x", (result[i]))
        }
        
        free(result)
        free(ctx)
        
        return hash;
    }
    
    /// - Returns: 计算文本宽度
    func widthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    /// - Returns: 计算文本高度
    func heightForComment(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
           
    /// - Returns: 计算文本最大高度
    func heightForComment(fontSize: CGFloat, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }
   
    func stringByTrim() -> String {
        let set:CharacterSet = CharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: set)
    }
}

public extension String {
    /// 字符串转换成UIViewController?
    /// - Returns: UIViewController?
    func toViewController() -> UIViewController? {
        if isEmpty {
            return nil
        }
        // 1.获取命名空间
        guard let name = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            return nil
        }
        // 2.获取Class
        let vcClass: AnyClass? = NSClassFromString(name + "." + self)
        guard let typeClass = vcClass as? UIViewController.Type else {
            return nil
        }
        // 3.创建vc
        let vc = typeClass.init()
        return vc
    }
}

public extension String {
    func contains(regular: String) -> Bool {
        return range(of: regular, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

public extension String {
    subscript(r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound, limitedBy: endIndex) ?? endIndex
        let end = index(startIndex, offsetBy: r.upperBound, limitedBy: endIndex) ?? endIndex
        return String(self[start ..< end])
    }

    subscript(str: String) -> Range<Index>? {
        return range(of: str)
    }

    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        return self[..<index(startIndex, offsetBy: value.upperBound)]
    }

    subscript(value: PartialRangeThrough<Int>) -> Substring {
        return self[...index(startIndex, offsetBy: value.upperBound)]
    }

    subscript(value: PartialRangeFrom<Int>) -> Substring {
        return self[index(startIndex, offsetBy: value.lowerBound)...]
    }

    subscript(value: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: value.lowerBound)
        let end = index(startIndex, offsetBy: value.upperBound)
        return self[start ..< end]
    }

    subscript(value: ClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: value.lowerBound)
        let end = index(startIndex, offsetBy: value.upperBound)
        return self[start ... end]
    }
}

