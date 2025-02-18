//
//  UIPickerView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIPickerView {
    
    @discardableResult
    func dataSource(_ dataSource: UIPickerViewDataSource?) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: UIPickerViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }

}
