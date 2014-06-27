//
//  UIImage+ColorImage.swift
//  poem
//
//  Created by Sun Xi on 6/19/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

import Foundation
import QuartzCore

extension UIImage {
    
    class func colorImage(color:UIColor, rect:CGRect)->UIImage {
        
        var rt = rect
        if rect == CGRectZero {
            rt = CGRectMake(0, 0, 1, 1)
        }
        
        UIGraphicsBeginImageContext(rt.size)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rt);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
}
