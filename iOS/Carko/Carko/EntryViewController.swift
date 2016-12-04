//
//  EntryViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import FirebaseAuth

class EntryViewController: UIViewController {

    let pageTitles = ["Connect with close professionals", "Get noticed", "Skyrocket your career", "Live your dream"]
    let pageImages = ["page1.png", "page2.png", "page3.png", "page4.png"]
    
    var pageViewController: UIPageViewController!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FIRAuth.auth()?.currentUser != nil {
            self.view.isHidden = true
            transitionToHomePage()
        }
    }
    
    func transitionToHomePage() {
        if let value = UserDefaults.standard.dictionary(forKey: "user") {
            let user = User.init(user: value["customer"] as! [String: Any])
            AppState.sharedInstance.currentUser = user
            self.performSegue(withIdentifier: "UserAlreadyLoggedIn", sender: nil)
        } else {
            User.getUser { (user, error) in
                if let error = error {
                    print("Shit something went wrong display something to the user: \(error.localizedDescription)")
                } else if let user = user {
                    UserDefaults.standard.set(user.toDictionnary(), forKey: "user")
                    AppState.sharedInstance.currentUser = user
                    self.performSegue(withIdentifier: "UserAlreadyLoggedIn", sender: nil)
                }
            }
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
