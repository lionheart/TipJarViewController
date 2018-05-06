//
//  UIImage+TipJarViewController.swift
//  TipJarViewController
//
//  Created by Dan Loewenherz on 5/6/18.
//

import UIKit

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image)
    }
}
