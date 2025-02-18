//
//  UIScrollView+TFY.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2021/5/10.
//

import UIKit

public extension TFY where Base: UIScrollView {
    
    @discardableResult
    func delegate(_ delegate: UIScrollViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func contentOffset(_ contentOffset: CGPoint) -> Self {
        base.contentOffset = contentOffset
        return self
    }
    
    @discardableResult
    func contentOffset(x: CGFloat, y: CGFloat) -> Self {
        base.contentOffset = CGPoint(x: x, y: y)
        return self
    }
    
    @discardableResult
    func contentSize(_ contentSize: CGSize) -> Self {
        base.contentSize = contentSize
        return self
    }
    
    @discardableResult
    func contentSize(width: CGFloat, height: CGFloat) -> Self {
        base.contentSize = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    func contentInset(_ contentInset: UIEdgeInsets) -> Self {
        base.contentInset = contentInset
        return self
    }
    
    @discardableResult
    func contentInset(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        base.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func contentInsetAdjustmentBehavior(_ contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        base.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        return self
    }
    
    @discardableResult
    func isDirectionalLockEnabled(_ isDirectionalLockEnabled: Bool) -> Self {
        base.isDirectionalLockEnabled = isDirectionalLockEnabled
        return self
    }
    
    @discardableResult
    func bounces(_ bounces: Bool) -> Self {
        base.bounces = bounces
        return self
    }
    
    @discardableResult
    func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        base.alwaysBounceVertical = alwaysBounceVertical
        return self
    }
    
    @discardableResult
    func alwaysBounceHorizontal(_ alwaysBounceHorizontal: Bool) -> Self {
        base.alwaysBounceHorizontal = alwaysBounceHorizontal
        return self
    }
    
    @discardableResult
    func isPagingEnabled(_ isPagingEnabled: Bool) -> Self {
        base.isPagingEnabled = isPagingEnabled
        return self
    }
    
    @discardableResult
    func isScrollEnabled(_ isScrollEnabled: Bool) -> Self {
        base.isScrollEnabled = isScrollEnabled
        return self
    }
    
    @discardableResult
    func showsHorizontalScrollIndicator(_ showsHorizontalScrollIndicator: Bool) -> Self {
        base.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        return self
    }
    
    @discardableResult
    func showsVerticalScrollIndicator(_ showsVerticalScrollIndicator: Bool) -> Self {
        base.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        return self
    }
    
    @discardableResult
    func scrollIndicatorInsets(_ scrollIndicatorInsets: UIEdgeInsets) -> Self {
        base.scrollIndicatorInsets = scrollIndicatorInsets
        return self
    }
    
    @discardableResult
    func scrollIndicatorInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        base.scrollIndicatorInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func bounces(bounces b: Bool) -> Self {
        base.bounces = b
        return self
    }
    
    @discardableResult
    func indicatorStyle(style s: UIScrollView.IndicatorStyle) -> Self {
        base.indicatorStyle = s
        return self
    }
    
    @discardableResult
    func decelerationRate(rate r: UIScrollView.DecelerationRate) -> Self {
        base.decelerationRate = r
        return self
    }
    
    @discardableResult
    func indexDisplayMode(displayMode m: UIScrollView.IndexDisplayMode) -> Self {
        base.indexDisplayMode = m
        return self
    }
    
    @discardableResult
    func setContentOffset(contentOffset p:CGPoint, _ animated:Bool = true) -> Self {
        base.setContentOffset(p, animated: animated)
        return self
    }
    
    @discardableResult
    func scrollRectToVisible(rectToVisible r:CGRect, _ animated:Bool = true) -> Self {
        base.scrollRectToVisible(r, animated: animated)
        return self
    }
    
    @discardableResult
    func flashScrollIndicators() -> Self {
        base.flashScrollIndicators()
        return self
    }
    
    @discardableResult
    func delaysContentTouches(contentTouches b:Bool) -> Self {
        base.delaysContentTouches = b
        return self
    }
    
    @discardableResult
    func canCancelContentTouches(contentTouches b:Bool) -> Self {
        base.canCancelContentTouches = b
        return self
    }
    
    @discardableResult
    func bouncesZoom(zoom b:Bool) -> Self {
        base.bouncesZoom = b
        return self
    }
    @discardableResult
    func scrollsToTop(_ b:Bool = true) -> Self {
        base.scrollsToTop = b
        return self
    }
    
    @discardableResult
    func minimumZoomScale(imumZoomScale a:CGFloat) -> Self {
        base.minimumZoomScale = a
        return self
    }
    
    @discardableResult
    func maximumZoomScale(scale a:CGFloat) -> Self {
        base.maximumZoomScale = a
        return self
    }
    
    @discardableResult
    func setZoomScale(zoomScale a:CGFloat, _ animated:Bool = true) -> Self {
        base.setZoomScale(a, animated: animated)
        return self
    }
    
    @discardableResult
    func zoom(toRect a:CGRect, _ animated:Bool = true) -> Self {
        base.zoom(to: a, animated: animated)
        return self
    }
    
    @discardableResult
    func keyboardDismissMode(dismissMode a:UIScrollView.KeyboardDismissMode) -> Self {
        base.keyboardDismissMode = a
        return self
    }
    
    @available(iOS 10.0, *)
    @discardableResult
    func refreshControl(control a:UIRefreshControl?) -> Self {
        base.refreshControl = a
        return self
    }
    
    /// 右滑返回
    @discardableResult
    func panBack(_ gesture: UIGestureRecognizer, otherGesture:UIGestureRecognizer) -> Bool {
        if base.contentOffset.x <= 0,
            let delegate = otherGesture.delegate,
            let fdFulls = NSClassFromString("_FDFullscreenPopGestureRecognizerDelegate").self,
            delegate.isKind(of: fdFulls) {
            return true
        }
        else if gesture == base.panGestureRecognizer,
            let pan:UIPanGestureRecognizer = gesture as? UIPanGestureRecognizer {
            let point = pan.translation(in: base)
            let state = pan.state
            if state == .began || state == .possible {
                let location = pan.location(in: base)
                if point.x >= 0 && location.x < 60 && base.contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
}

public extension UIScrollView {
    
    func scrollToTop(isAnimated: Bool) {
        var off = self.contentOffset
        off.y = 0 - self.contentInset.top
        self.setContentOffset(off, animated: isAnimated)
    }
    
    func scrollToLeft(isAnimated: Bool) {
        var off = self.contentOffset
        off.x = 0 - self.contentInset.left
        self.setContentOffset(off, animated: isAnimated)
    }
    
    func scrollToBottom(isAnimated: Bool) {
        var off = self.contentOffset
        off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom
        self.setContentOffset(off, animated: isAnimated)
    }
    
    func scrollToRight(isAnimated: Bool) {
        var off = self.contentOffset
        off.x = self.contentSize.width - self.bounds.width + self.contentInset.right
        self.setContentOffset(off, animated: isAnimated)
    }
    
    func scrollToTop() {
        scrollToTop(isAnimated: true)
    }
    
    func scrollToLeft() {
        scrollToLeft(isAnimated: true)
    }
    
    func scrollToBottom() {
        scrollToBottom(isAnimated: true)
    }
    
    func scrollToRight() {
        scrollToRight(isAnimated: true)
    }
}
