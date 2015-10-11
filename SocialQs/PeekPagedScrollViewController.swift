//
//  PeekPagedScrollViewController.swift
//  ScrollViews
//
//

import UIKit

class PeekPagedScrollViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    
    var imageZoom: [UIImage?] = [nil, nil, nil]
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        questionToView = nil
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        if (questionToView!["asker"]!["profilePicture"] as? PFFile != nil) {
            getImageFromPFFile(questionToView!["asker"]!["profilePicture"] as! PFFile, completion: { (image, error) -> () in
                if error == nil {
                    self.profilePicture.image = image
                }
            })
        }
        profilePicture.contentMode = UIViewContentMode.ScaleAspectFill
        profilePicture.layer.masksToBounds = false
        profilePicture.clipsToBounds = true
        
        var expectedCount = 0
        var downloadedCount = 0
        
        if let _  = questionToView!["questionImageThumb"] as? PFFile { expectedCount++ }
        if let _  = questionToView!["option1ImageThumb"]  as? PFFile { expectedCount++ }
        if let _  = questionToView!["option2ImageThumb"]  as? PFFile { expectedCount++ }
        
        if let questionPhoto = questionToView!["questionImageFull"] as? PFFile {
            
            questionPhoto.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error == nil {
                    
                    if let downloadedImage = UIImage(data: data!) {
                        
                        self.imageZoom[0] = downloadedImage
                        
                        downloadedCount++
                        
                        if downloadedCount == expectedCount {
                            
                            // Set page counts and page numbers
                            self.preparePages()
                            
                            // Load the initial set of pages that are on screen
                            self.loadVisiblePages()
                        }
                    }
                    
                } else {
                    
                    print("There was an error downloading an option2Photo")
                }
            })
        }
        
        if let option1Photo = questionToView!["option1ImageFull"] as? PFFile {
            
            option1Photo.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error == nil {
                    
                    if let downloadedImage = UIImage(data: data!) {
                        
                        self.imageZoom[1] = downloadedImage
                        
                        downloadedCount++
                        
                        if downloadedCount == expectedCount {
                            
                            // Set page counts and page numbers
                            self.preparePages()
                            
                            // Load the initial set of pages that are on screen
                            self.loadVisiblePages()
                        }
                    }
                    
                } else {
                    
                    print("There was an error downloading an option2Photo")
                }
            })
        }
        
        if let option2Photo = questionToView!["option2ImageFull"] as? PFFile {
            
            option2Photo.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error == nil {
                    
                    if let downloadedImage = UIImage(data: data!) {
                        
                        self.imageZoom[2] = downloadedImage
                        
                        downloadedCount++
                        
                        if downloadedCount == expectedCount {
                            
                            // Set page counts and page numbers
                            self.preparePages()
                            
                            // Load the initial set of pages that are on screen
                            self.loadVisiblePages()
                        }
                    }
                    
                } else {
                    
                    print("There was an error downloading an option2Photo")
                }
            })
        }
    }
    
    
    func preparePages() {
        
        // Set question text
        if let questionText = questionToView!["questionText"] as? String {
            questionLabel.text = questionText
            questionLabel.alpha = CGFloat(0.75)
            questionLabel.hidden = false
        } else {
            questionLabel.hidden = true
        }
        
        // Set up the image you want to scroll & zoom and add it to the scroll view
        for var i = 0; i < imageZoom.count; i++ {
            if imageZoom[i] != nil {
                pageImages.append(imageZoom[i]!)
            }
        }
        
        let pageCount = pageImages.count
        
        // Set up the page control
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        // Set up the array to hold the views for each page
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // Set up the content size of the scroll view
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(pageImages.count), 1.0)//pagesScrollViewSize.height)
        
        // Set offset to show clicked image (1st or 2nd option)
        let offset = CGPointMake(scrollView.frame.size.width*CGFloat(zoomPage), 0)
        scrollView.setContentOffset(offset, animated: false) // changed to false as to not see page selection during page load
    }
    
    func loadPage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Load an individual page, first checking if you've already loaded it
        if let _ = pageViews[page] {
            //if let pageView...
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            frame = CGRectInset(frame, 10.0, 0.0)
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}