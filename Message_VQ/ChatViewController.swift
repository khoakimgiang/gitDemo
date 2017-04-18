//
//  ChatViewController.swift
//  Message_VQ
//
//  Created by Van Quang on 3/11/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MobileCoreServices
import AVFoundation
class ChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    
    var user : User?{
        didSet{
            navigationItem.title = user?.name
            getMessage()
        }
    }
    var message = [Message]()
 // set Message
    func getMessage(){
        
        guard let id = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child((id))
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            
            let mRef = FIRDatabase.database().reference().child("Message").child(messageID)
            mRef.observe(.value, with: { (snapshot) in
                guard let dic = snapshot.value as? [String : AnyObject] else{
                    return
                }
                let message = Message()
                message.setValuesForKeys(dic)
                if( message.toid == self.user?.toid || message.formid == self.user?.toid){
                    self.message.append(message)
                }
                DispatchQueue.main.async {
                    self.collection.reloadData()
                    if(self.message.count - 1 > 0){
                    let Indexpatd = NSIndexPath(row: self.message.count - 1, section: 0)
                        
                        self.collection.scrollToItem(at: Indexpatd as IndexPath, at: .bottom, animated: true)
                    }
                    
                }
                
            }, withCancel: nil )
            
            
        }, withCancel: nil)
        
    }
    
    lazy var tfChat : UITextField = {
        let tf = UITextField()
        tf.placeholder = "write message"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()
    
    // colectionview
    let collection : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // check internet
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

// setupView
    var bottomCollection : NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkInternet()
        
        view.backgroundColor = UIColor.white
        view.addSubview(collection)

        collection.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8).isActive = true
        collection.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        collection.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bottomCollection = collection.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
        bottomCollection?.isActive = true
        
        
        collection.backgroundColor = UIColor.clear
        collection.delegate = self
        collection.dataSource = self
        collection.register(chatCell.self, forCellWithReuseIdentifier: cellid)
        
        collection.keyboardDismissMode = .interactive
        collection.alwaysBounceVertical = true
        // call keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
//make bottom collection
       //show keyboard
        func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.bottomCollection?.isActive = false
                self.bottomCollection?.constant = ( -10 - (keyboardSize.height))
                self.bottomCollection?.isActive = true
                DispatchQueue.main.async {
                if(self.message.count - 1 > 0){
                    let Indexpatd = NSIndexPath(row: self.message.count - 1, section: 0)
                    
                    self.collection.scrollToItem(at: Indexpatd as IndexPath, at: .bottom, animated: true)
                }
                }
            }
        }
        // hide keyboard
        func keyboardWillHide(notification: NSNotification) {
//
            self.bottomCollection?.isActive = false
            self.bottomCollection?.constant = -10
            self.bottomCollection?.isActive = true
//
        }
    
// set ViewChatText and btnSend
    lazy var setViewChat : UIView = {
        let ViewContainer = UIView()
        ViewContainer.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 50)
        
        let chat = UIView()
        chat.translatesAutoresizingMaskIntoConstraints = false
        ViewContainer.addSubview(chat)
        chat.centerXAnchor.constraint(equalTo: ViewContainer.centerXAnchor).isActive = true
        chat.centerYAnchor.constraint(equalTo: ViewContainer.centerYAnchor).isActive = true
        chat.leftAnchor.constraint(equalTo: ViewContainer.leftAnchor).isActive = true
        chat.topAnchor.constraint(equalTo: ViewContainer.topAnchor).isActive = true
        
        let ImgUpload = UIImageView()
        ImgUpload.translatesAutoresizingMaskIntoConstraints = false
        ImgUpload.image = UIImage.init(named:"write-compose-2-128.png")
        chat.addSubview(ImgUpload)
        ImgUpload.isUserInteractionEnabled = true
        ImgUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addImg)))
        ImgUpload.leftAnchor.constraint(equalTo: chat.leftAnchor , constant: 5).isActive = true
        ImgUpload.widthAnchor.constraint(equalToConstant: 30).isActive = true
        ImgUpload.heightAnchor.constraint(equalToConstant: 30).isActive = true
        ImgUpload.centerYAnchor.constraint(equalTo: chat.centerYAnchor).isActive  = true
        
        let send = UIButton()
        send.translatesAutoresizingMaskIntoConstraints = false
        send.setTitle("send", for: .normal)
        send.setTitleColor(UIColor.blue, for: .normal)
        
        chat.addSubview(send)
        send.rightAnchor.constraint(equalTo: chat.rightAnchor, constant: -8).isActive = true
        send.heightAnchor.constraint(equalToConstant: 48).isActive = true
        send.widthAnchor.constraint(equalToConstant: 70).isActive = true
        send.centerYAnchor.constraint(equalTo: chat.centerYAnchor).isActive = true
        send.addTarget(self, action: #selector(sender), for: .touchUpInside)
        
        
        chat.addSubview(self.tfChat)
        self.tfChat.leftAnchor.constraint(equalTo: ImgUpload.rightAnchor , constant: 8).isActive = true
        self.tfChat.centerYAnchor.constraint(equalTo: chat.centerYAnchor
            ).isActive = true
        self.tfChat.rightAnchor.constraint(equalTo: send.leftAnchor).isActive = true
        self.tfChat.heightAnchor.constraint(equalTo: send.heightAnchor).isActive = true
        
        let vBlack = UIView()
        vBlack.translatesAutoresizingMaskIntoConstraints = false
        vBlack.backgroundColor = UIColor.black
        
        chat.addSubview(vBlack)
        vBlack.heightAnchor.constraint(equalToConstant: 1).isActive = true
        vBlack.widthAnchor.constraint(equalTo: chat.widthAnchor).isActive = true
        vBlack.topAnchor.constraint(equalTo: chat.topAnchor).isActive = true
        vBlack.leftAnchor.constraint(equalTo: chat.leftAnchor).isActive = true
        return ViewContainer
        
    }()
    
    
    
// chose img
    func addImg(){
        let picker  = UIImagePickerController()
        picker.allowsEditing = true // view all image
        //picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String] // thay cho soureType : img + movie
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] {
            // upload a video
            
            let filename = NSUUID().uuidString + ".mov"
            let uploadTask = FIRStorage.storage().reference().child(filename).putFile(videoUrl as! URL, metadata: nil, completion: { (meta, error) in
                

                if error != nil {
                    return
                }
                if let storageUrl = meta?.downloadURL()?.absoluteString {
                    print(storageUrl)
                    
                    
                    let imgThumbnail = self.thumbnailForVideo(videoUrl: videoUrl as! NSURL )
               
                    self.uploatToFirebaseUsingImg(img: imgThumbnail! , videoUrl: storageUrl)
                    
                
                    
                }
            
            
            })
            // uploadding
            uploadTask.observe(.progress, handler: { (
                snapshot) in
                self.navigationItem.title = String(describing: snapshot.progress?.completedUnitCount)
            })
            
            // upload finish
            uploadTask.observe(.success, handler: { (
                snapshot) in
                //
                self.navigationItem.title = self.user?.name
            })
            
        }
            
        else{
        // upload a image
        var imgSelected = UIImage()
        if let editedImamge = info["UIImagePickerControllerEditedImage"]{ // Zoom +
            
            imgSelected = editedImamge as! UIImage
        }
        else {
            if let originalImage = info["UIImagePickerControllerOriginalImage"] { //
                
                imgSelected = originalImage as! UIImage
                
            }
        }
            
            uploatToFirebaseUsingImg(img: imgSelected, videoUrl: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    // copy img from video
    private func thumbnailForVideo(videoUrl : NSURL) -> UIImage? {
        let asset = AVAsset(url: videoUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnail  = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnail)
        }catch let error {
            
        }
        return nil
    }
    
    private func uploatToFirebaseUsingImg(img : UIImage , videoUrl : String? ){
        let name = NSUUID().uuidString // name img chose????
       // print(name)
        let ref = FIRStorage.storage().reference().child("message-image").child(name)
        
        if let uploadData = UIImageJPEGRepresentation(img, 0.2){
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
               
                if let downloadImg  = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWitdUrlimg(imgurl: downloadImg,img : img ,videoUrl: videoUrl)
                }
                
            })
        }
        
        
        
    }
    // send Img
    private func sendMessageWitdUrlimg(imgurl: String,img: UIImage, videoUrl : String? ) {
        
        let ref = FIRDatabase.database().reference().child("Message")
        let ref1 = ref.childByAutoId()
        let From = FIRAuth.auth()?.currentUser?.uid
        let dateTime = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        var value = [ "toid" : user?.toid as AnyObject, "formid" : From as AnyObject , "date" : dateTime , "imgurl" : imgurl as AnyObject , "imgHeight" : img.size.height as AnyObject, "imgWidth" : img.size.width as AnyObject] as [String : AnyObject]
        if videoUrl != nil{
            
            value["videoUrl"] = videoUrl as AnyObject?
        }
        
        
        
        
        ref1.updateChildValues(value) { (error, ref) in
            if error != nil {
                return
            }
            let userMessageref = FIRDatabase.database().reference().child("user-messages").child(From!)
            let messageid = ref1.key
            userMessageref.updateChildValues([messageid : 1])
            
            
            let userMessageref1 = FIRDatabase.database().reference().child("user-messages").child((self.user?.toid)!)
            
            userMessageref1.updateChildValues([messageid : 1])
            
        }
        
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker")
        self.dismiss(animated: true, completion: nil)
    }
    //
    var heightChat : NSLayoutConstraint?
    override var inputAccessoryView: UIView?{
        get{
            return setViewChat
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.message.count
    }
    let cellid = "cellid"
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! chatCell
        let message = self.message[indexPath.row]
        cell.text.text = message.text
        cell.message = message
        
        if let text = message.text {
            cell.viewTextWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 20
        }
        else if message.imgurl != nil {
            cell.viewTextWidthAnchor?.constant = 200 //message.imgWidth as! CGFloat
            
        }
        if message.videoUrl == nil {
            cell.btnPlay.isHidden = true
        }
        
        setupCell(cell: cell, mes:  message)
        
        cell.ChatView  = self
        return cell
    }
    private func setupCell(cell : chatCell ,  mes : Message){
        if let imgurl = self.user?.profileImage {
            cell.viewText.backgroundColor = UIColor.clear
            
            cell.profileImg.loadImage(url: imgurl)
            
        }
        
        if mes.formid == FIRAuth.auth()?.currentUser?.uid {
            cell.viewText.backgroundColor = UIColor.init(r: 100, g: 100, b: 240)
            cell.text.textColor = UIColor.white
            cell.viewTextleftAnchor?.isActive = false
            cell.viewTextRightAnchor?.isActive = true
            cell.profileImg.isHidden = true
        }
        else {
            cell.viewText.backgroundColor = UIColor.lightGray
            cell.text.textColor = UIColor.black
            cell.viewTextRightAnchor?.isActive = false
            cell.viewTextleftAnchor?.isActive = true
            cell.profileImg.isHidden = false
        }
        
        if let urlImg = mes.imgurl {
            cell.viewText.backgroundColor = UIColor.clear
            cell.profileImgWitdSended.loadImage(url: urlImg)
            cell.profileImgWitdSended.isHidden = false
        }
        else {
            
            cell.profileImgWitdSended.isHidden = true
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height = 100
        let message = self.message[indexPath.row]
        if let text = message.text {
            height = Int(estimateFrameForText(text: message.text!).height)
        } else if message.videoUrl != nil{
            
            height = Int((message.imgHeight as! CGFloat)/(message.imgWidth as! CGFloat)*200)
            return CGSize(width: Int(self.view.frame.width), height: height)
            
        }
        else if message.imgurl != nil {
            height = Int((message.imgHeight as! CGFloat)/(message.imgWidth as! CGFloat)*200)
            
        }
       
        return CGSize(width: Int(self.view.frame.width), height: height + 20)
    }
    // fix height
    private func estimateFrameForText(text: String) -> CGRect {
        let size  = CGSize(width: 200, height: 200)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    

    
    func sender(){
        let ref = FIRDatabase.database().reference().child("Message")
        let ref1 = ref.childByAutoId()
        let From = FIRAuth.auth()?.currentUser?.uid
        let dateTime = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let value = ["text" : tfChat.text! , "toid" : user?.toid, "formid" : From , "date" : dateTime] as [String : Any]
        
        
        //ref1.updateChildValues(value)
        ref1.updateChildValues(value) { (error, ref) in
            if error != nil {
                return
            }
            let userMessageref = FIRDatabase.database().reference().child("user-messages").child(From!)
            let messageid = ref1.key
            userMessageref.updateChildValues([messageid : 1])
            
            
            let userMessageref1 = FIRDatabase.database().reference().child("user-messages").child((self.user?.toid)!)
            
            userMessageref1.updateChildValues([messageid : 1])
            
        }
        
        
        tfChat.text = ""
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sender()
        return true
    }
    var viewZBack : UIView?
    var startFrame : CGRect?
    var zoomImgV : UIImageView?
    func zoomImageFromCell(imgView: UIImageView){
        //print("xxxxxxx")
        
        view.endEditing(true) // hidden keyBoard
        self.startFrame = imgView.superview?.convert(imgView.frame, to: nil) // get Frame Img in view
        
        self.zoomImgV = UIImageView(frame: startFrame!)
        zoomImgV?.image = imgView.image
        zoomImgV?.isUserInteractionEnabled = true
        zoomImgV?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        if let keywindow  = UIApplication.shared.keyWindow{
            self.viewZBack = UIView()
            viewZBack?.frame = keywindow.frame
            self.viewZBack?.backgroundColor = UIColor.black
            viewZBack?.alpha = 0
            viewZBack?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut(tapGes:))))
            
            keywindow.addSubview(viewZBack!)
            UIView.animate(withDuration: 0.5, animations: {
                self.viewZBack?.alpha = 1
                self.setViewChat.isHidden = true
                // h2/w2 = h1/w1
                let height =  CGFloat((self.startFrame?.height)! / (self.startFrame?.width)! * keywindow.frame.width)
                self.zoomImgV?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: keywindow.frame.width, height: height)
                self.zoomImgV?.center = keywindow.center
                keywindow.addSubview(self.zoomImgV!)
            }, completion: nil)
        }
        
    }
    func zoomOut(tapGes : UIGestureRecognizer){
       
            UIView.animate(withDuration: 0.5, animations: {
                self.zoomImgV?.frame = self.startFrame!
                self.viewZBack?.alpha = 0
            }, completion: { (complate: Bool) in
                self.zoomImgV?
                    .removeFromSuperview()
                self.viewZBack?.removeFromSuperview()
                self.setViewChat.isHidden = false
            })
            
            
        
    }
    
}
