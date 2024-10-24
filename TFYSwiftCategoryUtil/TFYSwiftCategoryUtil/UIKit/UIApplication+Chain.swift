//
//  UIApplication+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/18.
//

import Foundation
import UIKit

public extension TFY where Base: UIApplication {
    
    // cs.appDelegate: current AppDelegate
    static var appDelegate: UIApplicationDelegate {
        return UIApplication.shared.delegate!
    }
    
    // cs.currentViewController: current UIViewController
    static var currentViewController: UIViewController {
        let window = self.appDelegate.window
        var viewController = window!!.rootViewController
        while ((viewController?.presentedViewController) != nil) {
            viewController = viewController?.presentedViewController
            if ((viewController?.isKind(of: UINavigationController.classForCoder())) == true) {
                viewController = (viewController as! UINavigationController).visibleViewController
            } else if ((viewController?.isKind(of: UITabBarController.classForCoder())) == true) {
                viewController = (viewController as! UITabBarController).selectedViewController
            }
        }
        return viewController!
    }
}

// MARK: - App Version Related
public extension TFY where Base: UIApplication {
    /**
     'Documents' folder in app`s sandbox
     */
    static var documentsURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
    static var documentsPath: String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    /**
     'Caches' folder in this app`s sandbox
     */
    static var cachesURL: URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last
    }
    static var cachesPath: String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    /**
     'Library' folder in this app`s sandbox
     */
    static var libraryURL: URL? {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last
    }
    static var libraryPath: String? {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
    }
    
    /**
     Application`s Bundle Name
     */
    static var appBundleName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    /// Application`s Bundle ID e.g 'com.yamex.app'
    static var appBundleID: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
    }
    
    /// Application`s Bundle Version e.b '1.0.0'
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    /// Application`s Bundle Version e.b '12'
    static var appBuildVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
}


// MARK: - snapShot

public extension TFY where Base: UIApplication {
    static func snapShot(_ inView: UIView) -> UIImage {
        UIGraphicsBeginImageContext(inView.bounds.size)
        inView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapShot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return snapShot
    }
}

