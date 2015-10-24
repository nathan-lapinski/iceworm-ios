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
var name = ""

// Profile Picture variables
var profilePicture = UIImage?()

// Objects to hold questions
var myAlreadyRetrieved = [String]()
var myQJoinObjects: [AnyObject] = []
var theirAlreadyRetrieved = [String]()
var theirQJoinObjects: [AnyObject] = []

// Variables to keep track of badge counts
var myQsBadgeCount: Int = 0
var theirQsBadgeCount: Int = 0
var theirVotesBadgeCount: Int = 0
//var myVotesBadgeCount: Int = 0 // Don't need this, we know when WE'VE voted :P

// Blank Qs Qs
var noTheirQJoinObjects: PFObject? = nil
var noMyQJoinObjects: PFObject? = nil

// Set constants for formatting buttons - universal settings
let bgAlpha: CGFloat = 0.7
let bgColor = UIColor(red: 58/255, green: 154/255, blue: 188/255, alpha: bgAlpha)
let winColor = UIColor(red: 58/255, green: 154/255, blue: 188/255, alpha: 1.0)
let loseColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
let buttonBackgroundColor = UIColor(red: 239/256, green: 239/256, blue: 240/256, alpha: 0.8)
let buttonTextColor = UIColor(red: 11/256, green: 11/256, blue: 11/256, alpha: 1.0)
let cornerRadius: CGFloat = 2.0

// Colors to match SQ background images
let mainColorBlue = UIColor(red: 83/255, green: 138/255, blue: 159/255, alpha: 1.0) // winColor //
let mainColorPink = UIColor(red: 194/255, green: 55/255, blue: 109/255, alpha: 1.0)
let mainColorRed = UIColor(red: 238/255, green: 76/255, blue: 80/255, alpha: 1.0)
let mainColorYellow = UIColor(red: 242/255, green: 206/255, blue: 58/255, alpha: 1.0)
let mainColorTeal = UIColor(red: 96/255, green: 190/255, blue: 185/255, alpha: 1.0)
let mainColorDarkBlue = UIColor(red: 46/255, green: 64/255, blue: 86/255, alpha: 1.0)

// Tab bar colors
let activeTabColor = UIColor.whiteColor()
let inactiveTabColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)

// NSUserDefault Storage Keys - Move to login later ("myName" does nothing in this case)
var usernameStorageKey  = "username"
var nameStorageKey      = "name"
var uIdStorageKey       = "uId"
var myFriendsStorageKey = "myFriends"

// Dictionary to pass question value to "view votes" controller
var viewQ = Dictionary<String, Any>()
var isUploading = [String]()

// Friends and Groupies variables
var groupiesGroups = [Dictionary<String,AnyObject>]()
var friendsDictionary = [Dictionary<String, AnyObject>]()
var friendsPhotoDictionary = Dictionary<String, UIImage>()
var friendsDictionaryFiltered = [Dictionary<String, AnyObject>]()
var isGroupieName = [String]()
var groupiesDictionary = [Dictionary<String, AnyObject>]()
var myGroups = [String]() // Stores strings of group names
var myFriends = [String]() // Stores usernames of socialQs-typed users


// Variable for passing image to zoom and on which image to start (1 or 2)
var questionToView: PFObject? = nil
var zoomPage = Int()

// Variable to tell if returning from a popover (ie: don't refresh table)
var returningFromSettings = false
//var returningFromPopover = false
var topOffset = CGFloat(0)
var myViewReturnedOnce = false
var theirViewReturnedOnce = false

// Groupies variable
var logoutAttempt = false
var warningSeen = false

// popDirection
var popDirection = "top"
var popInset = CGFloat(30.0)
var popErrorMessage = ""

