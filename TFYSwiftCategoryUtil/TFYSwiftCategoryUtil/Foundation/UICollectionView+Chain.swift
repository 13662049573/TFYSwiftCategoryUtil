//
//  UICollectionView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UICollectionView {
    
    @discardableResult
    func backgroundView(_ backgroundView: UIView?) -> Self {
        base.backgroundView = backgroundView
        return self
    }
    
    @discardableResult
    func dataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: UICollectionViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func registerCell(_ cellClass: UICollectionViewCell.Type) -> Self {
        base.register(cell: cellClass)
        return self
    }
    
    @discardableResult
    func registerNibCell(_ nibCell: UICollectionViewCell.Type) -> Self {
        base.register(nibCell: nibCell)
        return self
    }
    
    @discardableResult
    func registerHeader(_ viewClass: UICollectionReusableView.Type) -> Self {
        base.register(header: viewClass)
        return self
    }
    
    @discardableResult
    func registerFooter(_ viewClass: UICollectionReusableView.Type) -> Self {
        base.register(footer: viewClass)
        return self
    }
    
    @discardableResult
    func registerNibHeader(_ nibHeader: UICollectionReusableView.Type) -> Self {
        base.register(nibHeader: nibHeader)
        return self
    }
    
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
