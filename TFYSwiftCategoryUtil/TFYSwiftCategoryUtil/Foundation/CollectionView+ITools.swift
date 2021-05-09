//
//  CollectionView+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/5/4.
//

import Foundation
import UIKit

/// MARK ---------------------------------------------------------------  UICollectionView ---------------------------------------------------------------
extension TFY where Base == UICollectionView {
    
    /// 代理delegate
    @discardableResult
    func delegate(_ delegate: UICollectionViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    /// 数组代理
    @discardableResult
    func dataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    /// 默认是肯定的。控制不在编辑模式下是否可以选择行
    @discardableResult
    func allowsSelection(_ selection: Bool) -> Self {
        base.allowsSelection = selection
        return self
    }
    
    /// 默认的是的。如果是，则跳过内容的边缘并返回
    @discardableResult
    func bounces(_ bounces: Bool) -> Self {
        base.bounces = bounces
        return self
    }
    
    /// 默认是否定的。控制是否可以同时选择多个行
    @discardableResult
    func allowsMultipleSelection(_ multipSelection: Bool) -> Self {
        base.allowsMultipleSelection = multipSelection
        return self
    }
    
    /// Layout
    @discardableResult
    func collectionViewLayout(_ layout: UICollectionViewLayout) -> Self {
        base.collectionViewLayout = layout
        return self
    }
    
    /// 添加容器
    @discardableResult
    func addSubview(_ subView: UIView) -> Self {
        subView.addSubview(base)
        return self
    }
    
    /// 背景颜色
    @discardableResult
    func backgroundColor(_ color: UIColor?) -> Self {
        base.backgroundColor = color
        return self
    }
    
    /// 偏移量
    @discardableResult
    func contentSize(_ size: CGSize) -> Self {
        base.contentSize = size
        return self
    }
    
    /// 圆角
    @discardableResult
    func cornerRadius(_ radius:CGFloat) -> Self {
        base.layer.cornerRadius = radius
        return self
    }
    
    
    /// 参数cellType: ' UICollectionViewCell ' (' TFYReusable ' & ' TFYNibLoadable ' - consistency)子类来注册
    @discardableResult
    func register<T: UICollectionViewCell>(cellType:T.Type) -> Self where T:TFYReusable & TFYNibLoadable {
        base.register(cellType.nib, forCellWithReuseIdentifier: cellType.reuseIdentifier)
        return self
    }
    
    ///注册一个基于类的' UICollectionViewCell '子类(符合' TFYReusable ')
    @discardableResult
    func register<T: UICollectionViewCell>(cellType: T.Type) -> Self
      where T: TFYReusable {
        base.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
        return self
    }
    
    ///返回类型推断的类返回一个可重用的' UICollectionViewCell '对象
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
      where T: TFYReusable {
        let bareCell = base.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        guard let cell = bareCell as? T else {
          fatalError(
            "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
              + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
              + "and that you registered the cell beforehand"
          )
        }
        return cell
    }
    
    /// 注册一个基于nib的' UICollectionReusableView '子类(符合' TFYReusable ' & ' TFYNibLoadable ') 作为补充视图
    @discardableResult
    func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) -> Self
      where T: TFYReusable & TFYNibLoadable {
        base.register(
          supplementaryViewType.nib,
          forSupplementaryViewOfKind: elementKind,
          withReuseIdentifier: supplementaryViewType.reuseIdentifier
        )
        return self
    }
    
    /// 注册一个基于类的' UICollectionReusableView '子类(符合' Reusable ')作为补充视图
    @discardableResult
    func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) -> Self
      where T: TFYReusable {
        base.register(
          supplementaryViewType.self,
          forSupplementaryViewOfKind: elementKind,
          withReuseIdentifier: supplementaryViewType.reuseIdentifier
        )
        return self
    }
    
    /// 返回一个可重用的' UICollectionReusableView '对象，用于由返回类型推断的类
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>
      (ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T
      where T: TFYReusable {
        let view = base.dequeueReusableSupplementaryView(
          ofKind: elementKind,
          withReuseIdentifier: viewType.reuseIdentifier,
          for: indexPath
        )
        guard let typedView = view as? T else {
          fatalError(
            "Failed to dequeue a supplementary view with identifier \(viewType.reuseIdentifier) "
              + "matching type \(viewType.self). "
              + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
              + "and that you registered the supplementary view beforehand"
          )
        }
        return typedView
    }
}
