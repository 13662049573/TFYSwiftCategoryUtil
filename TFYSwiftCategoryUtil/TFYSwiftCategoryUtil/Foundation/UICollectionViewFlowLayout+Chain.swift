//
//  UICollectionViewFlowLayout+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UICollectionViewFlowLayout {
    
    @discardableResult
    func minimumLineSpacing(_ minimumLineSpacing: CGFloat) -> Self {
        base.minimumLineSpacing = minimumLineSpacing
        return self
    }
    
    @discardableResult
    func minimumInteritemSpacing(_ minimumInteritemSpacing: CGFloat) -> Self {
        base.minimumInteritemSpacing = minimumInteritemSpacing
        return self
    }
    
    @discardableResult
    func itemSize(_ itemSize: CGSize) -> Self {
        base.itemSize = itemSize
        return self
    }
    
    @discardableResult
    func itemSize(width: CGFloat, height: CGFloat) -> Self {
        base.itemSize = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    func estimatedItemSize(_ estimatedItemSize: CGSize) -> Self {
        base.estimatedItemSize = estimatedItemSize
        return self
    }
    
    @discardableResult
    func estimatedItemSize(width: CGFloat, height: CGFloat) -> Self {
        base.estimatedItemSize = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    func scrollDirection(_ scrollDirection: UICollectionView.ScrollDirection) -> Self {
        base.scrollDirection = scrollDirection
        return self
    }
    
    @discardableResult
    func headerReferenceSize(_ headerReferenceSize: CGSize) -> Self {
        base.headerReferenceSize = headerReferenceSize
        return self
    }
    
    @discardableResult
    func headerReferenceSize(width: CGFloat, height: CGFloat) -> Self {
        base.headerReferenceSize = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    func footerReferenceSize(_ footerReferenceSize: CGSize) -> Self {
        base.footerReferenceSize = footerReferenceSize
        return self
    }
    
    @discardableResult
    func footerReferenceSize(width: CGFloat, height: CGFloat) -> Self {
        base.footerReferenceSize = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    func sectionInset(_ sectionInset: UIEdgeInsets) -> Self {
        base.sectionInset = sectionInset
        return self
    }
    
    @discardableResult
    func sectionInset(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        base.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
}
