//
//  Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public struct TFY<Base> {
    
    public let base: Base
    
    public var build: Base {
        return base
    }
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol TFYCompatible {
    
    associatedtype CompatibleType
    
    var tfy: CompatibleType { get }
}

public extension TFYCompatible {
    
    var tfy: TFY<Self> {
        return TFY(self)
    }
}

extension NSObject: TFYCompatible {}
