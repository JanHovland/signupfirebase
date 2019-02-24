//
//  UIImage+Scale.swift
//  signupfirebase
//
//  Created by Jan Hovland on 23/02/2019.
//  Copyright © 2019 Jan . All rights reserved.
//

import UIKit

extension UIImage {
    
    func scale(newWidth: CGFloat) -> UIImage {
        
        print("The original width: \(self.size.width)")
        
        // Make sure the given width is different from the existing one
        if self.size.width == newWidth {
            return self
        }
        
        // Calculate the scaling factor
        let scaleFactor = newWidth / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
        
    }
    
    
}
