//
//  Globals.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/17/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import Foundation
import UIKit
import Parse

// Database values for local storage
var username = ""
var uId = ""
var uQId = ""
var name = ""

// Profile Picture variables
var profilePicture = UIImage?()

// Set constants for formatting buttons - universal settings
let bgAlpha: CGFloat = 0.7
let bgColor = UIColor(red: 58/255, green: 154/255, blue: 188/255, alpha: bgAlpha)
let winColor = UIColor(red: 58/255, green: 154/255, blue: 188/255, alpha: 1.0)
let loseColor = UIColor.lightGrayColor()//UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
let buttonBackgroundColor = UIColor(red: 239/256, green: 239/256, blue: 240/256, alpha: 0.8)
let buttonTextColor = UIColor(red: 11/256, green: 11/256, blue: 11/256, alpha: 1.0)
let cornerRadius: CGFloat = 2.0
//let insets: CGFloat = 5
//let buttonEdge = UIEdgeInsetsMake(insets, insets, insets, insets)

// Colors to match SQ background images
let mainColorBlue = UIColor(red: 58/256, green: 154/256, blue: 188/256, alpha: 1.0)
//let mainColorOrange = UIColor(red: 239/256, green: 94/256, blue: 31/256, alpha: 1.0)
let mainColorPink = UIColor(red: 194/256, green: 55/256, blue: 109/256, alpha: 1.0)

// Tab bar colors
let activeTabColor = UIColor.whiteColor()
let inactiveTabColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)

// NSUserDefault Storage Keys - Move to login later ("myName" does nothing in this case)
var usernameStorageKey  = "username"
var nameStorageKey      = "name"
var uIdStorageKey       = "uId"
var uQIdStorageKey      = "uQId"
var myFriendsStorageKey = "myFriends"

// Dictionary to pass question value to "view votes" controller
var viewQ = Dictionary<String, Any>()
var isUploading = [String]()

// Friends and Groupies variables
var groupiesGroups = [Dictionary<String,AnyObject>]()
var friendsDictionary = [Dictionary<String, AnyObject>]()
var friendsPhotoDictionary = Dictionary<String, UIImage>()
var friendsDictionaryFiltered = [Dictionary<String, AnyObject>]()
var nonFriendsDictionary = [Dictionary<String, AnyObject>]()
var nonFriendsDictionaryFiltered = [Dictionary<String, AnyObject>]()
var isGroupieName = [String]()
var groupiesDictionary = [Dictionary<String, AnyObject>]()
var myGroups = [String]() // Stores strings of group names
//var myFriendsDictionary = [Dictionary<String, AnyObject>]()
var myFriends = [String]() // Stores usernames of socialQs-typed users
// Array to store non-FB friends
//var mySocialQsFriends = [String]()

// Variable for passing image to zoom and on which image to start (1 or 2)
//var imageZoom: [UIImage?] = [nil, nil, nil]//[UIImage(named: "camera.png"), UIImage(named: "camera.png"), UIImage(named: "camera.png")]
var questionToView: PFObject? = nil
var zoomPage = Int()

// Variable to tell if returning from a popover (ie: don't refresh table)
var returningFromSettings = false
var returningFromPopover = false
var topOffset = CGFloat(0)
var myViewReturnedOnce = false
var theirViewReturnedOnce = false

// Groupies variable

var logoutAttempt = false
var warningSeen = false

