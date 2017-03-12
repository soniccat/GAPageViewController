//
//  PagerConrollerViewController.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 19.02.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

// The class provides open methods which must be overriden in a subclass

open class GABasePagerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    open private(set) var collectionView: UICollectionView!
    private var pagerLayout = GAPagerLayout()
    
    open private(set) var currentIndex = 0
    private var appearingIndex = -1
    
    
    private func initializeCollectionView() {
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: pagerLayout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.translatesAutoresizingMaskIntoConstraints = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        // restore contentOffset
        let width = self.view.bounds.width
        collectionView.contentOffset = CGPoint(x: CGFloat(currentIndex) * width, y: 0)
        
        registerCells()
        
        view.addSubview(collectionView)
    }
    
    override open func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(currentIndex, forKey: "currentIndex")
    }
    
    override open func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        currentIndex = coder.decodeInteger(forKey: "currentIndex")
        pagerLayout.currentIndex = currentIndex
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareCollectionViewIfNeeded()
    }
    
    private func prepareCollectionViewIfNeeded() {
        if collectionView == nil {
            // provide collectionView creation here to avoid requesting a cell at 0 index
            // when currentIndex is different while restoration
            
            initializeCollectionView();
            restoreCollectionViewIfNeeded();
        }
    }
    
    private func restoreCollectionViewIfNeeded() {
        if currentIndex != 0 {
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded() // is required to request the right cell
        }
    }
    
    // MARK: To override
    
    open func registerCells() {
    }
    
    open func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        let exception = NSException(
            name: NSExceptionName("Not implemented!"),
            reason: "A concrete subclass doesn't provide its own implementation of cellForItem:",
            userInfo: nil
        )
        
        exception.raise()
        abort()
    }
    
    
    open func onPageChange() {
    }
    
    open func numberOfPage() -> Int {
        return 0;
    }
    
    open func bindPage(cell: UICollectionViewCell, index: Int) {
    }
    
    open func pageWillAppear(cell: UICollectionViewCell, index: Int) {
    }
    
    open func pageDidAppear(cell: UICollectionViewCell, index: Int) {
    }
    
    open func pageWillDisappear(cell: UICollectionViewCell, index: Int) {
    }
    
    open func pageDidDisappear(cell: UICollectionViewCell, index: Int) {
    }
    
    
    // MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPage()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cellForItem(at: indexPath)
        bindPage(cell: cell, index: indexPath.row)
        
        return cell
    }
    
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let nextPage = Int(targetContentOffset.pointee.x / collectionView.bounds.width)
        gaLog("scrollViewWillEndDragging targetContentOffset %@", NSStringFromCGPoint(targetContentOffset.pointee))
        
        if nextPage != appearingIndex && appearingIndex != -1 {
            gaLog("scrollViewWillEndDragging %d %d", nextPage, appearingIndex);
            
            // change current appearing cell
            let nextCell = collectionView.cellForItem(at: IndexPath(row: nextPage, section: 0))
            let prevCell = collectionView.cellForItem(at: IndexPath(row: appearingIndex, section: 0))
            appearingIndex = nextPage
            
            if nextCell != nil {
                pageWillAppear(cell: nextCell!, index: nextPage)
            }
            
            if prevCell != nil {
                pageWillDisappear(cell: prevCell!, index: appearingIndex)
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        gaLog("scrollViewDidEndDecelerating %d", Int(scrollView.contentOffset.x))
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        gaLog("scrollViewWillBeginDecelerating %d", Int(scrollView.contentOffset.x))
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        gaLog("scrollViewDidEndDragging %d", Int(scrollView.contentOffset.x))
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //log("scrollViewDidScroll %d", Int(scrollView.contentOffset.x))
    }
    
    
    // MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        gaLog("collectionView willDisplay %d %d", indexPath.row, appearingIndex);
        appearingIndex = indexPath.row
        pageWillAppear(cell: cell, index: appearingIndex)
        
        if currentIndex != appearingIndex && appearingIndex != -1 { // can be equal while first layouting
            let currentCell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))!
            pageWillDisappear(cell: currentCell, index: currentIndex)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        gaLog("collectionView didEndDisplaying %d %d", indexPath.row, appearingIndex);
        
        if appearingIndex == indexPath.row {
            // After a long swipe the right page can start decelerating which triggers viewWillAppear
            // and almost immediately viewWillDisappear. Here we rollback to the currentIndex.
            pageWillDisappear(cell: cell, index: indexPath.row)
            
            let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))!
            pageWillAppear(cell: cell, index: currentIndex)
            
            appearingIndex = currentIndex
        }
        
        pageDidDisappear(cell: cell, index: indexPath.row)
        
        let width = collectionView.bounds.width
        let index = Int((collectionView.contentOffset.x + width / 2) / collectionView.bounds.width)
        var pageHasChanged = false
        
        if (index != currentIndex) {
            currentIndex = index
            pagerLayout.currentIndex = currentIndex
            pageHasChanged = true
        }
        
        if appearingIndex == currentIndex {
            gaLog("collectionView didEndDisplaying %d %d -> -1", indexPath.row, appearingIndex);
            appearingIndex = -1
            
            let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
            if cell != nil {
                pageDidAppear(cell: cell!, index: currentIndex)
            }
        }
        
        if pageHasChanged {
            onPageChange()
        }
    }
    
    // MARK: Rotation
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        gaLog("transition started")
        
        super.viewWillTransition(to: size, with: coordinator)
        
        pagerLayout.isRotating = true
        
        weak var weakSelf = self
        coordinator.animate(alongsideTransition: nil) { (context: UIViewControllerTransitionCoordinatorContext) in
            weakSelf?.gaLog("transition finished")
            
            if let controller = weakSelf {
                controller.pagerLayout.isRotating = false
                
                // force to return the attributes for edge pages in PagerLayout
                controller.collectionView.reloadItems(at: controller.edgeIndexPaths())
            }
        }
    }
    
    private func edgeIndexPaths() -> [IndexPath] {
        var resutl:[IndexPath] = []
        
        let index = currentIndex
        if index > 0 {
            resutl.append(IndexPath(row: index - 1, section: 0))
        }
        
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        if pagerLayout.currentIndex < itemCount - 1 {
            resutl.append(IndexPath(row: pagerLayout.currentIndex + 1, section: 0))
        }
        
        return resutl
    }
}
