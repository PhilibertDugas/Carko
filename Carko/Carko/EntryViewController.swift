//
//  EntryViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol AuthenticatedDelegate {
    func userAuthenticated()
}

class EntryViewController: UIViewController {
    let pageTitles = ["Future of parking", "Make full use of your space"]
    let pageImages = ["page1.png", "page2.png"]
    
    var pageViewController: UIPageViewController!
    var delegate: AuthenticatedDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController!
        pageViewController.dataSource = self
        
        let startingViewController = viewControllerAtIndex(0)!
        pageViewController.setViewControllers([startingViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 80)
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignUp" {
            let vc = segue.destination as! RegisterViewController
            vc.delegate = self.delegate
        } else if segue.identifier == "showSignIn" {
            let vc = segue.destination as! LoginViewController
            vc.delegate = self.delegate
        }
    }
}

extension EntryViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).pageIndex!
        
        if index == 0 || index == NSNotFound {
            return nil;
        }
        
        index -= 1;
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).pageIndex!
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == pageTitles.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func viewControllerAtIndex(_ index: Int) -> PageContentViewController? {
        if index >= self.pageTitles.count {
            return nil
        }
        
        let pageContentController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as! PageContentViewController
        pageContentController.imageFile = self.pageImages[index]
        pageContentController.titleText = self.pageTitles[index]
        pageContentController.pageIndex = index
        return pageContentController
    }
}
