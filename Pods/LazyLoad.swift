//
//  LazyLoad.swift
//  Pods
//
//  Created by DREAMWORLD on 08/03/24.
//

import Foundation
import UIKit

class LazyLoadImage: UIImageView {
    
    private var imageCash = NSCache<AnyObject, UIImage>()
    
    func loadImage(imageURL: URL) {
        
        if let cashImage = self.imageCash.object(forKey: imageURL as AnyObject) {
            print("from cash")
            self.image = cashImage
            return
        }
        
        self.image = UIImage(systemName: "person")
        
        DispatchQueue.global().async {
            [weak self] in
            
            if let imageData = try? Data(contentsOf: imageURL) {
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        print("from server")
                        
                        self?.image = image
                        self?.imageCash.setObject(image, forKey: imageURL as AnyObject)
                    }
                }
            }
        }
    }
}
