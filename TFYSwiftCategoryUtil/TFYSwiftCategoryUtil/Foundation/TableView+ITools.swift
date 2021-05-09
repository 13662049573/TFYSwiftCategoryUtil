//
//  TableView+ITools.swift
//  TFYCategoryUtil
//
//  Created by 田风有 on 2021/5/4.
//

import Foundation
import UIKit

extension UITableView: TFYCompatible {}

/// MARK ---------------------------------------------------------------  UITableView ---------------------------------------------------------------

extension TFY where Base == UITableView {
    
    /// 代理delegate
    @discardableResult
    func delegate(_ delegate: UITableViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    /// 数组代理
    @discardableResult
    func dataSource(_ dataSource: UITableViewDataSource?) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    /// ios 11 必须设置方式
    func adJustedContentIOS11() -> Void {
        base.estimatedSectionFooterHeight = 0
        base.estimatedSectionHeaderHeight = 0
        base.contentInsetAdjustmentBehavior = .never
    }
    
    /// 行高
    @discardableResult
    func rowHeight(_ rowHeight: CGFloat) -> Self {
        base.rowHeight = rowHeight
        return self
    }
    
    /// 头部高度
    @discardableResult
    func sectionHeaderHeight(_ sectionHeaderHeight: CGFloat) -> Self {
        base.sectionHeaderHeight = sectionHeaderHeight
        return self
    }
    
    /// 尾部行高
    @discardableResult
    func sectionFooterHeight(_ sectionFooterHeight: CGFloat) -> Self {
        base.sectionFooterHeight = sectionFooterHeight
        return self
    }
    
    /// 默认高度
    @discardableResult
    func estimatedRowHeight(_ estimatedRowHeight: CGFloat) -> Self {
        base.estimatedRowHeight = estimatedRowHeight
        return self
    }
    
    /// 默认是UITableViewAutomaticDimension，设置为0禁用
    @discardableResult
    func estimatedSectionHeaderHeight(_ sectionHeaderHeight: CGFloat) -> Self {
        base.estimatedSectionHeaderHeight = sectionHeaderHeight
        return self
    }
    
    /// default is UITableViewAutomaticDimension, set to 0 to disable
    @discardableResult
    func estimatedSectionFooterHeight(_ sectionFooterHeight: CGFloat) -> Self {
        base.estimatedSectionFooterHeight = sectionFooterHeight
        return self
    }
    
    /// 线条内边际设置
    @discardableResult
    func separatorInset(_ Inset: UIEdgeInsets) -> Self {
        base.separatorInset = Inset
        return self
    }
    
    /// Vertical 边框线条
    @discardableResult
    func showsVerticalScrollIndicator(_ vertical: Bool) -> Self {
        base.showsVerticalScrollIndicator = vertical
        return self
    }
    
    /// Horizontal 边框线条
    @discardableResult
    func showsHorizontalScrollIndicator(_ horizontal: Bool) -> Self {
        base.showsHorizontalScrollIndicator = horizontal
        return self
    }
    
    /// 是否开启编辑
    @discardableResult
    func editing(_ editing: Bool) -> Self {
        base.isEditing = editing
        return self
    }
    
    /// 带动画编辑
    @discardableResult
    func setEditing(_ editing: Bool,animated: Bool) -> Self {
        base.setEditing(editing, animated: animated)
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
    
    /// 默认是否定的。控制在编辑模式下是否可以选择行
    @discardableResult
    func allowsSelectionDuringEditing(_ allowsEditing: Bool) -> Self {
        base.allowsSelectionDuringEditing = allowsEditing
        return self
    }
    
    /// 默认是否定的。控制在编辑模式下是否可以同时选择多行
    @discardableResult
    func allowsMultipleSelectionDuringEditing(_ allowsMultipleSelection: Bool) -> Self {
        base.allowsMultipleSelectionDuringEditing = allowsMultipleSelection
        return self
    }
    
    /// cell 点击状态
    @discardableResult
    func separatorStyle(_ style: UITableViewCell.SeparatorStyle) -> Self {
        base.separatorStyle = style
        return self
    }
    
    /// cell 点击颜色
    @discardableResult
    func separatorColor(_ color: UIColor?) -> Self {
        base.separatorColor = color
        return self
    }
    
    /// 以上行内容的附件视图。默认是零。不要与节标题混淆
    @discardableResult
    func tableHeaderView(_ view: UIView?) -> Self {
        base.tableHeaderView = view
        return self
    }
    
    /// 附件视图下面的内容。默认是零。不要与节页脚混淆
    @discardableResult
    func tableFooterView(_ view: UIView?) -> Self {
        base.tableFooterView = view
        return self
    }
    
    /// 未被修改的节索引的背景色
    @discardableResult
    func sectionIndexBackgroundColor(_ color: UIColor?) -> Self {
        base.sectionIndexBackgroundColor = color
        return self
    }
    
    /// 区段索引文本所用的颜色
    @discardableResult
    func sectionIndexColor(_ color: UIColor?) -> Self {
        base.sectionIndexColor = color
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
    
    /// 注册一个基于nib的' UITableViewCell '子类(符合' TFYReusable ' & ' TFYNibLoadable ')
    @discardableResult
    func register<T: UITableViewCell>(cellType: T.Type) -> Self where T: TFYReusable & TFYNibLoadable {
        base.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
        return self
    }
    
    ///注册一个基于类的' UITableViewCell '子类(符合' Reusable ')
    @discardableResult
    func register<T: UITableViewCell>(cellType: T.Type) -> Self where T: TFYReusable {
        base.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
        return self
    }
    
    /// 为由返回类型推断的类返回一个可重用的' UITableViewCell '对象
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T
      where T: TFYReusable {
        guard let cell = base.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
          fatalError(
            "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
              + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
              + "and that you registered the cell beforehand"
          )
        }
        return cell
    }
    
    /// 注册一个基于nib的' UITableViewHeaderFooterView '子类(符合' TFYReusable ' & ' TFYNibLoadable ')
    @discardableResult
    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) -> Self
      where T: TFYReusable & TFYNibLoadable {
        base.register(headerFooterViewType.nib, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
        return self
    }
    
    /// 注册一个基于类的' UITableViewHeaderFooterView '子类(符合'可重用')
    @discardableResult
    func register<T: UITableViewHeaderFooterView>(headerFooterViewType: T.Type) -> Self
      where T: TFYReusable {
        base.register(headerFooterViewType.self, forHeaderFooterViewReuseIdentifier: headerFooterViewType.reuseIdentifier)
        return self
    }

    /// 返回一个可重用的' UITableViewHeaderFooterView '对象，用于由返回类型推断的类
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type = T.self) -> T?
      where T: TFYReusable {
        guard let view = base.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T? else {
          fatalError(
            "Failed to dequeue a header/footer with identifier \(viewType.reuseIdentifier) "
              + "matching type \(viewType.self). "
              + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
              + "and that you registered the header/footer beforehand"
          )
        }
        return view
    }
}

