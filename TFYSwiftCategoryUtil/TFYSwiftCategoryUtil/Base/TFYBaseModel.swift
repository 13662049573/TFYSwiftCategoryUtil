//
//  TFYBaseModel.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/5/6.
//

import UIKit

typealias _modelClass = AnyObject.Type

class TFYBaseModel<ObjectType>: NSObject {

    var allOjects: [Any] = []
    var effectiveObjects: [Any] = []
    
    @discardableResult
    func multiple(count: NSInteger) -> Self {
        var addCount = count - allOjects.count
        while addCount > 0 {
            self.allOjects.append(_modelClass.self)
            addCount -= 1
        }
        return self
    }
}
