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

class ErrorOverlayViewController: UIViewController {
  
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var errorButton: UIButton!
    @IBOutlet var mainMessage: UITextView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //errorButton.layer.cornerRadius = 4.0
    errorButton.backgroundColor = UIColor.clearColor()//blackColor().colorWithAlphaComponent(0.7)
    errorButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    
    //mainMessage.layer.cornerRadius = 4.0
    mainMessage.editable = true
    mainMessage.selectable = true
    mainMessage.text = popErrorMessage
    mainMessage.backgroundColor = UIColor.clearColor()//blackColor().colorWithAlphaComponent(0.7)
    //mainMessage.font = UIFont(name: "HeleveticaNeue-Thin", size: )
    mainMessage.textAlignment = NSTextAlignment.Center
    mainMessage.textColor = UIColor.whiteColor()
    mainMessage.selectable = false
    mainMessage.editable = false
    
    backgroundImage.layer.cornerRadius = 20.0
    backgroundImage.layer.masksToBounds = true
    
    formatButton(dismissButton)
    dismissButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    
    // Format View
    view.layer.cornerRadius = 20.0
    view.layer.shadowColor = UIColor.blackColor().CGColor
    view.layer.shadowOffset = CGSizeMake(0, 0)
    view.layer.shadowRadius = 10
    view.layer.shadowOpacity = 0.5
  }
  

  @IBAction func handleDismissedPressed(sender: AnyObject) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
