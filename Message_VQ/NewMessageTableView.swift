//
//  NewMessageTableView.swift
//  Message_VQ
//
//  Created by Van Quang on 3/7/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class NewMessageTableView: UITableViewController {
    
    var Users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(Canceled))
       fetchUser()
        
        tableView.register(UserViewCell.self, forCellReuseIdentifier: "cellid")
    }
    
    func Canceled(){
        self.dismiss(animated: true, completion: nil)
    }

    func fetchUser(){
        FIRDatabase.database().reference().child("user").observe(.childAdded, with: { (snapshot) in
            // print(snapshot)
            if let diction = snapshot.value as? [String : AnyObject] {
                let user  = User()
                user.setValuesForKeys(diction)
                user.toid = snapshot.key
               // print(user.name)
                
                if user.toid != FIRAuth.auth()?.currentUser?.uid{
                self.Users.append(user)
                }
                //DispatchQueue.global(qos: .userInitiated).async {
                    
                    DispatchQueue.main.async {
                            self.tableView.reloadData()
                    }
               // }
            }
        }, withCancel: nil)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellid")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! UserViewCell
        cell.lbName.text = self.Users[indexPath.row].name
        cell.lbEmail.text = self.Users[indexPath.row].email
        cell.proFileImage.contentMode = .scaleAspectFill // full size image
        if let url = self.Users[indexPath.row].profileImage {
            cell.proFileImage.loadImage(url: url)
        }
        return cell
    }
    var Viewcontroller : ViewController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("dissmmiis")
        let user = self.Users[indexPath.row]
        
        self.Viewcontroller?.nextChatforUser(user: user)

        //self.navigationController?.popViewController(animated: true){
            
     //   }
//        self.dismiss(animated: true) {
//                    }
    }
    
}
class UserViewCell: UITableViewCell {
    
    let proFileImage : UIImageView = {
        let img = UIImageView()
        img.image = UIImage()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 24
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
    
    override  init(style: UITableViewCellStyle , reuseIdentifier : String?){
        super.init(style: .subtitle , reuseIdentifier : reuseIdentifier)
        
        
        addSubview(proFileImage)
        addSubview(lbName)
        addSubview(lbEmail)
        proFileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        proFileImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        proFileImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
        proFileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        lbName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        lbName.leftAnchor.constraint(equalTo: proFileImage.rightAnchor, constant: 10).isActive = true
        lbName.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        lbName.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -80).isActive = true
        
        lbEmail.heightAnchor.constraint(equalToConstant: 20).isActive = true
        lbEmail.topAnchor.constraint(equalTo: lbName.bottomAnchor, constant: 0).isActive = true
        lbEmail.leftAnchor.constraint(equalTo: proFileImage.rightAnchor, constant: 10).isActive = true
        lbEmail.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -80).isActive = true
        
                
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("")
    }
}

