//
//  VotesVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 10/23/15.
//  Copyright © 2015 BookSix. All rights reserved.
//

import UIKit

class VotesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableFontSize = CGFloat(16)
    let headerHeight = CGFloat(60)
    
    var option1Objects: [PFObject] = []
    var option2Objects: [PFObject] = []
    
    var votesBoxView = UIView()
    var votesBlurView = globalBlurView()
    
    //@IBOutlet var doneButton: UIBarButtonItem!
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var votesTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissPressed:")
    
        // Format Done button
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "dismissPressed:")
        doneButton.tintColor = UIColor.blackColor()
        self.navigationItem.leftBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!], forState: UIControlState.Normal)
        
        votesTable.delegate = self
        votesTable.dataSource = self
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: "resignKeyboard")
//        tapGesture.cancelsTouchesInView = true
//        askTable.addGestureRecognizer(tapGesture)
        
        self.votesTable.backgroundColor = UIColor.clearColor()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        displaySpinnerView(spinnerActive: true, UIBlock: false, _boxView: votesBoxView, _blurView: votesBlurView, progressText: "Loading Vote Data", sender: self)
        
        let query = PFQuery(className: "QJoin")
        query.whereKey("question", equalTo: questionToView!)
        query.includeKey("to")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                if let temp = objects {
                    
                    for object in temp {
                        
                        if let voteCheck: Int = object["vote"] as? Int {
                            
                            if voteCheck == 1 {
                                self.option1Objects.append(object)
                            } else if voteCheck == 2 {
                                self.option2Objects.append(object)
                            }
                        }
                    }
                    
                    // Reload table data
                    self.votesTable.reloadData()
                    
                    displaySpinnerView(spinnerActive: false, UIBlock: false, _boxView: self.votesBoxView, _blurView: self.votesBlurView, progressText: nil, sender: self)
                    
                } else {
                    
                    print("Voter retreival error")
                    print(error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(votesTable: UITableView) -> Int {
        
        return 3
    }
    
    
    func tableView(votesTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            
            return option1Objects.count
            
        } else if section == 2 {
            
            return option2Objects.count
            
        } else {
            
            return 0
        }
    }
    
    
    func tableView(votesTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = votesTable.dequeueReusableCellWithIdentifier("votesCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            
            cell.textLabel?.text = ""
            
        } else if indexPath.section == 1 {
            
            if let textString = option1Objects[indexPath.row]["to"]!["name"] as? String {
                cell.textLabel?.text = textString
            }
            
        } else if indexPath.section == 2 {
            
            if let textString = option2Objects[indexPath.row]["to"]!["name"] as? String {
                cell.textLabel?.text = textString
            }
        }
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    
    // Format section header
    func tableView(votesTable: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 0 { // Set Q in table header
            
            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor.grayColor()
            
//            // Add asker profile picture
//            if (questionToView!["asker"]["profilePicture"] as? PFFile != nil) {
//                
//                let frame = CGRectMake(0, 0, 60, 60)
//                let profilePicture = UIButton(frame: frame)
//                getImageFromPFFile((questionToView!["asker"]["profilePicture"] as? PFFile)!, completion: { (image, error) -> () in
//                    
//                    if error == nil {
//                        
//                        profilePicture.setImage(image, forState: UIControlState.Normal)
//                        profilePicture.contentMode = UIViewContentMode.ScaleAspectFill
//                        profilePicture.clipsToBounds = true
//                        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
//                        header.addSubview(profilePicture)
//                        
//                    } else {
//                        
//                        print("There was an error downloading asker profilePicture - votesTableVC")
//                    }
//                })
//            }
            
            if (questionToView!["questionText"] as? String != nil) {
                
                let headerTextView = UITextView(frame: CGRectMake(68, 0, self.view.frame.size.width - 136, 60))
                headerTextView.text = questionToView!["questionText"] as? String
                headerTextView.textColor = UIColor.whiteColor()
                headerTextView.backgroundColor = UIColor.clearColor()
                headerTextView.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
                headerTextView.textAlignment = NSTextAlignment.Center
                headerTextView.editable = false
                header.addSubview(headerTextView)
            }
            
            if (questionToView!["questionImageThumb"] as? PFFile != nil) {
                
                let frame = CGRectMake(self.view.frame.size.width - 60, 0, 60, 60)
                let headerImageView = UIImageView(frame: frame)
                getImageFromPFFile(questionToView!["questionImageThumb"] as! PFFile, completion: { (image, error) -> () in
                    
                    if error == nil {
                        
                        headerImageView.image = image
                        headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
                        headerImageView.clipsToBounds = true
                        header.addSubview(headerImageView)
                        
                    } else {
                        
                        print("There was an error downloading questionPhoto - votesTableVC")
                    }
                })
            }
            
        } else if section == 1 || section == 2 { // Set option text or photo in section header
            
            let xheader: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
            xheader.contentView.backgroundColor = mainColorBlue // mainColorRed
            
            if (questionToView!["option\(section)ImageThumb"] as? PFFile != nil) {
                //var frame = CGRectMake(0, 0, self.view.frame.size.width, 60) // full bar image
                let frame = CGRectMake(0, 0, 60, 60)
                let headerImageView = UIImageView(frame: frame)
                getImageFromPFFile(questionToView!["option\(section)ImageThumb"]! as! PFFile, completion: { (image, error) -> () in
                    
                    if error == nil {
                        
                        print("Adding image to section \(section) header")
                        
                        headerImageView.image = image
                        headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
                        headerImageView.clipsToBounds = true
                        xheader.addSubview(headerImageView)
                        
                    } else {
                        
                        print("There was an error downloading questionPhoto - votesTableVC")
                    }
                })
            }
            
            if (questionToView!["option\(section)Text"] as? String != nil) {
                
                let xheaderTextView = UITextView(frame: CGRectMake(68, 0, self.view.frame.size.width - 136, 60))
                xheaderTextView.text = questionToView!["option\(section)Text"] as? String
                xheaderTextView.textColor = UIColor.whiteColor()
                xheaderTextView.backgroundColor = UIColor.clearColor()
                xheaderTextView.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
                xheaderTextView.textAlignment = NSTextAlignment.Center
                xheaderTextView.editable = false
                xheader.addSubview(xheaderTextView)
            }
        }
    }
    
    
    func tableView(votesTable: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //print("SELECTED \(indexPath.row)")
        
        
    }
    
    
    // Set section header heights
    func tableView(votesTable: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
