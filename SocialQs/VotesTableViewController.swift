//
//  Votes
//  TableViewController.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/30/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import UIKit

class VotesTableViewController: UITableViewController {
    
    let tableFontSize = CGFloat(16)
    var objectsArray = [Objects]()
    let headerHeight = CGFloat(60)
    
    var votesId       = ""
    var questionText  = ""
    var option1Text   = ""
    var option2Text   = ""
    var questionPhoto: PFFile? = PFFile()
    var option1Photo: PFFile?  = PFFile()
    var option2Photo: PFFile?  = PFFile()
    
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
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
        
        returningFromPopover = true
        returningFromSettings = false
        
        var query = PFQuery(className: "Votes")
        query.getObjectInBackgroundWithId(viewQ["votesId"] as! String, block: { (objects, error) -> Void in
            
            if error == nil {
                
                var voter1s = [""]
                var voter2s = [""]
                voter1s.removeAll(keepCapacity: true)
                voter2s.removeAll(keepCapacity: true)
                
                // Fill voter1 array - use "?" as it may not exist
                if objects!["option1VoterName"]?.count > 0 {
                    voter1s = objects!["option1VoterName"] as! [String]
                }
                
                // Fill voter2 array - use "?" as it may not exist
                if objects!["option2VoterName"]?.count > 0 {
                    voter2s = objects!["option2VoterName"] as! [String]
                }
                
                // Build table view objects
                if voter1s.count > 0 && voter2s.count > 0 {
                    self.objectsArray = [Objects(sectionName: viewQ["option1"] as! String, sectionObjects: voter1s), Objects(sectionName: viewQ["option2"] as! String, sectionObjects: voter2s)]
                } else if voter1s.count > 0 && voter2s.count < 1 {
                    self.objectsArray = [Objects(sectionName: viewQ["option1"] as! String, sectionObjects: voter1s)]
                } else if voter1s.count < 1 && voter2s.count > 0 {
                    self.objectsArray = [Objects(sectionName: viewQ["option2"] as! String, sectionObjects: voter2s)]
                }
                
                // Reload table data
                self.tableView.reloadData()
                //self.tableView.reloadInputViews()
                
            } else {
                println("Voter retreival error")
                println(error)
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectsArray.count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray[section].sectionObjects.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("votesCell", forIndexPath: indexPath) as! VotesCell
        
        cell.textLabel?.text = objectsArray[indexPath.section].sectionObjects[indexPath.row]
        
        // Make cells non-selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    
    // Format section header
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = mainColorBlue
        
        // Set Q in table header
        if imageZoom[0] != nil {
        //if let qPhoto = viewQ["questionPhoto"] as? PFFile {
            var headerTextView = UITextField(frame: CGRectMake(8, 0, self.view.frame.size.width - 60, 60))
            headerTextView.text = viewQ["question"] as! String //questionText
            headerTextView.textColor = UIColor.darkTextColor()
            headerTextView.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            headerTextView.textAlignment = NSTextAlignment.Center
            
            var frame = CGRectMake(0, 0, 60, 60)
            var headerImageView = UIImageView(frame: frame)
            var image: UIImage = imageZoom[0]!
            headerImageView.image = image
            headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
            headerImageView.clipsToBounds = true
            tableView.tableHeaderView = headerTextView
            tableView.tableHeaderView?.addSubview(headerImageView)
        } else {
            var headerTextView = UITextField(frame: CGRectMake(8, 0, self.view.frame.size.width - 8, 60))
            headerTextView.text = viewQ["question"] as! String //questionText
            headerTextView.textColor = UIColor.darkTextColor()
            headerTextView.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            headerTextView.textAlignment = NSTextAlignment.Center
            tableView.tableHeaderView = headerTextView
        }
        
        // Set text or photo in section header
        if imageZoom[section+1] != nil {
            
        //if let ophoto = viewQ["option\(section+1)Photo"] as? PFFile { // Image
            //var frame = CGRectMake(0, 0, self.view.frame.size.width, 60) // full bar image
            var frame = CGRectMake(self.view.frame.size.width - 60, 0, 60, 60)
            var headerImageView = UIImageView(frame: frame)
            var image: UIImage = imageZoom[section+1]!
            headerImageView.image = image
            headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
            headerImageView.clipsToBounds = true
            header.addSubview(headerImageView)
            
            var headerTextView = UITextField(frame: CGRectMake(0, 0, self.view.frame.size.width, 60))
            headerTextView.text = viewQ["option1"] as! String
            headerTextView.textColor = UIColor.whiteColor()
            headerTextView.backgroundColor = UIColor.clearColor()
            headerTextView.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            headerTextView.textAlignment = NSTextAlignment.Center
            //header.textLabel.text = objectsArray[section].sectionName
            //var linesShown: CGFloat = 3
            //var maxHeight: CGFloat = headerTextView.font.lineHeight * linesShown
            //headerTextView.sizeThatFits(CGSizeMake(self.view.frame.size.width, maxHeight))
            
            header.addSubview(headerTextView)
            
        } else {
            header.textLabel.textColor = UIColor.whiteColor()
            header.textLabel.backgroundColor = UIColor.clearColor()
            //header.alpha = bgAlpha //make the header transparent
            
            header.textLabel.textAlignment = NSTextAlignment.Left
            header.textLabel.numberOfLines = 10 // Dynamic number of lines
            header.textLabel.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
            //header.textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            header.textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: tableFontSize)!
            header.textLabel.text = objectsArray[section].sectionName
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
