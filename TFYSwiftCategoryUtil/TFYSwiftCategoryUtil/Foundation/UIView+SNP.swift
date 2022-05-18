//
//  UIView+SNP.swift
//  ECTSESwift
//
//  Created by 田风有 on 2022/5/12.
//  Copyright © 2022 ZHSwift. All rights reserved.
//

import Foundation

#if canImport(SnapKit)
extension TFY where Base: UIView {
    func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        base.snp.makeConstraints(closure)
    }
    
    func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        base.snp.remakeConstraints(closure)
    }
    
    func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        base.snp.updateConstraints(closure)
    }
    
    func removeConstraints() {
        base.snp.removeConstraints()
    }
}
#endif
