//
//  UserDefaults+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/9.
//
import UIKit

public extension TFY where Base: UserDefaults {
    
    @discardableResult
    func removeObject(forKey defaultName: String) -> TFY {
        base.removeObject(forKey: defaultName)
        return self
    }
    
    @discardableResult
    func set(_ value: Any?, forKey defaultName: String) -> TFY {
        base.set(value, forKey: defaultName)
        return self
    }
    
    @discardableResult
    func set(_ value: Bool, forKey defaultName: String) -> TFY {
        base.set(value, forKey: defaultName)
        return self
    }
    
    @discardableResult
    func set(_ value: Int, forKey defaultName: String) -> TFY {
        base.set(value, forKey: defaultName)
        return self
    }
    
    @discardableResult
    func set(_ value: Double, forKey defaultName: String) -> TFY {
        base.set(value, forKey: defaultName)
        return self
    }
    
    @discardableResult
    func set(_ value: Float, forKey defaultName: String) -> TFY {
        base.set(value, forKey: defaultName)
        return self
    }
    
    @discardableResult
    func set(_ url: URL?, forKey defaultName: String) -> TFY {
        base.set(url, forKey: defaultName)
        return self
    }
    
    @discardableResult
    func synchronize() -> Bool {
        return base.synchronize()
    }
}
