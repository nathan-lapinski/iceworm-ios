////
////  PseudoCodeForCloud.swift
////  SocialQs
////
////  Created by Brett Wiesman on 10/9/15.
////  Copyright © 2015 BookSix. All rights reserved.
////
//
//import UIKit
//
//class PseudoCodeForCloud: UIViewController {
//    
//    // MARK: - Cloud Code
//    
//    func submitQuestion(asker: PFObject, to: Dictionary<String, String>, questionText: String,  questionImageThumb: NSData, questionImageFull: NSData, optionText: Dictionary<Int, String>, optionImageThumbs: Dictionary<Int, NSData>, optionImageFull: Dictionary<Int, NSData>) {
//        
//        // toIds = [id: accountType] 
//        //               - this will hopefully ensure we can accommodate other types logins later
//        
//        /////////////////////////////////////////////////////////////////////////////////////////
//        // Build QImage entries (full res and thumbs)
//        var images: [PFObject] = []
//        
//        // Q
//        var imageObject = PFObject(className: "QImages")
//        
//        let imageThumb = PFFile(name: "questionImageThumb.png", data: questionImageThumb)
//        imageObject.setObject(imageThumb, forKey: "thumbnail")
//        
//        let imageFull = PFFile(name: "quesitonImageFull.png", data: questionImageFull)
//        imageObject.setObject(imageFull, forKey: "fullResolution")
//        
//        imageObject.saveInBackground()
//        images.append(imageObject)
//        
//        // Options
//        for var i = 0; i < optionImageThumbs.count; i++ {
//            var imageObject = PFObject(className: "QImages")
//            
//            let imageThumb = PFFile(name: "option\(i)ImageThumb.png", data: optionImageThumbs[i]!)
//            imageObject.setObject(imageThumb, forKey: "thumbnail")
//            
//            let imageFull = PFFile(name: "option\(i)ImageFull.png", data: optionImageFull[i]!)
//            imageObject.setObject(imageFull, forKey: "fullResolution")
//            
//            imageObject.saveInBackground()
//            images.append(imageObject)
//        }
//        /////////////////////////////////////////////////////////////////////////////////////////
//        
//        var questionObject = PFObject(className: "SocialQs")
//        
//        /////////////////////////////////////////////////////////////////////////////////////////
//        // Build Stats table entry
//        var statsObject = PFObject(className: "Stats")
//        statsObject.setObject(questionObject, forKey: "question")
//        //statsObject.saveInBackground()
//        /////////////////////////////////////////////////////////////////////////////////////////
//        
//        
//        /////////////////////////////////////////////////////////////////////////////////////////
//        // Build SocialQs table entry
//        questionObject.setObject(questionText, forKey: "questionText")
//        questionObject.setObject(optionText, forKey: "optionText")
//        questionObject.setObject(images, forKey: "images")
//        questionObject.setObject(statsObject, forKey: "Stats")
//        /////////////////////////////////////////////////////////////////////////////////////////
//        
//        
//        /////////////////////////////////////////////////////////////////////////////////////////
//        // Build QJoin Entries
//        var toUsers: [PFObject] = []
//        var userQuery = PFQuery(className: "_User")
//        
//        // Here, sepearte account types and address as needed
//        let toFacebookIds = Array(to.values) // Extract values from dictionary
//        userQuery.whereKey("facebookId", containedIn: toFacebookIds)
//        userQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//            
//            if error == nil {
//                
//                if let users = objects {
//                    
//                    for user in users {
//                        var qJoin = PFObject(className: "QJoin")
//                        //qJoin.setObject(from, forKey: "asker")
//                        qJoin.setObject(user, forKey: "to")
//                        qJoin.setObject(asker, forKey: "from")
//                        qJoin.setObject(false, forKey: "deleted")
//                        qJoin.setObject(questionObject, forKey: "question")
//                        
//                        toUsers.append(qJoin)
//                    }
//                    
//                    PFObject.saveAllInBackground(toUsers, block: { (success, error) -> Void in })
//                }
//                
//            } else {
//                //
//            }
//        }
//        /////////////////////////////////////////////////////////////////////////////////////////
//    }
//    
//    
//    
//    func downloadQs(toUser: PFObject, myQs: Bool, entries: ???) -> [PFObject] {
//        
//        var qJoinObjects: [PFObject] = []
//        
//        // I'm not sure about "myQs: Bool" as we may need 
//        // a third option to get all Qs that are to user
//        
//        // "entries" - a variable to define which entries to get,
//        // this should allow the future implementation of paginated
//        // queries/display
//        
//        let qJoinQuery = PFQuery(className: "QJoin")
//        qJoinQuery.whereKey("to", equalTo: toUser)
//        if myQs == true {
//            qJoinQuery.whereKey("from", equalTo: toUser)
//        } else {
//            qJoinQuery.whereKey("from", notEqualTo: toUser)
//        }
//        
//        qJoinQuery.orderByDescending("createdAt")
//        qJoinQuery.whereKey("deleted", equalTo: false)
//        qJoinQuery.includeKey("from")
//        qJoinQuery.includeKey("question")
//        qJoinQuery.??? // pagination stuffs
//        //qJoinQuery.limit = 1000
//        
//        qJoinQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
//            
//            if error == nil {
//                
//                qJoinObjects = objects
//        
//            } else {
//                
//                print("There was an error retrieving new Qs from the database:")
//                print(error)
//            }
//        })
//        
//        return qJoinObjects
//    }
//    
//    
//    
//    
//    func downloadStats(question: PFObject) -> Dictionary<String, Int> {
//        
//        var stats: Dictionary<String, Int> = [:]
//        
//        var statsQuery = PFQuery(className: "Stats")
//        statsQuery.whereKey("objectId", equalTo: question["stats"]["objectId"] as! String)
//        
//        statsQuery.findObjectsInBackgroundWithBlock { (object, error) -> Void in
//            
//            if error == nil {
//            
//                var i = 0;
//                
//                // Loop through all columns and build dictionary of stats to return
//                while let temp = object![0]["option\(i)stats"] {
//                    
//                    stats["option\(i)stats"] = object![0]["option\(i)stats"]
//                }
//            }
//        }
//        
//        return stats
//    }
//    
//    
//    
//    
//    func sendNewQuestionPushes(to: Dictionary<String, String>, from: [PFObject]) {
//        
//        let toUsers: PFQuery = PFUser.query()!
//        let pushQuery: PFQuery = PFInstallation.query()!
//        
//        // Here, sepearte account types and address as needed
//        let toFacebookIds = Array(to.values) // Extract values from dictionary
//        toUsers.whereKey("facebookId", containedIn: toFacebookIds)
//        pushQuery.whereKey("user", matchesQuery: toUsers)
//        
//        let pushDirected: PFPush = PFPush()
//        pushDirected.setQuery(pushQuery)
//        pushDirected.setMessage("New Q from \(from)!")
//        
//        // Send Push Notifications
//        pushDirected.sendPushInBackgroundWithBlock({ (success, error) -> Void in
//            
//            if error == nil {
//                
//                print("Directed push notifications sent!")
//                
//            } else {
//                
//                print("There was an error sending notifications")
//            }
//        })
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
////    func submitQuestion(askerObjectId: String, toObjectIds: [String], questionText: String,  questionImageThumb: NSData, questionImageFull: NSData, optionText: Dictionary<Int, String>, optionImageThumbs: Dictionary<Int, NSData>, optionImageFull: Dictionary<Int, NSData>) {
////        
////        /////////////////////////////////////////////////////////////////////////////////////////
////        // Build QImage entries (full res and thumbs)
////        var images: [PFObject] = []
////        
////        // Q
////        var imageObject = PFObject(className: "QImages")
////        
////        let imageThumb = PFFile(name: "questionImageThumb.png", data: questionImageThumb)
////        imageObject.setObject(imageThumb, forKey: "thumbnail")
////        
////        let imageFull = PFFile(name: "quesitonImageFull.png", data: questionImageFull)
////        imageObject.setObject(imageFull, forKey: "fullResolution")
////        
////        imageObject.saveInBackground()
////        images.append(imageObject)
////        
////        // Options
////        for var i = 0; i < optionImageThumbs.count; i++ {
////            var imageObject = PFObject(className: "QImages")
////            
////            let imageThumb = PFFile(name: "option\(i)ImageThumb.png", data: optionImageThumbs[i]!)
////            imageObject.setObject(imageThumb, forKey: "thumbnail")
////            
////            let imageFull = PFFile(name: "option\(i)ImageFull.png", data: optionImageFull[i]!)
////            imageObject.setObject(imageFull, forKey: "fullResolution")
////            
////            imageObject.saveInBackground()
////            images.append(imageObject)
////        }
////        /////////////////////////////////////////////////////////////////////////////////////////
////        
////        
////        /////////////////////////////////////////////////////////////////////////////////////////
////        // Build SocialQs table entry
////        var questionObject = PFObject(className: "SocialQs")
////        questionObject.setObject(questionText, forKey: "questionText")
////        questionObject.setObject(optionText, forKey: "optionText")
////        questionObject.setObject(images, forKey: "images")
////        /////////////////////////////////////////////////////////////////////////////////////////
////        
////        
////        /////////////////////////////////////////////////////////////////////////////////////////
////        // Build QJoin Entries
////        var toUsers: [PFObject] = []
////        var userQuery = PFQuery(className: "_User")
////        userQuery.whereKey("objectId", containedIn: toObjectIds + [askerObjectId])
////        userQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
////            
////            if error == nil {
////                
////                if let users = objects {
////                    
////                    var asker = PFObject()
////                    
////                    for user in users {
////                        if user.objectId! == askerObjectId {
////                            asker = user
////                            questionObject.setObject(asker, forKey: "asker")
////                            questionObject.saveInBackground()
////                            return
////                        }
////                    }
////                    
////                    for user in users {
////                        var qJoin = PFObject(className: "QJoin")
////                        //qJoin.setObject(from, forKey: "asker")
////                        qJoin.setObject(user, forKey: "to")
////                        qJoin.setObject(asker, forKey: "from")
////                        qJoin.setObject(false, forKey: "deleted")
////                        qJoin.setObject(questionObject, forKey: "question")
////                        
////                        toUsers.append(qJoin)
////                    }
////                    
////                    PFObject.saveAllInBackground(toUsers, block: { (success, error) -> Void in })
////                }
////                
////            } else {
////                //
////            }
////        }
////        /////////////////////////////////////////////////////////////////////////////////////////
////    }
//}
//
//
//
//
//
//
//
