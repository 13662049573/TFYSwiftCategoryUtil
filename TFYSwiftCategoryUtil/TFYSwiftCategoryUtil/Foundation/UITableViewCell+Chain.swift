//
//  UITableViewCell+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/15.
//

import Foundation
import UIKit

public extension UITableViewCell {
    
    func getTableView() -> UITableView? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let tableView = view as? UITableView {
                return tableView
            }
        }
        return nil
    }
    
    func getIndexPath() -> IndexPath? {
        return getTableView()?.indexPath(for: self)
    }
    
    
}
