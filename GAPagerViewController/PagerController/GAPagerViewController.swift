//
//  GAPagerViewController.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 04.03.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

@objc public protocol PagerConrollerViewControllerDataSrouce {
    func pagerControllerNumberOfPages() -> Int
    func pagerControllerBindPage(controller: UIViewController, index: Int)
    func pagerControllerPageIndentifier(index: Int) -> String
    func pagerControllerCreateController(identifier: String) -> UIViewController
}

@objc public protocol PagerConrollerViewControllerDelegate {
    func pagerControllerPageDidChange()
    func pagerControllerWillAppearPage(controller: UIViewController, index: Int)
    func pagerControllerWillDisappearPage(controller: UIViewController, index: Int)
    func pagerControllerDidAppearPage(controller: UIViewController, index: Int)
    func pagerControllerDidDisappearPage(controller: UIViewController, index: Int)
    func pagerControllerIndexChanged(controller: UIViewController, newIndex: Int)
}

open class GAPagerViewController: GABasePagerViewController {
    private let CellIdentifier = "PagerCell"
    private var queue = GAReuseQueue()
    private var bindedControllers:[Int:UIViewController] = [:]
    //private var deletingControllers:[Int:UIViewController] = [:]
    
    // Define how many additional controllers we want to keep in the memory
    public var bindControllerRange = 1 {
        didSet {
            updateBindedControllers()
        }
    }
    
    public var datasource: PagerConrollerViewControllerDataSrouce!
    public var delegate: PagerConrollerViewControllerDelegate?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        baseInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        baseInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    private func baseInit() {
        bindDelegate()
    }
    
    private func bindDelegate() {
        queue.delegate = self
    }
    
    override open func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        var i = 0;
        for controller in bindedControllers.values {
            controller.restorationIdentifier = String(format: "%d", i)
            i += 1
        }
        
        coder.encode(bindedControllers, forKey: "bindedControllers")
    }
    
    override open func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        bindedControllers = coder.decodeObject(forKey: "bindedControllers") as! [Int : UIViewController]
    }
    
    // force controller binding
    private func prebindControllers() {
        let minIndex = max(0, currentIndex - bindControllerRange)
        let maxIndex = min(collectionView.numberOfItems(inSection: 0) - 1, currentIndex + bindControllerRange)
        
        for i in minIndex ... maxIndex {
            if bindedControllers[i] == nil {
                bindController(index: i)
            }
        }
    }
    
    // MARK: Overrides
    
    open override func registerCells() {
        collectionView.register(GAPagerCell.self, forCellWithReuseIdentifier: CellIdentifier)
    }
    
    open override func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath)
    }
    
    
    override open func onPageChange() {
        updateBindedControllers()
        prebindControllers()
        delegate?.pagerControllerPageDidChange()
    }
    
    override open func numberOfPage() -> Int {
        return datasource.pagerControllerNumberOfPages()
    }
    
    override open func bindPage(cell: UICollectionViewCell, index: Int) {
        prebindControllers()
        // we set controller for the cell in startAddingController
    }
    
    private func bindController(index: Int) {
        let controller = ensuredPageController(index: index)
        prepareController(controller: controller)
        datasource.pagerControllerBindPage(controller: controller, index: index)
        addBindedController(index: index, controller: controller)
    }
    
    override open func pageWillAppear(cell: UICollectionViewCell, index: Int) {
        let pagerCell = cell as! GAPagerCell
        
        startAddingControllerIfNeeded(cell: pagerCell, index: index)
        delegate?.pagerControllerWillAppearPage(controller: pagerCell.controller!, index: index)
    }
    
    override open func pageDidAppear(cell: UICollectionViewCell, index: Int) {
        let pagerCell = cell as! GAPagerCell
        
        finishAddingController(cell: pagerCell, index: index)
        delegate?.pagerControllerDidAppearPage(controller: pagerCell.controller!, index: index)
    }
    
    override open func pageWillDisappear(cell: UICollectionViewCell, index: Int) {
        let pagerCell = cell as! GAPagerCell
        
        startRemovingController(cell: pagerCell, index: index)
        delegate?.pagerControllerWillDisappearPage(controller: pagerCell.controller!, index: index)
    }
    
    override open func pageDidDisappear(cell: UICollectionViewCell, index: Int) {
        let pagerCell = cell as! GAPagerCell
        
        delegate?.pagerControllerDidDisappearPage(controller: pagerCell.controller!, index: index)
        finishRemovingController(cell: pagerCell, index: index)
    }
    
    override open func willDeletePages(pages: [Int]) {
        super.willDeletePages(pages: pages)
        
        for (index, _) in bindedControllers {
            if pages.contains(index) {
                bindedControllers[index] = nil
                offsetBindedControllers(offset: -pages.count)
            }
        }
    }
    
    override open func onClearDeletingPage() {
        super.onClearDeletingPage()
        
        if deletingPage != nil {
            let pagerCell = deletingPage as! GAPagerCell
            
            if let ctrl = pagerCell.controller {
                queue.enqueue(obj: ctrl)
                gaLog("queue size %d", queue.count)
            
                //prebindControllers()
            }
        }
    }
    
    // MARK: bindedControllers managing
    
    private func updateBindedControllers() {
        for (index, v) in bindedControllers {
            if abs(currentIndex - index) > bindControllerRange {
                queue.enqueue(obj: v)
                gaLog("queue size %d", queue.count)
                clearBindedController(index: index)
            }
        }
    }
    
    private func addBindedController(index:Int, controller: UIViewController) {
        bindedControllers[index] = controller
        gaLog("binded size %d after add", bindedControllers.count)
    }
    
    private func clearBindedController(index: Int) {
        bindedControllers[index] = nil
        gaLog("binded size %d after clear", bindedControllers.count)
    }
    
    private func offsetBindedControllers(offset: Int) {
        var newBindedControllers:[Int:UIViewController] = [:]
        for (index, v) in bindedControllers {
            let newIndex = index + offset
            newBindedControllers[index + offset] = v
            delegate?.pagerControllerIndexChanged(controller: v, newIndex: newIndex)
        }
        
        gaLog("offsetBindedControllers %d", offset)
        bindedControllers = newBindedControllers
    }
    
    // MARK: controllers managing
    
    private func startAddingControllerIfNeeded(cell: GAPagerCell, index:Int) {
        if cell.controller == nil {
            startAddingController(cell: cell, index: index)
            
        } else {
            cell.startAddingController(ct: cell.controller!, animated: true)
        }
    }
    
    private func startAddingController(cell: GAPagerCell, index:Int) {
        let controller = ensuredPageController(index: index)
        
        addChildViewController(controller)
        cell.startAddingController(ct: controller, animated: true)
        controller.didMove(toParentViewController: self)
    }
    
    private func finishAddingController(cell: GAPagerCell, index:Int) {
        cell.finishAddingController()
    }
    
    private func startRemovingController(cell: GAPagerCell, index:Int) {
        cell.startRemovingController(animated: true)
    }
    
    private func finishRemovingController(cell: GAPagerCell, index:Int) {
        let ctrl: UIViewController! = cell.controller
        
        ctrl?.willMove(toParentViewController: nil)
        cell.finishRemovingController()
        // we enque the controller in updateBindedControllers
    }
    
    private func ensuredPageController(index: Int) -> UIViewController {
        var controller = bindedControllers[index]
        let identifier = datasource.pagerControllerPageIndentifier(index: index)
        
        if controller == nil || controller?.reuseIdentifier != identifier {
            controller = queue.dequeue(reuseIdentifier: identifier) as? UIViewController
            gaLog("queue size %d %@", queue.count, controller!)
        }
        
        return controller!
    }
    
    private func prepareController(controller: UIViewController) {
        controller.view.frame = view.bounds
    }
}

extension GAPagerViewController: GAReuseQueueDelegate {
    
    public func createObject(reuseIdentifier: String) -> GAReusableObject {
        return datasource.pagerControllerCreateController(identifier: reuseIdentifier)
    }
}
