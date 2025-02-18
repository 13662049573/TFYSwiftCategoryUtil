//
//  UITableView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UITableView {
    
    @discardableResult
    func backgroundView(_ backgroundView: UIView?) -> Self {
        base.backgroundView = backgroundView
        return self
    }

    @discardableResult
    func dataSource(_ dataSource: UITableViewDataSource?) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: UITableViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func rowHeight(_ rowHeight: CGFloat) -> Self {
        base.rowHeight = rowHeight
        return self
    }
    
    @discardableResult
    func sectionHeaderHeight(_ sectionHeaderHeight: CGFloat) -> Self {
        base.sectionHeaderHeight = sectionHeaderHeight
        return self
    }
    
    @discardableResult
    func sectionFooterHeight(_ sectionFooterHeight: CGFloat) -> Self {
        base.sectionFooterHeight = sectionFooterHeight
        return self
    }
    
    @discardableResult
    func estimatedRowHeight(_ estimatedRowHeight: CGFloat) -> Self {
        base.estimatedRowHeight = estimatedRowHeight
        return self
    }
    
    @discardableResult
    func estimatedSectionHeaderHeight(_ estimatedSectionHeaderHeight: CGFloat) -> Self {
        base.estimatedSectionHeaderHeight = estimatedSectionHeaderHeight
        return self
    }
    
    @discardableResult
    func estimatedSectionFooterHeight(_ estimatedSectionFooterHeight: CGFloat) -> Self {
        base.estimatedSectionFooterHeight = estimatedSectionFooterHeight
        return self
    }
    
    @discardableResult
    func sectionIndexColor(_ sectionIndexColor: UIColor?) -> Self {
        base.sectionIndexColor = sectionIndexColor
        return self
    }
    
    @discardableResult
    func sectionIndexBackgroundColor(_ sectionIndexBackgroundColor: UIColor?) -> Self {
        base.sectionIndexBackgroundColor = sectionIndexBackgroundColor
        return self
    }
    
    @discardableResult
    func sectionIndexTrackingBackgroundColor(_ sectionIndexTrackingBackgroundColor: UIColor?) -> Self {
        base.sectionIndexTrackingBackgroundColor = sectionIndexTrackingBackgroundColor
        return self
    }
    
    @discardableResult
    func sectionIndexMinimumDisplayRowCount(_ sectionIndexMinimumDisplayRowCount: Int) -> Self {
        base.sectionIndexMinimumDisplayRowCount = sectionIndexMinimumDisplayRowCount
        return self
    }
    
    @discardableResult
    func separatorStyle(_ separatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        base.separatorStyle = separatorStyle
        return self
    }

    @discardableResult
    func separatorColor(_ separatorColor: UIColor?) -> Self {
        base.separatorColor = separatorColor
        return self
    }
    
    @discardableResult
    func separatorInset(_ separatorInset: UIEdgeInsets) -> Self {
        base.separatorInset = separatorInset
        return self
    }
    
    @discardableResult
    func separatorInset(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        base.separatorInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func tableHeaderView(_ tableHeaderView: UIView?) -> Self {
        base.tableHeaderView = tableHeaderView
        return self
    }
    
    @discardableResult
    func tableFooterView(_ tableFooterView: UIView?) -> Self {
        base.tableFooterView = tableFooterView
        return self
    }
    
    @discardableResult
    func registerNibCell(_ nib: UITableViewCell.Type) -> Self {
        base.register(nibCell: nib)
        return self
    }
    
    @discardableResult
    func registerCell(_ cellClass: UITableViewCell.Type) -> Self {
        base.register(cell: cellClass)
        return self
    }
    
    @discardableResult
    func registerNibHeaderOrFooter(_ nib: UITableViewHeaderFooterView.Type) -> Self {
        base.register(nibHeaderOrFooter: nib)
        return self
    }
    
    @discardableResult
    func registerHeaderOrFooter(_ aClass: UITableViewHeaderFooterView.Type) -> Self {
        base.register(headerOrFooter: aClass)
        return self
    }
    
    @discardableResult
    func estimatedAll(_ height:CGFloat = CGFloat.leastNormalMagnitude) -> Self {
        if #available(iOS 11.0, *) {
            base.contentInsetAdjustmentBehavior = .never
            base.estimatedRowHeight = height
            base.estimatedSectionHeaderHeight = height
            base.estimatedSectionFooterHeight = height
        }else{
            let height = height >= 2 ? height : 2
            base.estimatedRowHeight = height
            base.estimatedSectionHeaderHeight = height
            base.estimatedSectionFooterHeight = height
        }
        base.rowHeight = UITableView.automaticDimension
        base.sectionHeaderHeight = UITableView.automaticDimension
        base.sectionFooterHeight = UITableView.automaticDimension
        return self
    }
    
    @available(iOS 10.0, *)
    @discardableResult
    func prefetchDataSource(dataSource d: UITableViewDataSourcePrefetching?) -> Self {
        base.prefetchDataSource = d
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func dropDelegate(delegate d: UITableViewDropDelegate?) -> Self {
        base.dropDelegate = d
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func separatorInsetReference(insetReference i: UITableView.SeparatorInsetReference) -> Self {
        base.separatorInsetReference = i
        return self
    }
    
}

extension UITableView {
    // MARK: - 注册方法
    public func register<C: RawRepresentable>(nibHeaderOrFooter reused: C) where C.RawValue == String {
        register(reused.nib(), forHeaderFooterViewReuseIdentifier: reused.rawValue)
    }
    
    public func register<C: UITableViewHeaderFooterView>(headerOrFooter clz: C.Type) {
        register(clz, forHeaderFooterViewReuseIdentifier: identifier(for: clz))
    }
    
    public func register<C: UITableViewHeaderFooterView>(nibHeaderOrFooter clz: C.Type) {
        register(identifier(for: clz).nib(), forHeaderFooterViewReuseIdentifier: identifier(for: clz))
    }
    
    public func register<C: RawRepresentable>(nibCell reused: C) where C.RawValue == String {
        register(reused.nib(), forCellReuseIdentifier: reused.rawValue)
    }
    
    public func register<C: UITableViewCell>(cell clz: C.Type) {
        register(clz, forCellReuseIdentifier: identifier(for: clz))
    }
    
    public func register<C: UITableViewCell>(nibCell clz: C.Type) {
        register(identifier(for: clz).nib(), forCellReuseIdentifier: identifier(for: clz))
    }
    
    // MARK: - 复用方法
    public func dequeueReusable<C: RawRepresentable>(cell reused: C, for indexPath: IndexPath) -> UITableViewCell where C.RawValue == String {
        dequeueReusableCell(withIdentifier: reused.rawValue, for: indexPath)
    }
    
    public func dequeueReusable<C: UITableViewCell>(cell clz: C.Type, for indexPath: IndexPath) -> C {
        guard let cell = dequeueReusableCell(withIdentifier: identifier(for: clz), for: indexPath) as? C else {
            fatalError("Failed to dequeue cell with identifier: \(identifier(for: clz))")
        }
        return cell
    }
    
    public func dequeueReusable<C: RawRepresentable>(headerOrFooter reused: C) -> UITableViewHeaderFooterView? where C.RawValue == String {
        dequeueReusableHeaderFooterView(withIdentifier: reused.rawValue)
    }
    
    public func dequeueReusable<C: UITableViewHeaderFooterView>(headerOrFooter clz: C.Type) -> C? {
        dequeueReusableHeaderFooterView(withIdentifier: identifier(for: clz)) as? C
    }
    
    // MARK: - 更新操作
    public func update(with block: (_ tableView: UITableView) -> Void) {
        beginUpdates()
        block(self)
        endUpdates()
    }
    
    // MARK: - 滚动操作
    public func scrollTo(row: Int, in section: Int, at position: UITableView.ScrollPosition, animated: Bool) {
        guard section < numberOfSections, row < numberOfRows(inSection: section) else { return }
        let indexPath = IndexPath(row: row, section: section)
        scrollToRow(at: indexPath, at: position, animated: animated)
    }
    
    // MARK: - 增删改操作
    public func insert(row: Int, in section: Int, with rowAnimation: UITableView.RowAnimation) {
        insert(at: IndexPath(row: row, section: section), with: rowAnimation)
    }
    
    public func reload(row: Int, in section: Int, with rowAnimation: UITableView.RowAnimation) {
        reload(at: IndexPath(row: row, section: section), with: rowAnimation)
    }
    
    public func delete(row: Int, in section: Int, with rowAnimation: UITableView.RowAnimation) {
        delete(at: IndexPath(row: row, section: section), with: rowAnimation)
    }
    
    public func insert(at indexPath: IndexPath, with rowAnimation: UITableView.RowAnimation) {
        insertRows(at: [indexPath], with: rowAnimation)
    }
    
    public func reload(at indexPath: IndexPath, with rowAnimation: UITableView.RowAnimation) {
        reloadRows(at: [indexPath], with: rowAnimation)
    }
    
    public func delete(at indexPath: IndexPath, with rowAnimation: UITableView.RowAnimation) {
        deleteRows(at: [indexPath], with: rowAnimation)
    }
    
    public func reload(section: Int, with rowAnimation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integer: section), with: rowAnimation)
    }
    
    // MARK: - 选择操作
    public func clearSelectedRows(animated: Bool) {
        indexPathsForSelectedRows?.forEach { deselectRow(at: $0, animated: animated) }
    }
    
    // MARK: - 辅助方法
    public func reloadCell(_ cell: UITableViewCell, with animation: UITableView.RowAnimation) {
        guard let indexPath = indexPath(for: cell) else { return }
        reloadRows(at: [indexPath], with: animation)
    }
    
    public func scrollToBottom(position: UITableView.ScrollPosition = .bottom, animated: Bool = true) {
        guard numberOfSections > 0 else { return }
        
        let lastSection = numberOfSections - 1
        guard numberOfRows(inSection: lastSection) > 0 else { return }
        
        let lastRow = numberOfRows(inSection: lastSection) - 1
        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
        scrollToRow(at: lastIndexPath, at: position, animated: animated)
    }
    
    // MARK: - 新增实用方法
    public func reloadData(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        reloadData()
        CATransaction.commit()
    }
    
    public func isValid(indexPath: IndexPath) -> Bool {
        indexPath.section < numberOfSections && indexPath.row < numberOfRows(inSection: indexPath.section)
    }
    
    // MARK: - 私有方法
    private func identifier(for clz: AnyClass) -> String {
        String(describing: clz).components(separatedBy: ".").last ?? String(describing: clz)
    }
}
