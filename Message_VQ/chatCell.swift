
//
//  chatCell.swift
//  Message_VQ
//
//  Created by Van Quang on 3/12/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit
import AVFoundation
class chatCell: UICollectionViewCell {
    
    var ChatView : ChatViewController?
    var message : Message?
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setupViews()
    }
    
    lazy var btnPlay : UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.setImage(UIImage.init(named: "play.png"), for: .normal)
        btn.tintColor = UIColor.white
        btn.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
       // btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playVideo)))
        return btn
    }()
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    func playVideo(){
        print("lay")
        if let videoUrl = self.message?.videoUrl {
            let url = NSURL(string: videoUrl)
          self.player  = AVPlayer(url: url as! URL)
          self.playerLayer  = AVPlayerLayer(player: player)
            playerLayer?.frame = self.viewText.bounds
            self.viewText.layer.addSublayer(playerLayer!)
            player?.play()
            active.startAnimating()
            btnPlay.isHidden = true
        }
    }
    // cell die 
    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        //playerLayer?.removeFromSuperlayer()
        active.isHidden = true
    }
    
    let active : UIActivityIndicatorView = {
       let ac = UIActivityIndicatorView(activityIndicatorStyle: .white)
        ac.hidesWhenStopped  = true
        ac.translatesAutoresizingMaskIntoConstraints = false

    return ac
    }()
    let text : UILabel = {
        let t  = UILabel()
        t.text = ""
        t.font = .systemFont(ofSize: 16)
        t.numberOfLines = 0
        t.sizeToFit()
        t.translatesAutoresizingMaskIntoConstraints = false
        
        return t
    }()
    
    let viewText : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.blue
        
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()
    let profileImg : UIImageView = {
        let img = UIImageView()
        img.image = UIImage.init(named: "Telegram_Messenger.png")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 15
        img.layer.masksToBounds = true
        return img
    }()
    
    let profileImgWitdSended : UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        return img
    }()
    var viewTextWidthAnchor : NSLayoutConstraint?
    var viewTextleftAnchor : NSLayoutConstraint?
    var viewTextRightAnchor : NSLayoutConstraint?
    
    func setupViews (){
        addSubview(viewText)
        viewTextRightAnchor =  viewText.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        viewTextleftAnchor = viewText.leftAnchor.constraint(equalTo: profileImg.rightAnchor, constant: 8)
        viewTextWidthAnchor = viewText.widthAnchor.constraint(equalToConstant: 100)
        viewTextWidthAnchor?.isActive = true
        viewText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        viewText.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        viewText.addSubview(profileImgWitdSended)
        profileImgWitdSended.centerYAnchor.constraint(equalTo: viewText.centerYAnchor).isActive = true
        profileImgWitdSended.centerXAnchor.constraint(equalTo: viewText.centerXAnchor).isActive = true
        profileImgWitdSended.heightAnchor.constraint(equalTo: viewText.heightAnchor).isActive = true
        profileImgWitdSended.widthAnchor.constraint(equalTo: viewText.widthAnchor).isActive = true
        profileImgWitdSended.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImage)))
        
        addSubview(profileImg)
        profileImg.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImg.heightAnchor.constraint(equalToConstant: 30).isActive = true
        profileImg.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImg.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        
        viewText.addSubview(text)
        text.leftAnchor.constraint(equalTo: viewText.leftAnchor, constant : 8).isActive = true
        text.topAnchor.constraint(equalTo: viewText.topAnchor).isActive
            = true
        text.rightAnchor.constraint(equalTo: viewText.rightAnchor, constant : -8).isActive = true
        text.heightAnchor.constraint(equalTo: viewText.heightAnchor).isActive = true
        
        viewText.addSubview(btnPlay)
        btnPlay.centerYAnchor.constraint(equalTo: viewText.centerYAnchor).isActive = true
        btnPlay.centerXAnchor.constraint(equalTo: viewText.centerXAnchor).isActive = true
        btnPlay.widthAnchor.constraint(equalToConstant: 20).isActive = true
        btnPlay.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        viewText.addSubview(active)
        active.centerYAnchor.constraint(equalTo: viewText.centerYAnchor).isActive = true
        active.centerXAnchor.constraint(equalTo: viewText.centerXAnchor).isActive = true
        active.widthAnchor.constraint(equalToConstant: 20).isActive = true
        active.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        }
    func zoomImage(ui : UIGestureRecognizer){
        if message?.videoUrl != nil {
            return
        }
        if let imgv : UIImageView =  profileImgWitdSended  {
            self.ChatView?.zoomImageFromCell(imgView: imgv)
        }
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemensted")
    }
    
}
