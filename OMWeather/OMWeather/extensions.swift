//
//  extensions.swift
//  OMWeather
//
//  Created by Alex on 22.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import Foundation

extension Date {
    
    func toFormat_EEE () -> String {
        let weekDaydateFormatter = DateFormatter()
        weekDaydateFormatter.dateFormat = "EEE"
        weekDaydateFormatter.locale = Locale(identifier: "en_US")
        return weekDaydateFormatter.string(from: self).uppercased()
    }
    
    func toFormat_ddMM () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        return dateFormatter.string(from: self).uppercased()
    }
    
    func toFormat_HHmm () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self).uppercased()
    }
}

extension UIView  {
    func scaleFonts() {
        let scaleY = UIScreen.main.bounds.width / 320
        
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if subSubView is UILabel  {
                    (subSubView as! UILabel).font = (subSubView as! UILabel).font.withSize((subSubView as! UILabel).font.pointSize * scaleY)
                }
                if subSubView is UIButton  {
                    (subSubView as! UIButton).titleLabel?.font = (subSubView as! UIButton).titleLabel?.font.withSize(((subSubView as! UIButton).titleLabel?.font.pointSize)! * scaleY)
                }
            }
        }
    }
}


extension String {
    
    var isValidForGeocodeSearch: Bool  {
        let mask = "[A-Za-z0-9, ]{2,32}"
        let siteNameTest = NSPredicate(format:"SELF MATCHES %@", mask)
        return  siteNameTest.evaluate(with: self)
    }

}
