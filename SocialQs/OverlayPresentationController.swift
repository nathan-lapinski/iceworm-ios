//
// Copyright 2015 Brett Wiesman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class OverlayPresentationController: UIPresentationController {
    
    let dimmingView = UIView()
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    }
    
    // Creates dimming view and initializes its transition
    override func presentationTransitionWillBegin() {
        
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({
            context in
            self.dimmingView.alpha = 1.0
            }, completion: nil)
    }
    
    // This really only handles the fade out of the dimming view
    override func dismissalTransitionWillBegin() {
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({
            context in
            self.dimmingView.alpha = 0.0
            }, completion: {
                context in
                self.dimmingView.removeFromSuperview()
        })
    }
    
    // Sets the frame of the popover view
    override func frameOfPresentedViewInContainerView() -> CGRect {
        
        //return containerView.bounds.rectByInsetting(dx: popInset, dy: popInset)
        var returnFrame = CGRect()
        
        switch popDirection {
        case "left":
            returnFrame = CGRectMake(containerView.frame.origin.x - 2*popInset, containerView.frame.origin.y + popInset, containerView.frame.width + popInset, containerView.frame.height - 2*popInset)
        case "right":
            returnFrame = CGRectMake(containerView.frame.origin.x + popInset, containerView.frame.origin.y + popInset, containerView.frame.width + popInset, containerView.frame.height - 2*popInset)
        default:
            returnFrame = CGRectMake(containerView.frame.origin.x + popInset, containerView.frame.origin.y + popInset, containerView.frame.width - 2*popInset, containerView.frame.height - 2*popInset)
        }
        
        return returnFrame
    }
    
    // Pulls the frame of the popover view from function
    override func containerViewWillLayoutSubviews() {
        
        dimmingView.frame = containerView.bounds
        presentedView().frame = frameOfPresentedViewInContainerView()
    }
}
