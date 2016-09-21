//
//  PageViewControllerDataSource.swift
//  Pods
//
//  Created by Guillaume on 9/21/16.
//
//

import Foundation

public protocol PageViewControllerDataSource: class {
    
    func pageViewController(_ pageViewController: PageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    
    func pageViewController(_ pageViewController: PageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController?
    
}
