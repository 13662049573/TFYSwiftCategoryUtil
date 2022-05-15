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

open class UICircleImageView: UICornerImageView {
    
    open override func layoutSubviews() {
        cornerRadii.width = bounds.width / 2
        cornerRadii.height = bounds.height / 2
        super.layoutSubviews()
    }
    
}

@IBDesignable
open class UICornerImageView: UIImageView {
    
    @IBInspectable open var cornerRadii:CGSize = .zero {
        didSet { cornerImage() }
    }
    @IBInspectable open var corners:UIRectCorner = .allCorners {
        didSet { cornerImage() }
    }

    private var _image:UIImage? = nil
    open override var image: UIImage? {
        get { return _image }
        set {
            _image = newValue
            cornerImage()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.size
        if  size != oldSize {
            cornerImage()
        }
    }
    
    private lazy var oldSize:CGSize = frame.size
    
    private func cornerImage() {
        let rect = bounds
        let size = rect.size
        oldSize = size

        super.image = _image
        
        if _image == nil { return }
        
        let opaque:Bool = backgroundColor != nil && backgroundColor != .clear
        let scale:CGFloat = 0

        // 开始对imageView进行画图
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        if opaque {
            backgroundColor!.setFill()
            UIRectFill(bounds)
        }
        // 实例化一个圆形的路径
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
        //  进行路劲裁切   后续的绘图都会出现在圆形内  外部的都被干掉
        path.addClip()
        draw(rect)
        //  取到结果
        super.image = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
    }
    
}
