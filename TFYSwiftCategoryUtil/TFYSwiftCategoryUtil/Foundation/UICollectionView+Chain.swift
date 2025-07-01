//
//  UICollectionView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//  优化：参数安全性检查、注释补全、健壮性提升
//

import UIKit

public extension TFY where Base: UICollectionView {
    /// 设置背景视图
    @discardableResult
    func backgroundView(_ backgroundView: UIView?) -> Self {
        base.backgroundView = backgroundView
        return self
    }
    /// 设置数据源
    @discardableResult
    func dataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        base.dataSource = dataSource
        return self
    }
    /// 设置代理
    @discardableResult
    func delegate(_ delegate: UICollectionViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    /// 注册Cell类
    @discardableResult
    func registerCell(_ cellClass: UICollectionViewCell.Type) -> Self {
        base.register(cell: cellClass)
        return self
    }
    /// 注册Nib Cell
    @discardableResult
    func registerNibCell(_ nibCell: UICollectionViewCell.Type) -> Self {
        base.register(nibCell: nibCell)
        return self
    }
    /// 注册Header类
    @discardableResult
    func registerHeader(_ viewClass: UICollectionReusableView.Type) -> Self {
        base.register(header: viewClass)
        return self
    }
    /// 注册Footer类
    @discardableResult
    func registerFooter(_ viewClass: UICollectionReusableView.Type) -> Self {
        base.register(footer: viewClass)
        return self
    }
    /// 注册Nib Header
    @discardableResult
    func registerNibHeader(_ nibHeader: UICollectionReusableView.Type) -> Self {
        base.register(nibHeader: nibHeader)
        return self
    }
    /// 注册Nib Footer
    @discardableResult
    func registerNibFooter(_ nibFooter: UICollectionReusableView.Type) -> Self {
        base.register(nibFooter: nibFooter)
        return self
    }
}

extension UICollectionView {
    // MARK: - 安全注册方法
    private func safeIdentifier<C>(for clz: C.Type) -> String {
        let fullName = String(describing: clz)
        guard let validIdentifier = fullName.components(separatedBy: ".").last else {
            fatalError("⚠️ 无效的类名格式: \(fullName)")
        }
        return validIdentifier
    }

    // MARK: - Cell注册
    public func register<C: UICollectionViewCell>(cell clz: C.Type) {
        let identifier = safeIdentifier(for: clz)
        register(clz, forCellWithReuseIdentifier: identifier)
    }
    
    public func register<C: UICollectionViewCell>(nibCell clz: C.Type) {
        let identifier = safeIdentifier(for: clz)
        register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }

    // MARK: - 补充视图注册
    public func register<C: UICollectionReusableView>(
        header clz: C.Type,
        kind: String = UICollectionView.elementKindSectionHeader
    ) {
        let identifier = safeIdentifier(for: clz)
        register(clz, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    public func register<C: UICollectionReusableView>(
        footer clz: C.Type,
        kind: String = UICollectionView.elementKindSectionFooter
    ) {
        let identifier = safeIdentifier(for: clz)
        register(clz, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }

    public func register<C: UICollectionReusableView>(
        nibHeader clz: C.Type,
        kind: String = UICollectionView.elementKindSectionHeader
    ) {
        let identifier = safeIdentifier(for: clz)
        register(UINib(nibName: identifier, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    public func register<C: UICollectionReusableView>(
        nibFooter clz: C.Type,
        kind: String = UICollectionView.elementKindSectionFooter
    ) {
        let identifier = safeIdentifier(for: clz)
        register(UINib(nibName: identifier, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }

    // MARK: - 安全获取方法
    public func dequeueReusable<C: UICollectionViewCell>(cell clz: C.Type, for indexPath: IndexPath) -> C {
        let identifier = safeIdentifier(for: clz)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? C else {
            fatalError("⚠️ 未注册的Cell类型: \(identifier)")
        }
        return cell
    }

    public func dequeueReusable<C: UICollectionReusableView>(
        header clz: C.Type,
        for indexPath: IndexPath,
        kind: String = UICollectionView.elementKindSectionHeader
    ) -> C {
        let identifier = safeIdentifier(for: clz)
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? C else {
            fatalError("⚠️ 未注册的Header类型: \(identifier)")
        }
        return view
    }
    
    public func dequeueReusable<C: UICollectionReusableView>(
        footer clz: C.Type,
        for indexPath: IndexPath,
        kind: String = UICollectionView.elementKindSectionFooter
    ) -> C {
        let identifier = safeIdentifier(for: clz)
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? C else {
            fatalError("⚠️ 未注册的Footer类型: \(identifier)")
        }
        return view
    }
}
