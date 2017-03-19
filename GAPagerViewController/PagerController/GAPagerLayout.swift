//
//  PagerLayout.swift
//  CollectionPager
//
//  Created by Alexey Glushkov on 19.02.17.
//  Copyright © 2017 Alexey Glushkov. All rights reserved.
//

import UIKit

internal class GAPagerLayout: UICollectionViewLayout {
    
    internal var currentIndex: Int = 0 // to calculate contentOffset after rotation
    internal var isRotating: Bool = false
    private var layoutWidth: CGFloat = 0
    private var attributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    override var collectionViewContentSize: CGSize {
        get {
            let height = collectionView!.bounds.size.height
            return CGSize(width: contentWidth(), height: height)
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = ensuredAttributes(indexPath: indexPath)
        attributes.frame = frame(at: indexPath)
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result: [UICollectionViewLayoutAttributes] = []
        
        // while rotation we return only the curren indexPath to avoid calling willDisplay
        // in UICollectionViewDelegate for the edge pages
        let paths = isRotating ? [IndexPath(row: currentIndex, section: 0)] : indexPaths(in: rect)
        
        for path in paths {
            result.append(layoutAttributesForItem(at: path)!)
        }
        
        return result
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let needInvalidate = layoutWidth != newBounds.width
        layoutWidth = newBounds.width

        return needInvalidate
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        // to handle rotation
        
        let offset = CGFloat(currentIndex) * pageWidth()
        return CGPoint(x: offset, y: proposedContentOffset.y)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // to handle swiping
        
        var point = proposedContentOffset;
        
        var nextIndex = currentIndex
        let width = pageWidth()
        if velocity.x > 0 {
            nextIndex = min(nextIndex + 1, collectionView!.numberOfItems(inSection: 0)-1)
        } else if velocity.x < 0 {
            nextIndex = max(nextIndex - 1, 0)
        } else {
            nextIndex = Int((CGFloat(point.x) + width/2) / width)
        }
        
        point = CGPoint(x: nextIndex * Int(width), y: 0)
        
        NSLog("targetContentOffset forProposedContentOffset %@", NSStringFromCGPoint(point))
        return point
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attrs?.alpha = 1.0
        
        return attrs
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        attrs?.alpha = 1.0
        
        /*var frame = attrs?.frame
        frame?.origin.x -= pageWidth();
        attrs?.frame = frame!*/
        
        return attrs
    }
    
    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
    }
    
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
    }
    
    private func contentWidth() -> CGFloat {
        return CGFloat(collectionView!.numberOfItems(inSection: 0)) * pageWidth()
    }
    
    private func ensuredAttributes(indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        var result = attributes[indexPath]
        if let attribute = result {
            result = attribute
            
        } else {
            result = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes[indexPath] = result
        }
        
        return result!
    }
    
    private func indexPaths(in rect: CGRect) -> [IndexPath] {
        var result:[IndexPath] = []
        var start = firstIndex(rect: rect)
        start = max(start, 0)
        
        var end = lastIndex(rect: rect)
        end = min(end, collectionView!.numberOfItems(inSection: 0) - 1)
        
        if end >= start {
            for i in start...end {
                result.append(IndexPath(row: i, section: 0))
            }
        }
        
        return result
    }
    
    private func firstIndex(rect: CGRect) -> Int {
        let x = rect.origin.x / pageWidth()
        return Int(floorf(Float(x)))
    }
    
    private func lastIndex(rect: CGRect) -> Int {
        let x = (rect.origin.x + rect.width) / pageWidth()
        return Int(ceilf(Float(x)))
    }
    
    private func frame(at indexPath: IndexPath) -> CGRect {
        let x = CGFloat(indexPath.row) * pageWidth()
        let size = collectionView!.bounds.size
        
        return CGRect(x: x, y: 0, width: size.width, height: size.height)
    }
    
    private func pageRect() -> CGRect {
        return CGRect(x: collectionView!.contentOffset.x, y: 0, width: pageWidth(), height: 0)
    }
    
    private func pageWidth() -> CGFloat {
        return collectionView!.bounds.width
    }
}
