//
//  UIWindow+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/15.
//

import Foundation
import UIKit

public extension UIWindow {
    static var keyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            if let window = UIApplication.shared.delegate?.window as? UIWindow {
                return window
            } else {
                for window in UIApplication.shared.windows where window.windowLevel == .normal && !window.isHidden {
                    return window
                }
                return UIApplication.shared.windows.first
            }
        }
    }

    static var statusBarFrame: CGRect {
        if #available(iOS 13.0, *) {
            return keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            return UIApplication.shared.statusBarFrame
        }
    }

    static var statusBarHeight: CGFloat {
        return statusBarFrame.size.height
    }

    static var safeAreaInsets: UIEdgeInsets {
        return UIWindow.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
    }
}

public extension UIScreen {
    static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }

    static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
}

public extension UIDevice {
    static var isIphoneX: Bool {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return true
        }
        if #available(iOS 11.0, *) {
            let bottom = UIWindow.safeAreaInsets.bottom
            if bottom > 0.0 {
                return true
            }
        }
        return false
    }
}

