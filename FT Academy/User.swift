////
////  Meal.swift
////  FoodTracker
////
////  Created by Jane Appleseed on 5/26/15.
////  Copyright © 2015 Apple Inc. All rights reserved.
////  See LICENSE.txt for this sample’s licensing information.
////
//
//import UIKit
//
//class User: NSObject, NSCoding {
//    // MARK: Properties
//    
//    var userid: String
//    
//    // MARK: Archiving Paths
//    
//    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("users")
//    
//    // MARK: Types
//    
//    struct PropertyKey {
//        static let useridKey = "userid"
//    }
//    
//    // MARK: Initialization
//    
//    init?(userid: String) {
//        // Initialize stored properties.
//        self.userid = userid
//        
//        super.init()
//        
//        // Initialization should fail if there is no name or if the rating is negative.
//        if userid.isEmpty {a
//            return nil
//        }
//    }
//    
//    // MARK: NSCoding
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(userid, forKey: PropertyKey.useridKey)
//    }
//    
//    required convenience init?(coder aDecoder: NSCoder) {
//        let userid = aDecoder.decodeObjectForKey(PropertyKey.useridKey) as! String
//        
//        
//        // Must call designated initializer.
//        self.init(userid: userid)
//    }
//    
//}