//
//  UIResponder+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/7/13.
//
import UIKit

public extension TFY where Base: UIResponder {
    
    @discardableResult
    func becomeFirstResponder() -> TFY {
        base.becomeFirstResponder()
        return self
    }
    
    @discardableResult
    func resignFirstResponder() -> TFY {
        base.resignFirstResponder()
        return self
    }
}
