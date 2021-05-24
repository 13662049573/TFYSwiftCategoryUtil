//
//  Data+ITools.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/16.
//

import UIKit

public enum ImageFormat {
    case Unknow
    case JPEG
    case PNG
    case GIF
    case TIFF
    case WebP
    case HEIC
    case HEIF
}

extension Data: TFYCompatible {}
// MARK:- 一、基本的扩展
public extension TFY where Base == Data {

    // MARK: 1.1、base64编码成 Data
    /// 编码
    var encodeToData: Data? {
        return base.base64EncodedData()
    }
    
    // MARK: 1.2、base64解码成 Data
    /// 解码成 Data
    var decodeToDada: Data? {
        return Data(base64Encoded: base)
    }
    
    func getImageFormat() -> ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 1)
        base.copyBytes(to: &buffer, count: 1)
        switch buffer {
        case [0xFF]: return .JPEG
        case [0x89]: return .PNG
        case [0x47]: return .GIF
        case [0x49],[0x4D]: return .TIFF
        case [0x52] where base.count >= 12:
            if let str = String(data: base[0...11], encoding: .ascii), str.hasPrefix("RIFF"), str.hasPrefix("WEBP") {
                return .WebP
            }
        case [0x00] where base.count >= 12:
            if let str = String(data: base[8...11], encoding: .ascii) {
                let HEICBitMaps = Set(["heic", "heis", "heix", "hevc", "hevx"])
                if HEICBitMaps.contains(str) {
                    return .HEIC
                }
                let HEIFBitMaps = Set(["mif1", "msf1"])
                if HEIFBitMaps.contains(str) {
                    return .HEIF
                }
            } default: break;
        }
        return .Unknow
    }
}
