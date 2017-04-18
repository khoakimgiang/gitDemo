//
//  LoadImge.swift
//  Message_VQ
//
//  Created by Van Quang on 3/7/17.
//  Copyright © 2017 Van Quang. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    func loadImage(url : String){
       
        
        if let cacheImage = imageCache.object(forKey: url as AnyObject){
            self.image = cacheImage as? UIImage
            return
        }
        
            URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    print(error)
                    return
                }
                
               // DispatchQueue.global(qos: .background).async { [weak self]
                   // () -> Void in
                    
                                
                       DispatchQueue.main.async {
            
                                    if let image = UIImage(data: data!){
                                        
                                        imageCache.setObject(image, forKey: url as AnyObject)
                                        self.image = image
                                    }
                                }
        
                    
                    
              //  }
                
            }).resume()
            
            
    }
    
}
