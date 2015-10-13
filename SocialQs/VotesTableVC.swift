//
//  Votes
//  VotesTableVC.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/30/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class VotesTableVC: UITableViewController {
    
    let tableFontSize = CGFloat(16)
    var objectsArray = [Objects]()
    let headerHeight = CGFloat(60)
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]?
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissPressed:")
        
        // Format Done button
        navigationItem.leftBarButtonItem = doneButton
        navigationItem.leftBarButtonItem!.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 16)!], forState: UIControlState.Normal)
    }

    
    override func viewWillAppear(animated: Bool) {
        
        let query = PFQuery(className: "QJoin")
        query.whereKey("question", equalTo: questionToView!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                if let temp = objects {
                    
                    var voter1s:[String] = []
                    var voter2s:[String] = []
                    
                    for object in temp {
                        
                        if let _: PFObject = object["vote"]! as? PFObject {
                            
                            if (object["vote"] as! Int) == 1 { voter1s.append(object["to"] as! String) }
                                
                            else if (object["vote"] as! Int) == 2 { voter2s.append(object["to"] as! String) }
                        }
                    }
                    
                    var qText = ""
                    var o1Text = ""
                    var o2Text = ""
                    
                    if let temp = questionToView!["questionText"] as? String {
                        
                        qText = temp
                        
                    } else {
                        
                        qText = ""
                    }
                    
                    if let temp = questionToView!["option1Text"] as? String {
                        
                        o1Text = temp
                        
                    } else {
                        
                        o1Text = ""
                    }
                    
                    if let temp = questionToView!["option2Text"] as? String {
                        
                        o2Text = temp
                        
                    } else {
                        
                        o2Text = ""
                    }
                    
                    // Build table view objects
                    if voter1s.count > 0 && voter2s.count > 0 {
                        
                        self.objectsArray = [
                            Objects(sectionName: qText, sectionObjects: nil),
                            Objects(sectionName: o1Text, sectionObjects: voter1s),
                            Objects(sectionName: o2Text, sectionObjects: voter2s)
                        ]
                        
                    } else if voter1s.count > 0 && voter2s.count < 1 {
                        
                        self.objectsArray = [
                            Objects(sectionName: qText, sectionObjects: nil),
                            Objects(sectionName: o1Text, sectionObjects: voter1s)
                        ]
                        
                    } else if voter1s.count < 1 && voter2s.count > 0 {
                        
                        self.objectsArray = [
                            Objects(sectionName: qText, sectionObjects: nil),
                            Objects(sectionName: o2Text, sectionObjects: voter2s)
                        ]
                    }
                    
                    // Reload table data
                    self.tableView.reloadData()
                    //self.tableView.reloadInputViews()
                    
                } else {
                    print("Voter retreival error")
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectsArray.count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if objectsArray[section].sectionObjects != nil {
            
            return objectsArray[section].sectionObjects!.count
        } else {
            
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("votesCell", forIndexPath: indexPath) as! VotesCell
        
        cell.textLabel?.text = objectsArray[indexPath.section].sectionObjects![indexPath.row]
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        
        if section == 0 { // Set Q in table header
            header.contentView.backgroundColor = mainColorBlue
            
            if(questionToView!["questionText"] as? String != nil) {
                
                let headerTextView = UITextView(frame: CGRectMake(68, 0, self.view.frame.size.width - 128, 60))
                headerTextView.text = questionToView!["questionText"] as? String
                headerTextView.textColor = UIColor.darkTextColor()
                headerTextView.backgroundColor = UIColor.clearColor()
                headerTextView.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
                headerTextView.textAlignment = NSTextAlignment.Center
                headerTextView.editable = false
                header.addSubview(headerTextView)
            }
            
            if (questionToView!["questionPhoto"] as? PFFile != nil) {
                
                let frame = CGRectMake(self.view.frame.size.width - 60, 0, 60, 60)
                let headerImageView = UIImageView(frame: frame)
                getImageFromPFFile(questionToView!["questionPhoto"] as! PFFile, completion: { (image, error) -> () in
                    
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
            
        } else { // Set option text or photo in section header
            header.contentView.backgroundColor = mainColorRed
            
            if (questionToView!["option\(section)Photo"] as? PFFile != nil) {
                //var frame = CGRectMake(0, 0, self.view.frame.size.width, 60) // full bar image
                let frame = CGRectMake(0, 0, 60, 60)
                let headerImageView = UIImageView(frame: frame)
                getImageFromPFFile(questionToView!["option\(section)Photo"]! as! PFFile, completion: { (image, error) -> () in
                    
                    if error == nil {
                        
                        print("Adding image to section \(section) header")
                        
                            headerImageView.image = image
                            headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
                            headerImageView.clipsToBounds = true
                            header.addSubview(headerImageView)
                        
                    } else {
                        
                        print("There was an error downloading questionPhoto - votesTableVC")
                    }
                })
            }
            
            if (questionToView!["option\(section)Text"] as? String != nil) {
                
                let headerTextView = UITextView(frame: CGRectMake(68, 0, self.view.frame.size.width - 128, 60))
                headerTextView.text = questionToView!["option\(section)Text"] as? String
                headerTextView.textColor = UIColor.whiteColor()
                headerTextView.backgroundColor = UIColor.clearColor()
                headerTextView.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
                headerTextView.textAlignment = NSTextAlignment.Center
                headerTextView.editable = false
                header.addSubview(headerTextView)
            }
        }
    }
    
    
    // Set section header heights
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
