//
//  UIButton+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIButton {
    
    @discardableResult
    func title(_ title: String?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setTitle(title, for: $0) }
        return self
    }
    
    @discardableResult
    func titleColor(_ color: UIColor?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setTitleColor(color, for: $0) }
        return self
    }
    
    @discardableResult
    func image(_ image: UIImage?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setImage(image, for: $0) }
        return self
    }
    
    @discardableResult
    func backgroundImage(_ image: UIImage?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setBackgroundImage(image, for: $0) }
        return self
    }
    
    @discardableResult
    func attributedTitle(_ attributedTitle: NSAttributedString?, for state: UIControl.State...) -> TFY {
        state.forEach { base.setAttributedTitle(attributedTitle, for: $0) }
        return self
    }
    
    @discardableResult
    func titleEdgeInsets(_ edgeInsets: UIEdgeInsets) -> TFY {
        base.titleEdgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    func titleEdgeInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> TFY {
        base.titleEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func imageEdgeInsets(_ edgeInsets: UIEdgeInsets) -> TFY {
        base.imageEdgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    func imageEdgeInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> TFY {
        base.imageEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func contentHorizontalAlignment(_ alignment:UIControl.ContentHorizontalAlignment) -> TFY {
        base.contentHorizontalAlignment = alignment
        return self
    }
    
    @discardableResult
    func imageDirection(_ direction:UIButton.ButtonImageDirection,_ space:CGFloat) -> TFY {
        base.imageDirection(direction, space)
        return self
    }
    
}

extension UIButton {
    
    public enum ButtonImageDirection:Int {
        case ButtonImageDirectionTop = 0
        case ButtonImageDirectionLeft = 1
        case ButtonImageDirectionRight = 2
        case ButtonImageDirectionBottom = 3
    }
    
    func imageDirection(_ type:ButtonImageDirection ,_ space:CGFloat) {
        let imageWidth:CGFloat = currentImage?.size.width ?? 0.0
        let imageHeight:CGFloat = currentImage?.size.height ?? 0.0
        titleLabel?.sizeToFit()
        
        let textWidth:CGFloat = titleLabel?.frame.size.width ?? 0.0
        let textHeight:CGFloat = titleLabel?.frame.size.height ?? 0.0
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        let spaceValue:CGFloat = space/2

        switch type {
        case .ButtonImageDirectionTop:
            x = textHeight / 2 + spaceValue;
            y = textWidth / 2;
            imageEdgeInsets = UIEdgeInsets(top: -x, left: y, bottom: x, right: -y)
            x = imageHeight / 2 + spaceValue;
            y = imageWidth / 2;
            titleEdgeInsets = UIEdgeInsets(top: x, left: -y, bottom: -x, right: y)
            break
        case.ButtonImageDirectionBottom:
            x = textHeight / 2 + spaceValue;
            y = textWidth / 2;
            imageEdgeInsets = UIEdgeInsets(top: x, left: y, bottom: -x, right: -y)
            x = imageHeight / 2 + spaceValue;
            y = imageWidth / 2;
            titleEdgeInsets = UIEdgeInsets(top: -x, left: -y, bottom: x, right: y)
            break
        case.ButtonImageDirectionLeft:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spaceValue, bottom: 0, right: spaceValue)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: spaceValue, bottom: 0, right: -spaceValue)
            break
        case.ButtonImageDirectionRight:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: spaceValue + textWidth, bottom: 0, right: -(spaceValue + textWidth))
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(spaceValue + imageWidth), bottom: 0, right: (spaceValue + imageWidth))
            break
        }
    }
    
}
