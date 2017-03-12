GAPageViewController is a custom container view controller like UIPageViewController with a scroll UIPageViewControllerTransitionStyle. 

## Reasons

There's a bug in a UIPageViewController. After fast crolling its viewControllers property returns a controller which is not currently visible.  
There is no way to customize a UIPageViewController and understand how it works under the hood.

## Implementation details

GAPageViewController supports restoration, calls appearance-related messages (viewWillAppear, view..) for its child view controllers. Scrolling is implemented using a UICollectionView. Page layouting is done with a custom UICollectionViewLayout.

## Requirements
 
* iOS 8.0+
* Xcode 8.0+

## TODO:

Support page deletion, insertion, refreshing.
