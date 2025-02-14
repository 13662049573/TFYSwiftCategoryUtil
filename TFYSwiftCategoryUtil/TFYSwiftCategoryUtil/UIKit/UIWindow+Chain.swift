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
        var keyWindow:UIWindow?
        keyWindow = UIApplication.shared.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows.first
        return keyWindow
    }

    static var statusBarFrame: CGRect {
        return keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
    }

    static var statusBarHeight: CGFloat {
        return statusBarFrame.size.height
    }

    static var safeAreaInsets: UIEdgeInsets {
        return keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
    }
}

public extension UIScreen {
    static var width: CGFloat {
        let size:CGSize = UIScreen.main.bounds.size
        return size.height < size.width ? size.height : size.width
    }

    static var height: CGFloat {
        let size:CGSize = UIScreen.main.bounds.size
        return size.height > size.width ? size.height : size.width
    }
    
    static var kscale:CGFloat {
        return UIScreen.main.scale
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
    
    static var bottomHeight: CGFloat {
        let bottomH:CGFloat = UIDevice.isIphoneX ? 83 : 49
        return bottomH
    }
    
    static var navBarHeight: CGFloat {
        let navH:CGFloat = UIDevice.isIphoneX ? 88 : 64
        return navH
    }
}

