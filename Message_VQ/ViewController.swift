//
//  ViewController.swift
//  Message_VQ
//
//  Created by Van Quang on 3/6/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ViewController: UITableViewController {
    func checkInternet(){
        if Singleton.sharedInstance.isInternetAvailable() == true {
            print("internet")
        }
        else {
            print("no internet")
            let alert = UIAlertController(title: "No internet connection", message: "Go to setting????", preferredStyle: .alert)
            let alertOk = UIAlertAction(title: "OK", style: .default, handler: { (default) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
            let alertCancel  =  UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(alertOk)
            alert.addAction(alertCancel)
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkInternet()
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellid)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logout))
        if FIRAuth.auth()?.currentUser?.uid == nil {
            logout()
        }
        else {
            checkUserIsLogin()
        }
      
       
}
// get Mesage
    var messages  =  [Message]()
    var messagesDic = [String : Message]()
    
    func observeUserMessage () {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot1) in
            let messageid = snapshot1.key
            let messageReference = FIRDatabase.database().reference().child("Message").child(messageid)
            
            messageReference.observe(.value, with: { (snapshot) in
                
                //print(snapshot)
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    //self.messages.append(message)
                    if let chatpart : String = message.chatPartnerId() {
                        self.messagesDic[chatpart] = message
                        self.messages = Array(self.messagesDic.values)
                        self.messages = self.messages.sorted(by: { (message1, message2) -> Bool in
                            return (message1.date?.intValue)! > (message2.date?.intValue)!
                        })
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }

                
            }, withCancel: nil)
            
            
            
            
        }, withCancel: nil)
    }
    
    
    func obserMessage(){
        messages.removeAll()

        let ref =  FIRDatabase.database().reference().child("Message")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                //self.messages.append(message)
                if let id = message.toid {
                    self.messagesDic[id] = message
                    self.messages = Array(self.messagesDic.values)
                    self.messages = self.messages.sorted(by: { (message1, message2) -> Bool in
                        return (message1.date?.intValue)! > (message2.date?.intValue)!
                    })
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }

        }, withCancel: nil)
        
    }
    
func checkUserIsLogin(){
        let Uid = FIRAuth.auth()?.currentUser?.uid // uid là id của mỗi user
        FIRDatabase.database().reference().child("user").child(Uid!).observeSingleEvent(of: .value, with: { (snapshot) in
           
            
            if let diction = snapshot.value as? [String : AnyObject] {
               
                
                let img = UIImage.init(named: "001-edit.png")
               
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(self.newMessage))
               
                let user  = User()
                user.setValuesForKeys(diction)
                
                self.setViewNaviBar(user: user)
                
            }
            
            
        }, withCancel: nil)
    }
    
    
    // table
    var cellid = "cellid"
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        if let id : String =  message.chatPartnerId(){
            let ref = FIRDatabase.database().reference().child("user").child(id)
            ref.observe(.value, with: { (snapshot) in
              
                if let dictionary = snapshot.value as? [String : AnyObject]{
                    cell.lbName.text = dictionary["name"] as! String?
                    cell.lbEmail.text = message.text
                    
                    if let url = dictionary["profileImage"] {
                        cell.proFileImage.loadImage(url: url as! String)
                    }
                    //cell.lbDate.text = message.date?.stringValue
                    let date = NSDate(timeIntervalSinceReferenceDate: Double((message.date?.doubleValue)!))
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss a"
                    let someDateTime = formatter.string(from: date as Date)
                  //  print(someDateTime)
                     cell.lbDate.text = someDateTime
                    


                }
            
            }, withCancel: nil)
            
        }
       
        
        
        return cell

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatpartnerID : String = message.chatPartnerId() else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user").child(chatpartnerID)
        ref.observe(.value, with: { (snapshot) in
            
            
            guard let dic  = snapshot.value as? [String : AnyObject] else{
                return
            }
            let user = User()
            user.toid = chatpartnerID
            user.setValuesForKeys(dic)
            self.nextChatforUser(user: user)
            
            
        }, withCancel: nil)
        
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
//
//            self.tableView.reloadData()
            
            guard let uid  = FIRAuth.auth()?.currentUser?.uid else {
                return
            }
            
            let message = self.messages[indexPath.row]
            if let chatpart : String = message.chatPartnerId() {
                FIRDatabase.database().reference().child("user-messages").child(chatpart).removeValue(completionBlock: { (error, ref) in
                     let ref =  FIRDatabase.database().reference().child("user-messages").child(uid)
                    ref.observe(.childRemoved, with: { (snapshots) in
                        let key = snapshots.key
                        FIRDatabase.database().reference().child("Message").child(key).removeValue()
                    })
                    ref.removeValue()
                    if error != nil {
                        return
                    }
                    self.messagesDic.removeValue(forKey: chatpart)
                    self.messages.remove(at: indexPath.row)
                    self.tableView.reloadData()
                    
                })
            
            }
            
            
        }
    }
    
    func setViewNaviBar(user: User){
        messages.removeAll()
        messagesDic.removeAll()
        
        
        observeUserMessage()
       // self.tableView.reloadData()
 
        let profileImageView : UIImageView = {
           let img = UIImageView()
            img.translatesAutoresizingMaskIntoConstraints = false
            img.loadImage(url: user.profileImage!)
            img.layer.cornerRadius = 25
          //  img.backgroundColor = UIColor.gray
            img.layer.masksToBounds = true
            return img
        }()
        let titleName : UILabel = {
           let lbl = UILabel()
            lbl.text = user.name
            lbl.translatesAutoresizingMaskIntoConstraints = false
            //lbl.backgroundColor = UIColor.blue
            return lbl
        }()
        let titleView = UIView()
       
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        
        let constrainView = UIView()
        constrainView.translatesAutoresizingMaskIntoConstraints = false
        //constrainView.backgroundColor = UIColor.red
        titleView.addSubview(constrainView)
//
        constrainView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        constrainView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        constrainView.widthAnchor.constraint(equalTo: titleView.widthAnchor).isActive = true
        constrainView.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
//       
        
        constrainView.addSubview(profileImageView)
        profileImageView.rightAnchor.constraint(equalTo: constrainView.centerXAnchor , constant : 5).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: constrainView.centerYAnchor).isActive = true
        constrainView.addSubview(titleName)
        titleName.leftAnchor.constraint(equalTo: constrainView.centerXAnchor , constant : 5).isActive = true
        titleName.centerYAnchor.constraint(equalTo: constrainView.centerYAnchor).isActive = true
        titleView.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        titleView.rightAnchor.constraint(equalTo: constrainView.rightAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextChat)))
    }
    func nextChatforUser(user: User){
        let chatViewController = ChatViewController()
        chatViewController.user = user
        chatViewController.collection.reloadData()
        
        navigationController?.pushViewController(chatViewController, animated: true)
       
    }
    func newMessage(){
        
        let vc = NewMessageTableView()
        vc.Viewcontroller = self
       // let navc  = UINavigationController(rootViewController: vc)
        
        navigationController?.pushViewController(vc, animated: true)
        //present(navc, animated: true, completion: nil)
    }
    func logout(){
        do{
          try  FIRAuth.auth()?.signOut()
            
        }catch let error {
            //print(error)
        }
        print("logout")
        let login = LoginViewController()
        login.controller = self
      present(login, animated: true, completion: nil)
    }

   


}

