//
//  UIColor+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/12.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexColor: String) {
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        let hex = hexColor as NSString
        Scanner(string: hex.substring(with: NSRange(location: 0, length: 2))).scanHexInt64(&red)
        Scanner(string: hex.substring(with: NSRange(location: 2, length: 2))).scanHexInt64(&green)
        Scanner(string: hex.substring(with: NSRange(location: 4, length: 2))).scanHexInt64(&blue)
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
    /// 随机颜色
    static var random: UIColor {
        return UIColor(red: CGFloat(arc4random() % 256) / 255.0,
                       green: CGFloat(arc4random() % 256) / 255.0,
                       blue: CGFloat(arc4random() % 256) / 255.0,
                       alpha: 0.5)
    }

    /// 根据16进制颜色值返回颜色
    /// - Parameters:
    ///   - hexString: 颜色值字符串: 前缀 ‘#’ 和 ‘0x’ 不是必须的
    ///   - alpha: 透明度，默认为1
    /// - Returns: UIColor
    static func hexString(_ hexString: String, alpha: CGFloat = 1) -> UIColor {
        var str = ""
        if hexString.lowercased().hasPrefix("0x") {
            str = hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.lowercased().hasPrefix("#") {
            str = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            str = hexString
        }

        let length = str.count
        // 如果不是 RGB RGBA RRGGBB RRGGBBAA 结构
        if length != 3 && length != 4 && length != 6 && length != 8 {
            return .clear
        }

        // 将 RGB RGBA 转换为 RRGGBB RRGGBBAA 结构
        if length < 5 {
            var tStr = ""
            str.forEach { tStr.append(String(repeating: $0, count: 2)) }
            str = tStr
        }

        guard let hexValue = Int(str, radix: 16) else {
            return .clear
        }

        var red = 0
        var green = 0
        var blue = 0

        if length == 3 || length == 6 {
            red = (hexValue >> 16) & 0xFF
            green = (hexValue >> 8) & 0xFF
            blue = hexValue & 0xFF
        } else {
            red = (hexValue >> 20) & 0xFF
            green = (hexValue >> 16) & 0xFF
            blue = (hexValue >> 8) & 0xFF
        }
        return UIColor(red: CGFloat(red) / 255.0,
                       green: CGFloat(green) / 255.0,
                       blue: CGFloat(blue) / 255.0,
                       alpha: CGFloat(alpha))
    }

    /// 根据16进制颜色值返回颜色
    /// - Parameters:
    ///   - hex: 16进制数值
    ///   - alpha: 透明度，默认为1
    /// - Returns: UIColor
    static func hexInt32(_ hex: Int32, alpha: CGFloat = 1) -> UIColor {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255
        let g = CGFloat((hex & 0xFF00) >> 8) / 255
        let b = CGFloat(hex & 0xFF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    /// 颜色 --> 图片
    /// - Returns: UIImage?
    func toImage() -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    public func darkerColor(threshold:CGFloat = 0.3) -> UIColor {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let threshold = 1 - threshold
        r *= threshold * threshold
        g *= threshold * threshold
        b *= threshold * threshold
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    public func lighterColor(threshold:CGFloat = 0.3) -> UIColor {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let threshold = 1 - threshold
        r = 1 - (1 - r) * threshold * threshold
        g = 1 - (1 - g) * threshold * threshold
        b = 1 - (1 - b) * threshold * threshold
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

