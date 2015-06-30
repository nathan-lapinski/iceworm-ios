//
//  Globals.swift
//  SocialQs
//
//  Created by Brett Wiesman on 6/17/15.
//  Copyright (c) 2015 BookSix. All rights reserved.
//

import Foundation
import UIKit

// Database values for local storage
var myName = ""
var uId = ""
var uQId = ""

// Set constants for formatting buttons - universal settings
let bgAlpha: CGFloat = 0.7

let bgColor = UIColor(red: 58/255, green: 154/255, blue: 188/255, alpha: bgAlpha)

let winColor = bgColor
let loseColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: bgAlpha)

let buttonAlpha: CGFloat = 0.8
let buttonBackgroundColor = UIColor(red: 239/256, green: 239/256, blue: 240/256, alpha: buttonAlpha)
let buttonTextColor = UIColor(red: 11/256, green: 11/256, blue: 11/256, alpha: 1.0)

let mainColorOrange = UIColor(red: 239/256, green: 94/256, blue: 31/256, alpha: 1.0)
let mainColorBlue = UIColor(red: 58/256, green: 154/256, blue: 188/256, alpha: 1.0)
let mainColorPink = UIColor(red: 194/256, green: 55/256, blue: 109/256, alpha: 1.0)

let cornerRadius: CGFloat = 2.0

let insets: CGFloat = 5
let buttonEdge = UIEdgeInsetsMake(insets, insets, insets, insets)


var deletedMyQuestions = [String]() // questions DELETED by current user
var dismissedTheirQuestions = [String]() // questions ANSWERED by current user
var deletedTheirQuestions = [String]() // questions DELETED by current user