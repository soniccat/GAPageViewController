//
//  PagerCell.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 19.02.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

open class GAPagerCell: UICollectionViewCell {
    open var controller: UIViewController?
    private var isDisappearing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        if let ctrl = self.controller {
            gaLog("prepareForReuse %p", ctrl)
        }
    }
    
    open func startAddingController(ct: UIViewController, animated: Bool) {
        controller = ct
        prepareController(controller: ct)
        
        if needPassAppearEvents() {
            ct.beginAppearanceTransition(true, animated: animated)
            isDisappearing = false
        }
        
        addSubview(ct.view)
    }
    
    private func prepareController(controller: UIViewController) {
        controller.view.frame = self.bounds
        controller.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        controller.view.translatesAutoresizingMaskIntoConstraints = true
    }
    
    open func finishAddingController() {
        if needPassAppearEvents() {
            self.controller!.endAppearanceTransition()
        }
    }
    
    open func startRemovingController(animated: Bool) {
        // We use isDisappearing flag to handle a situation when we swipe long in a one direction
        // and then swipe long in another direction while the scrollView is decelerating
        // If we start with page 0 after the first swipe we will get willDisappear for the page 1 to start showing page 2
        // and after the the second swipe we will get willDisappear again for the page 1 to start showing page 2
        // When we call more than one beginAppearanceTransition with false isAppearing in a row we have to call
        // the same amount of endAppearanceTransition to trigger viewDidDisappear
        // Here we avoid that possible double call of beginAppearanceTransition with false isAppearing
        
        if needPassAppearEvents() && !isDisappearing {
            self.controller!.beginAppearanceTransition(false, animated: animated)
            isDisappearing = true
        }
    }
    
    open func finishRemovingController() {
        self.controller!.view.removeFromSuperview()
        
        let v: Int = needPassAppearEvents() ? 1 : 0
        gaLog("finishRemovingController %d", v)
        
        if needPassAppearEvents() {
            self.controller!.endAppearanceTransition()
            isDisappearing = false
        }
        
        self.controller?.removeFromParentViewController()
        self.controller = nil
    }
    
    private func needPassAppearEvents() -> Bool {
        return self.window != nil && self.superview != nil
    }
}
