//
//  PageViewController.swift
//  Tunsy
//
//  Created by Guillaume on 19/07/15.
//  Copyright (c) 2015 Tunsy. All rights reserved.
//

import UIKit

private let SWIPE_VELOCITY: CGFloat = 700

public class PageViewController: UIViewController {
    
    public static let pageDidChange = Notification.Name(rawValue: "PageViewController.pageDidChangeNotification")
    
    public weak var dataSource: PageViewControllerDataSource?
    
    public weak var delegate: PageViewControllerDelegate?
    
    public fileprivate(set) weak var visibleViewController: UIViewController?
    
    fileprivate var beforeViewController: UIViewController?
    
    fileprivate var afterViewController: UIViewController?
    
    fileprivate var txMin: CGFloat = 0
    
    fileprivate var txMax: CGFloat = 0
    
    public var bounce: CGFloat = 0.1
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(PageViewController.panRecognized(_:)))
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
    }
    
    /**
    Sets the visible view controller.
    
    :param: viewController the new view controller
    :param: direction      the direction
    :param: animated       true if animated
    :param: completion     the completion block that will be called only if animated
    */
    public func setViewController(_ viewController: UIViewController?, direction: UIPageViewControllerNavigationDirection = .forward, animated: Bool = true, completion:((Bool) -> Void)? = nil) {
        
        let current = visibleViewController
        current?.willMove(toParentViewController: nil)
        
        if viewController != nil {
            self.addChildViewController(viewController!)
            viewController!.view.frame = self.view.bounds
            viewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(viewController!.view)
        }
        
        let finish: () -> () = {
            current?.view.removeFromSuperview()
            current?.removeFromParentViewController()
            
            viewController?.didMove(toParentViewController: self)
            
            self.visibleViewController = viewController
        }
        
        if animated {
            
            beforeViewController = direction == .reverse ? viewController : nil
            afterViewController = direction == .forward ? viewController : nil
            
            setTransform(0)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                
                self.setTransform(direction == .forward ? -1 : 1)
                
                }, completion: { (f) -> Void in
                    finish()
                    completion?(f)
            })
        } else {
            finish()
        }
    }
}

extension PageViewController: UIGestureRecognizerDelegate {
    
    fileprivate func addAnimationLayer(_ controller: UIViewController) -> CALayer {

        let layer = CALayer()
        layer.frame = visibleViewController!.view.layer.frame
        
        let h = controller.view.isHidden
        let a = controller.view.alpha
        
        controller.view.isHidden = false
        controller.view.alpha = 1
        
        UIGraphicsBeginImageContextWithOptions(controller.view.frame.size, false, 0);
        controller.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        controller.view.isHidden = h
        controller.view.alpha = a
        
        layer.contents = image
        
        view.layer.addSublayer(layer)
        
        return layer
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            if self.dataSource == nil || self.visibleViewController == nil {
                return false
            } else {
                
                let width = self.view.bounds.width
                
                if let before = self.dataSource!.pageViewController(self, viewControllerBefore: self.visibleViewController!) {
                    beforeViewController = before
                    txMax = width
                } else {
                    beforeViewController = nil
                    txMax = bounce * width
                }
                
                if let after = self.dataSource!.pageViewController(self, viewControllerAfter: self.visibleViewController!) {
                    afterViewController = after
                    txMin = -width
                } else {
                    afterViewController = nil
                    
                    txMin = -bounce * width
                }
                
                if beforeViewController == nil && afterViewController == nil {
                    return false
                } else {
                    if delegate?.pageViewController(self, panGestureRecognizerShouldBegin: pan) ?? true {
                        return true
                    } else {
                        beforeViewController = nil
                        afterViewController = nil
                        return false
                    }
                }
            }
        }
        return true
    }
    
    fileprivate func setTransform(_ progress: CGFloat) {
        delegate?.pageViewController(self, applyTransformsTo: beforeViewController, visible: visibleViewController, after: afterViewController, forProgress: progress)
    }
    
    open func panRecognized(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            
            let handleVC: (UIViewController!) -> () =  { vc in
                
                if vc != nil {
                    self.addChildViewController(vc)
                    vc.view.frame = self.view.bounds
                    self.view.addSubview(vc.view)
                    vc.didMove(toParentViewController: self)
                }
            }
            
            handleVC(beforeViewController)
            handleVC(afterViewController)
            
            delegate?.pageViewController(self, willStartPanWith: beforeViewController, visible: visibleViewController, after: afterViewController)
            
            setTransform(0)
            
            break
        case .changed:
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            var t = sender.translation(in: self.view).x
            if t > txMax {
                t = txMax
            } else if t < txMin {
                t = txMin
            }
            
            setTransform(t / self.view.bounds.width)
            CATransaction.commit()
        default:
            let tx = sender.translation(in: self.view).x
            let vx = sender.velocity(in: self.view).x
            let width = self.view.bounds.width
            
            let finalTx: CGFloat
            
            //TODO: check velocity
            let newVisible: UIViewController
            let oldVisible = visibleViewController!
            
            if beforeViewController != nil && (tx > 0.5 * width || vx > SWIPE_VELOCITY) {
                newVisible = beforeViewController!
                finalTx = width
            } else if afterViewController != nil && (tx < -0.5 * width || vx < -SWIPE_VELOCITY) {
                newVisible = afterViewController!
                finalTx = -width
            } else {
                newVisible = visibleViewController!
                finalTx = 0
            }
            
            
            var duration = TimeInterval((finalTx - tx) / vx)
            if duration > 0.3 {
                duration = 0.3
            } else if duration < 0.15 {
                duration = 0.15
            }
            
            if oldVisible != newVisible {
                delegate?.pageViewController(self, willTransitionFrom: oldVisible, to: newVisible)
            }
            
            beforeViewController?.willMove(toParentViewController: nil)
            afterViewController?.willMove(toParentViewController: nil)
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                            self.setTransform(finalTx/width)
            }, completion: { (f) -> Void in
                for vc in [self.beforeViewController, self.visibleViewController, self.afterViewController] {
                    if vc != nil && vc! != newVisible {
                        vc!.view.removeFromSuperview()
                        vc!.removeFromParentViewController()
                    }
                }
                
                self.visibleViewController = newVisible
                self.beforeViewController = nil
                self.afterViewController = nil
                
                if oldVisible != newVisible {
                    self.delegate?.pageViewController(self, didTransitionFrom: oldVisible, to: newVisible)
                    NotificationCenter.default.post(name: PageViewController.pageDidChange, object: self)
                }
            })
            
        }
    }
    
}

extension PageViewController {
    
    public func previous() {
        if let vc = dataSource?.pageViewController(self, viewControllerBefore: visibleViewController!) {
            setViewController(vc, direction: .reverse, animated: true, completion: nil)
        }
    }
    
    public func next() {
        if let vc = dataSource?.pageViewController(self, viewControllerAfter: visibleViewController!) {
            setViewController(vc, direction: .forward, animated: true, completion: nil)
        }
    }
    
}
