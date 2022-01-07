//
//  UILabel+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UILabel {
    
    @discardableResult
    func shadowColor(_ shadowColor: UIColor?) -> TFY {
        base.shadowColor = shadowColor
        return self
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset: CGSize) -> TFY {
        base.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func shadowOffset(width: CGFloat, height: CGFloat) -> TFY {
        base.shadowOffset = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    func numberOfLines(_ numberOfLines: Int) -> TFY {
        base.numberOfLines = numberOfLines
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> TFY {
        base.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
}
