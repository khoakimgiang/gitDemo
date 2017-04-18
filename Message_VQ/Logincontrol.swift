//
//  Logincontrol.swift
//  Message_VQ
//
//  Created by Van Quang on 3/7/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
extension LoginViewController :UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func Login(){
        
        self.hiddenViewLoading()
        
        guard let email = tfEmail.text, let password = tfPassWord.text , let name = tfName.text else{
            print("email or password nil")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                //print(error)
                self.viewLoading.isHidden = true
                let alertVC = UIAlertController(title: "Email used", message: "The email address is already in use by another account", preferredStyle: .alert)
                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                    (_) in
                   
                }
                alertVC.addAction(alertActionOkay)
                self.present(alertVC, animated: true, completion: nil)
                return
            }
 
                
            guard let uid = user?.uid else {
                return
            }
            
            
            //upload img
            
            let uploadData = UIImagePNGRepresentation(self.profileImage.image!)
            let storagate = FIRStorage.storage().reference().child("MyImage").child("\(uid).jpg")
            
            
            storagate.put(uploadData!, metadata: nil, completion: { (meta, error) in
                
                if error != nil {
                   // print(error)
                    return
                }
                //print(meta)
                
                
                if let urlString = meta?.downloadURL()?.absoluteString {
                    
                    let values = ["name" : name, "email" : email, "password" : password , "profileImage" : urlString] as [String : Any]
                    self.registerUserIntoDatabase(uid: uid, value: values as [String : AnyObject])
                    // set navi..Item.title
                    self.controller?.checkUserIsLogin()
                    self.dismiss(animated: true, completion: nil)
                }
                
                
            })
            
            // print("save user accessfully into Firebase")
        })
        
    }
    private func registerUserIntoDatabase(uid: String , value : [String : AnyObject]){
        
        let ref = FIRDatabase.database().reference(fromURL: "https://chatappvq.firebaseio.com/")
        let userRef = ref.child("user").child(uid)
        //
        userRef.updateChildValues(value, withCompletionBlock: { (error, ref) in
            if error != nil {
              //  print(error)
                return
            }
        })
    }
    
    func choseImage(){
        
        
        let picker  = UIImagePickerController()
        picker.allowsEditing = true // view all image
        picker.sourceType = .photoLibrary
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print(info)
        var imgSelected = UIImage()
        if let editedImamge = info["UIImagePickerControllerEditedImage"]{ // Zoom +
            //print((editedImamge as AnyObject).size)
            imgSelected = editedImamge as! UIImage
        }
        else {
            if let originalImage = info["UIImagePickerControllerOriginalImage"] { // Zoom = 100%
                //print((originalImage as AnyObject).size)
                
                imgSelected = originalImage as! UIImage
            }
        }
        // if case let sec == imgSelected {
        
        profileImage.image = imgSelected
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.layer.masksToBounds = true
        
        // }
        
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker")
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
