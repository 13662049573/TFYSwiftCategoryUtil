//
//  UIStackView+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/22.
//

import Foundation
import UIKit

public extension TFY where Base: UIStackView {
    
    @discardableResult
    func addArranged(subview view: UIView) -> Self {
        base.addArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func removeArranged(subview view: UIView) -> Self {
        base.removeArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func insertArranged(subview view: UIView, at:Int) -> Self {
        base.insertArrangedSubview(view, at: at)
        return self
    }
    
    @discardableResult
    func axis(_ a: NSLayoutConstraint.Axis) -> Self {
        base.axis = a
        return self
    }
    
    @discardableResult
    func distribution(_ a: UIStackView.Distribution) -> Self {
        base.distribution = a
        return self
    }
    
    @discardableResult
    func alignment(_ a: UIStackView.Alignment) -> Self {
        base.alignment = a
        return self
    }

    @discardableResult
    func spacing(_ a: CGFloat) -> Self {
        base.spacing = a
        return self
    }
    
    @discardableResult
    @available(iOS 11.0, *)
    func custom(_ spacing: CGFloat, after arrangedSubview: UIView) -> Self {
        base.setCustomSpacing(spacing, after: arrangedSubview)
        return self
    }
    
    @discardableResult
    func isBaselineRelativeArrangement(_ a: Bool) -> Self {
        base.isBaselineRelativeArrangement = a
        return self
    }
    
    @discardableResult
    func isLayoutMarginsRelativeArrangement(_ a: Bool) -> Self {
        base.isLayoutMarginsRelativeArrangement = a
        return self
    }
}
