//
//  PageViewControllerDelegate.swift
//  Pods
//
//  Created by Guillaume on 9/21/16.
//
//

import Foundation

public protocol PageViewControllerDelegate: class {

    /**
     Called in CATransaction block to apply transforms. If not implemented or returns false, an horizontal animation is used
     
     :param: pageViewController the page view controller
     :param: before             the controller that comes before the current one
     :param: visible            the current view controller
     :param: after              the controller that comes after the current one
     :param: progress           progress value, from -1 to 1, 0: visible correctly placed, 1 before correctly placed, -1 after correctly placed
     
     :returns: true if did set the transforms
     */
    func pageViewController(_ pageViewController: PageViewController, applyTransformsTo before: UIViewController?, visible: UIViewController?, after: UIViewController?, forProgress progress: CGFloat)

    /**
     Propagation the gestureRecognizerShouldBegin method, return false if you don't want the recognizer to start
     
     :param: pageViewController the pageViewController
     :param: gestureRecognizer  the gestureRecognizer
     
     :returns: true if it should begin
     */
    func pageViewController(_ pageViewController: PageViewController, panGestureRecognizerShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool

    func pageViewController(_ pageViewController: PageViewController, willStartPanWith before: UIViewController?, visible: UIViewController?, after: UIViewController?)

    func pageViewController(_ pageViewController: PageViewController, willTransitionFrom fromViewController: UIViewController, to: UIViewController)

    func pageViewController(_ pageViewController: PageViewController, didTransitionFrom fromViewController: UIViewController, to: UIViewController)
}

extension PageViewControllerDelegate {

    public func pageViewController(_ pageViewController: PageViewController, applyTransformsTo before: UIViewController?, visible: UIViewController?, after: UIViewController?, forProgress progress: CGFloat) {

        let width = pageViewController.view.bounds.width
        before?.view.layer.transform = CATransform3DMakeTranslation(width * (progress - 1), 0, 0)
        visible?.view.layer.transform = CATransform3DMakeTranslation(width * progress, 0, 0)
        after?.view.layer.transform = CATransform3DMakeTranslation(width * (progress + 1), 0, 0)

    }

    public func pageViewController(_ pageViewController: PageViewController, panGestureRecognizerShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }

    public func pageViewController(_ pageViewController: PageViewController, willStartPanWith before: UIViewController?, visible: UIViewController?, after: UIViewController?) {
    }

    public func pageViewController(_ pageViewController: PageViewController, willTransitionFrom fromViewController: UIViewController, to: UIViewController) {}

    public func pageViewController(_ pageViewController: PageViewController, didTransitionFrom fromViewController: UIViewController, to: UIViewController) {}

}
