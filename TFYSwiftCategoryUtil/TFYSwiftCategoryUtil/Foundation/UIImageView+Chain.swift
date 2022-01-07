//
//  UIImageView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIImageView {
    
    @discardableResult
    func image(_ image: UIImage?) -> TFY {
        base.image = image
        return self
    }
    
    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> TFY {
        base.isHighlighted = isHighlighted
        return self
    }
}
