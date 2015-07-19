//
//  TabBarController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/27/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // Active text color
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: activeTabColor], forState: UIControlState.Selected)
        
        // Inactive text color
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: inactiveTabColor], forState: UIControlState.Normal)
        
        // Active icon color
        UITabBar.appearance().tintColor = activeTabColor
        
        // Inactive icon color
        for item in self.tabBar.items as! [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(inactiveTabColor).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        
        // Set Logo
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo_square.png")
        imageView.image = image
        self.navigationItem.titleView = imageView

    }
    
    
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioningObject: TransitioningObject = TransitioningObject()
        // set the reference to self so it can get the indexes of the to and from view controllers
        transitioningObject.tabBarController = self
        return transitioningObject
    }
}

class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
    
    private weak var tabBarController: TabBarController!
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Get the "from" and "to" views
        let fromView: UIView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toView: UIView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        transitionContext.containerView().addSubview(fromView)
        transitionContext.containerView().addSubview(toView)
        
        let fromViewControllerIndex = find(self.tabBarController.viewControllers! as! [UIViewController], fromViewController)
        let toViewControllerIndex = find(self.tabBarController.viewControllers!as! [UIViewController], toViewController)
        
        // 1 will slide left, -1 will slide right
        var directionInteger: CGFloat!
        if fromViewControllerIndex < toViewControllerIndex {
            directionInteger = 1
        } else {
            directionInteger = -1
        }
        
        //The "to" view with start "off screen" and slide left pushing the "from" view "off screen"
        toView.frame = CGRectMake(directionInteger * toView.frame.width, 0, toView.frame.width, toView.frame.height)
        let fromNewFrame = CGRectMake(-1 * directionInteger * fromView.frame.width, 0, fromView.frame.width, fromView.frame.height)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            toView.frame = fromView.frame
            fromView.frame = fromNewFrame
            }) { (Bool) -> Void in
                // update internal view - must always be called
                transitionContext.completeTransition(true)
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.33
    }
}


extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext() as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}



