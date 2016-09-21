//
//  ViewController.swift
//  GMPageViewController
//
//  Created by Guillaume on 9/21/16.
//
//

import UIKit
import GMPage

class ViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let p = segue.destination as? PageViewController {
            p.delegate = self
            p.dataSource = self
            p.setViewController(storyboard!.instantiateViewController(withIdentifier: "content"), animated: false)
        }
    }

}

extension ViewController: PageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = storyboard!.instantiateViewController(withIdentifier: "content") as! ContentViewController
        vc.index = (viewController as! ContentViewController).index + 1
        return vc
    }
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = storyboard!.instantiateViewController(withIdentifier: "content")  as! ContentViewController
        vc.index = (viewController as! ContentViewController).index - 1
        return vc
    }
    
}

extension ViewController: PageViewControllerDelegate {
    
}

class ContentViewController: UIViewController {
    
    var index: Int = 0 {
        didSet {
            label?.text = index.description
//            let gray = CGFloat((index * 10) % 255 ) / 255.0
//            view.backgroundColor = UIColor(white: gray, alpha: 1)
        }
    }
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let index = self.index
        self.index = index
    }
    
}
