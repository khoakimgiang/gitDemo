//
//  UserMessage.swift
//  Message_VQ
//
//  Created by Van Quang on 3/11/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
class UserCell: UITableViewCell {
    
    let proFileImage : UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.contentMode = .scaleAspectFill // full size image
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        
        return img
    }()
    let lbName : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textColor = UIColor.black
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    let lbEmail : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.textColor = UIColor.black
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    let lbDate : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.font  = .systemFont(ofSize: 14)
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        lbl.textColor  = UIColor.lightGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    override  init(style: UITableViewCellStyle , reuseIdentifier : String?){
        super.init(style: .subtitle , reuseIdentifier : reuseIdentifier)
        
        
        addSubview(proFileImage)
        addSubview(lbName)
        addSubview(lbEmail)
        proFileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        proFileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        proFileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        proFileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
       
        
        
        addSubview(lbDate)
        lbDate.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lbDate.heightAnchor.constraint(equalToConstant: 20).isActive = true
        lbDate.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        lbDate.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lbName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        lbName.leftAnchor.constraint(equalTo: proFileImage.rightAnchor, constant: 10).isActive = true
        lbName.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        lbName.rightAnchor.constraint(equalTo: lbDate.leftAnchor).isActive = true
        
        lbEmail.heightAnchor.constraint(equalToConstant: 20).isActive = true
        lbEmail.topAnchor.constraint(equalTo: lbName.bottomAnchor, constant: 0).isActive = true
        lbEmail.leftAnchor.constraint(equalTo: proFileImage.rightAnchor, constant: 10).isActive = true
        lbEmail.rightAnchor.constraint(equalTo: lbDate.leftAnchor).isActive = true

        
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("")
    }
}
