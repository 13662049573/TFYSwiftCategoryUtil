//
//  Data+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/18.
//

import Foundation
import UIKit

extension Data: TFYCompatible {}

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
    
    // MARK: 1.3、转成bytes
    /// 转成bytes
    var bytes: [UInt8] {
        return [UInt8](base)
    }
}
