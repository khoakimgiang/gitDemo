//
//  Message.swift
//  Message_VQ
//
//  Created by Van Quang on 3/11/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class Message : NSObject {
    var formid : String?
    var text : String?
    var date : NSNumber?
    var toid : String?
    var imgurl : String?
    var imgHeight : NSNumber?
    var imgWidth: NSNumber?
    var videoUrl: String?
//    init (dic : [String : AnyObject]){
//        super.init()
//        self.formid = dic["forid"] as? String
//        self.text = dic["text"] as? String
//        self.date = dic["date"] as? NSNumber
//        self.toid = dic["toid"] as? String
//        self.imgurl = dic["imgurl"] as? String
//        self.imgHeight = dic["imgHeight"] as? NSNumber
//        self.imgWidth = dic["imgWidth"] as? NSNumber
//        
//    }
    func chatPartnerId() -> String {
       
        if formid == FIRAuth.auth()?.currentUser?.uid{
           return toid!
        }
        else {
            return formid!
        }
    }
}
