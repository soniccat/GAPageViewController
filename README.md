GAPageViewController is a custom container view controller like UIPageViewController with scroll UIPageViewControllerTransitionStyle. 

## Reasons

There's a bug in UIPageViewController. After fast crolling its viewControllers property returns a controller which is not currently visible.
There is no way to customize UIPageViewController and understand how it works under the hood.

## Implementation details

GAPageViewController supports restoration, calls appearance-related messages (viewWillAppear, view..) for its child view controllers. Scrolling is implemented using UICollectionView. Page layouting is done with a custom UICollectionViewLayout.

## TODO:

Support page deletion, insertion, refreshing.
