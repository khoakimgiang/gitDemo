
//  LoginViewController.swift
//  Message_VQ
//
//  Created by Van Quang on 3/6/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class LoginViewController: UIViewController , UITextFieldDelegate{
    
    var controller : ViewController? = nil
    
    
    //check Email
    func validateEmail(enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    //segmented Controller
    let segmented : UISegmentedControl = {
       let seg = UISegmentedControl(items: ["Login","Register"])
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.tintColor = UIColor.white
        seg.selectedSegmentIndex = 1
        seg.addTarget(self, action: #selector(selecSegmented), for: .valueChanged)
        return seg
    }()
    func selecSegmented(){
        print("click")
        let titlebtn = segmented.titleForSegment(at: segmented.selectedSegmentIndex)
        btnLogin.setTitle(titlebtn, for: .normal)
        
        // inputVIew
       
        //name textfield
        tfNameHeight?.isActive = false
        tfNameHeight = tfName.heightAnchor.constraint(equalTo: inputContrainView.heightAnchor, multiplier: segmented.selectedSegmentIndex == 0 ? 0 : 1/3)
        if segmented.selectedSegmentIndex == 0 {
            
            self.inputsViewHeightArchor?.isActive = false
            inputsViewHeightArchor = inputContrainView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 2/15)
            self.inputsViewHeightArchor?.isActive = true
            
            
            
            tfName.isHidden = true
        }
        else {
            
            self.inputsViewHeightArchor?.isActive = false
            inputsViewHeightArchor = inputContrainView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/5)
            self.inputsViewHeightArchor?.isActive = true
            
            
            tfName.isHidden = false
        }
        tfNameHeight?.isActive = true
        // email
        tfemailHeight?.isActive = false
        tfemailHeight = tfEmail.heightAnchor.constraint(equalTo: inputContrainView.heightAnchor, multiplier: segmented.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        tfemailHeight?.isActive = true
        //password
        tfpasswordHeight?.isActive = false
        tfpasswordHeight = tfPassWord.heightAnchor.constraint(equalTo: inputContrainView.heightAnchor, multiplier: segmented.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        tfpasswordHeight?.isActive = true
    }
    
    // profile Image
    lazy var profileImage :UIImageView = {
       let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage.init(named: "Telegram_Messenger.png")
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(choseImage)))
        img.isUserInteractionEnabled = true
       
        return img
    }()
    // view loading
    let activity : UIActivityIndicatorView = {
        let ac = UIActivityIndicatorView(activityIndicatorStyle: .white)
        ac.translatesAutoresizingMaskIntoConstraints = false
        ac.hidesWhenStopped  = true
        return ac
    }()
    
    let viewLoading : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black
        v.alpha = 0.3
        return v
    }()

    //Name
    let tfName :UITextField = {
       let txf = UITextField()
        txf.translatesAutoresizingMaskIntoConstraints = false
        txf.placeholder = "name"
        
        return txf
    }()
    let nameV : UIView = {
       let V = UIView()
        V.translatesAutoresizingMaskIntoConstraints = false
        V.backgroundColor = UIColor.darkGray
        return V
    }()
    
    //email
    
    let tfEmail :UITextField = {
        let txf = UITextField()
        txf.translatesAutoresizingMaskIntoConstraints = false
        txf.placeholder = "email"
        
        return txf
    }()
    let nameE : UIView = {
        let V = UIView()
        V.translatesAutoresizingMaskIntoConstraints = false
        V.backgroundColor = UIColor.darkGray
        return V
    }()

    //password
    let tfPassWord :UITextField = {
        let txf = UITextField()
        txf.translatesAutoresizingMaskIntoConstraints = false
        txf.placeholder = "password"
        
        return txf
    }()
   

    //View input
    
    let inputContrainView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
       
        return view
    }()

    // btn Login
    
    let btnLogin : UIButton = {
        let btn = UIButton(type:.system)
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor(r: 80, g: 111, b: 161)
        btn.addTarget(self, action: #selector(touchbtnLogin), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    func touchbtnLogin()  {
        self.dismissKeyboard()
        if(!validateEmail(enteredEmail: tfEmail.text!)){
            let alertVC = UIAlertController(title: "Error", message: "Email not Work", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Ok", style: .default) {
                (_) in
            }
            alertVC.addAction(alertActionOkay)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        if segmented.selectedSegmentIndex == 1 {
            Login()
            return
        }
        else {
            hiddenViewLoading()
            guard let email = tfEmail.text, let password = tfPassWord.text else{
                print("email or password nil")
                return
            }
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
                if error == nil{
                    
                    print("logIn succesfull")
                    self.controller?.checkUserIsLogin()
                    self.dismiss(animated: true, completion: nil)
                    
                }else{
                    
                    let typeError = FIRAuthErrorCode(rawValue: error!._code)!
                    switch typeError {
                    case .errorCodeUserNotFound:
                        
                            print("user not found")
                            self.viewLoading.isHidden = true
                            let alertVC = UIAlertController(title: "Error", message: "user not found", preferredStyle: .alert)
                            let alertActionOkay = UIAlertAction(title: "Ok", style: .default) {
                                                (_) in
                                            }
                            alertVC.addAction(alertActionOkay)
                            self.present(alertVC, animated: true, completion: nil)
                            return
                        
                        
                    case .errorCodeWrongPassword:
                        print("wrong password")
                        self.viewLoading.isHidden = true
                        let alertVC = UIAlertController(title: "Error", message: "wrong password", preferredStyle: .alert)
                        let alertActionOkay = UIAlertAction(title: "Ok", style: .default) {
                            (_) in
                        }
                        alertVC.addAction(alertActionOkay)
                        self.present(alertVC, animated: true, completion: nil)
                        return
                    default:
                        break
                        
                    }
                }

           
           })
        }
    }
    
    // hidden viewLoading
    func hiddenViewLoading(){
        self.viewLoading.isHidden = false
    }
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
        
        
        self.view.backgroundColor = UIColor(r: 61, g: 91, b: 155)
        
        self.view.addSubview(inputContrainView)
        self.view.addSubview(btnLogin)
        self.view.addSubview(profileImage)
        self.view.addSubview(segmented)
        self.tfName.delegate  = self
        self.tfEmail.delegate = self
        self.tfPassWord.delegate = self
        setViewInput()
        setViewbtnLogin()
        setViewprofileImage()
        setViewSegmented()
        
//loading
        self.view.addSubview(viewLoading)
        viewLoading.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        viewLoading.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        viewLoading.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        viewLoading.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        viewLoading.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: viewLoading.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: viewLoading.centerYAnchor).isActive = true
        
        
        activity.startAnimating()
        viewLoading.isHidden = true
        
        //
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
            }
    // hidden keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func setViewSegmented(){
        segmented.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmented.widthAnchor.constraint(equalTo: inputContrainView.widthAnchor, multiplier: 3/4).isActive = true
        segmented.heightAnchor.constraint(equalTo: self.inputContrainView.heightAnchor, multiplier: 1/4).isActive = true
        segmented.bottomAnchor.constraint(equalTo: inputContrainView.topAnchor, constant: -10).isActive = true
    }
    
    func setViewprofileImage(){
        profileImage.centerXAnchor.constraint(equalTo: inputContrainView.centerXAnchor).isActive = true
      //  profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.widthAnchor.constraint(equalTo: inputContrainView.widthAnchor, multiplier: 1/3).isActive = true
        profileImage.heightAnchor.constraint(equalTo: inputContrainView.widthAnchor, multiplier: 1/3).isActive = true
        
       // profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: segmented.topAnchor, constant: -20).isActive = true
    }
    
    
    // check height input
    var inputsViewHeightArchor : NSLayoutConstraint?
    
    // check height name
    var tfNameHeight  : NSLayoutConstraint?
    
    var tfemailHeight : NSLayoutConstraint?
    
    var tfpasswordHeight :NSLayoutConstraint?
    func setViewInput(){
        inputContrainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContrainView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContrainView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        inputsViewHeightArchor = inputContrainView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/5)
        inputsViewHeightArchor?.isActive = true
        
        // name
        inputContrainView.addSubview(tfName)
        tfName.leftAnchor.constraint(equalTo: inputContrainView.leftAnchor, constant: 5).isActive = true
        tfName.rightAnchor.constraint(equalTo: inputContrainView.rightAnchor, constant: 5).isActive = true
        tfName.topAnchor.constraint(equalTo: inputContrainView.topAnchor, constant: 0).isActive = true
        tfNameHeight = tfName.heightAnchor.constraint(equalTo: inputContrainView.heightAnchor, multiplier: 1/3 )
        tfNameHeight?.isActive = true
        
        //
        inputContrainView.addSubview(nameV)
        nameV.widthAnchor.constraint(equalTo: inputContrainView.widthAnchor).isActive = true
        nameV.centerXAnchor.constraint(equalTo: inputContrainView.centerXAnchor).isActive = true
        nameV.topAnchor.constraint(equalTo: tfName.bottomAnchor, constant: 0).isActive = true
        nameV.heightAnchor.constraint(equalToConstant: 1).isActive = true
        //email
        
        inputContrainView.addSubview(tfEmail)
        tfEmail.leftAnchor.constraint(equalTo: inputContrainView.leftAnchor, constant: 5).isActive = true
        tfEmail.rightAnchor.constraint(equalTo: inputContrainView.rightAnchor, constant: 5).isActive = true
        tfEmail.topAnchor.constraint(equalTo: nameV.bottomAnchor, constant: 0).isActive = true
        tfemailHeight = tfEmail.heightAnchor.constraint(equalTo: inputContrainView.heightAnchor, multiplier: 1/3)
        tfemailHeight?.isActive = true
        
        //
        inputContrainView.addSubview(nameE)
        nameE.widthAnchor.constraint(equalTo: inputContrainView.widthAnchor).isActive = true
        nameE.centerXAnchor.constraint(equalTo: inputContrainView.centerXAnchor).isActive = true
        nameE.topAnchor.constraint(equalTo: tfEmail.bottomAnchor, constant: 0).isActive = true
        nameE.heightAnchor.constraint(equalToConstant: 1).isActive = true
       
        
        // password
        
        inputContrainView.addSubview(tfPassWord)
        tfPassWord.leftAnchor.constraint(equalTo: inputContrainView.leftAnchor, constant: 5).isActive = true
        tfPassWord.rightAnchor.constraint(equalTo: inputContrainView.rightAnchor, constant: 5).isActive = true
        tfPassWord.topAnchor.constraint(equalTo: nameE.bottomAnchor, constant: 0).isActive = true
        tfpasswordHeight = tfPassWord.heightAnchor.constraint(equalTo: inputContrainView.heightAnchor, multiplier: 1/3)
        tfpasswordHeight?.isActive = true
    }
    func setViewbtnLogin(){
        btnLogin.topAnchor.constraint(equalTo: inputContrainView.bottomAnchor, constant: 20).isActive = true
        btnLogin.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnLogin.widthAnchor.constraint(equalTo: inputContrainView.widthAnchor).isActive = true
        btnLogin.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    // hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
extension UIColor{
    convenience init(r:CGFloat , g: CGFloat, b:CGFloat) {
        self.init(red: r/255 ,  green: g/255 , blue: b/255 , alpha: 1)
    }
}
