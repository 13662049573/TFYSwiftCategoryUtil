//
//  UIPickerView+TFY.swift
//  CocoaChainKit
//
//  Created by GorXion on 2018/5/11.
//
import UIKit

public extension TFY where Base: UIPickerView {
    
    @discardableResult
    func dataSource(_ dataSource: UIPickerViewDataSource?) -> TFY {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: UIPickerViewDelegate?) -> TFY {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func showsSelectionIndicator(_ showsSelectionIndicator: Bool) -> TFY {
        base.showsSelectionIndicator = showsSelectionIndicator
        return self
    }
}
