//
//  String+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/13.
//

import Foundation
import UIKit
import CommonCrypto

extension String {
    
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
    
    /// - Returns: 返回文件的 md5 值
    public func md5_File() -> String? {
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
   
}

