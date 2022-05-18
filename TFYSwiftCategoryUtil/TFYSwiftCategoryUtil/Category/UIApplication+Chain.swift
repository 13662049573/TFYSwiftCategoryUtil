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
    var appDelegate: UIApplicationDelegate {
        return UIApplication.shared.delegate!
    }
    
    // cs.currentViewController: current UIViewController
    var currentViewController: UIViewController {
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
    
    // cs.appVersion: current App Version
    var appVersion: String {
        let infoDict = Bundle.main.infoDictionary! as Dictionary<String, AnyObject>
        return infoDict["CFBundleShortVersionString"] as! String
    }
    
}


// MARK: - snapShot

public extension TFY where Base: UIApplication {
    
    func snapShot(_ inView: UIView) -> UIImage {
        UIGraphicsBeginImageContext(inView.bounds.size)
        inView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapShot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return snapShot
    }
    
}

