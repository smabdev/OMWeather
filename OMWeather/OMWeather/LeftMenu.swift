
//
//  LeftMenu.swift
//  OMWeather
//
//  Created by Alex on 09.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import Foundation


class LeftMenu {
    static let USER_DEFAULT_KEY = "LeftMenuItems"
    
    final class Item: NSObject, NSCoding  {
        var locationName = ""
        var lat = 0.0
        var lon = 0.0
        
        init (locationName: String, lat: Double, lon: Double) {
            self.locationName = locationName
            self.lat = lat
            self.lon = lon
        }
        
        static func saveToDefaults(items: [Item]) {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: items)
            UserDefaults.standard.set(encodedData, forKey: USER_DEFAULT_KEY)
            UserDefaults.standard.synchronize()
        }
        
        static func loadFromDefaults() -> [Item]?  {
            if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_KEY),
                let itemsList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Item] {
                return itemsList
            } else {
                print("data not found for key: " + USER_DEFAULT_KEY)
                return nil
            }
        }
        
        
        required init(coder decoder: NSCoder) {
            self.locationName = decoder.decodeObject(forKey: "name") as? String ?? ""
            self.lat = decoder.decodeDouble(forKey: "lat")
            self.lon  = decoder.decodeDouble(forKey: "lon")
        }
        
        func encode(with coder: NSCoder) {
            coder.encode(locationName, forKey: "name")
            coder.encode(lat, forKey: "lat")
            coder.encode(lon, forKey: "lon")
        }
    }               // end of class Item
    
    
    
    // максимальное число элементов таблицы
    let itemsCapacity = 10
    var table = UITableView()
    var mask = UIButton()
    var view = UIView()
    
    var isOpen = Bool()
    var item = Item(locationName: "", lat: 0, lon: 0)
    var items = [Item]()
    
    
    func clearDefaults() {
        UserDefaults.standard.removeObject(forKey: LeftMenu.USER_DEFAULT_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func saveToDefaults() {
        Item.saveToDefaults(items: self.items)
    }
    
    func loadFromDefaults()  {
        if Item.loadFromDefaults() != nil  {
            self.items = Item.loadFromDefaults()!
        } else {
            items.removeAll()
        }
    }
    
    init () { }
    
    init(view: UIView) {
        
        self.isOpen = false
        self.view = view
        
        // маска между tableView с названием мест и основным view
        mask = {
            mask.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height - 20)
            
            UIApplication.shared.keyWindow?.addSubview(mask)
            return mask
        }()
        mask.isEnabled = false
        
        table = UITableView(frame: CGRect(x: -view.frame.width * 0.75, y: 20, width: view.frame.width * 0.75, height: view.frame.height - 20))
        table.backgroundColor = UIColor(red: 74/255, green: 192/255, blue: 252/255, alpha: 1)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        cell.backgroundColor = table.backgroundColor
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeOn(_:) ) )
        swipe.direction = .left
        
        UIApplication.shared.keyWindow?.addSubview(table)
        table.addSubview(UITableViewCell(style: .subtitle, reuseIdentifier: "myCell"))
        table.addGestureRecognizer(swipe)

    } // end of init
    
    
    
    
    func getCell (index: Int) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "myCell")
        cell.selectionStyle = .none
        cell.backgroundColor = table.backgroundColor
        cell.textLabel!.text = items[index].locationName
        cell.detailTextLabel?.text = "lat: " + items[index].lat.description + ", lon: " + items[index].lon.description
        return cell
    }
}   // end of class LeftMenu





extension LeftMenu {
    
    func addItem(locationName: String, lat: Double, lon: Double) {
        
        let newItem = LeftMenu.Item(locationName: locationName, lat: lat, lon: lon)
        
        // если такое место уже есть
        for index in 0..<items.count {
            if newItem.locationName == items[index].locationName {
                items.remove(at: index)
                break
            }
        }
        
        
        items.insert(newItem, at: 0)
        if items.count == itemsCapacity + 1 {
            items.remove(at: itemsCapacity)
        }
        saveToDefaults()
    }
    
    
    func open() {
        mask.isEnabled = true
        isOpen = true
        UIView.animate(withDuration: 0.3) {
            self.mask.layer.opacity = 0.5
            self.mask.backgroundColor = UIColor.gray
            self.table.frame.origin.x = 0
            self.view.layoutIfNeeded()
        }

        
    }
    
    func close() {
        mask.isEnabled = false
        isOpen = false
        UIView.animate(withDuration: 0.3) {
            self.mask.layer.opacity = 0
            self.mask.backgroundColor = UIColor.white
            self.table.frame.origin.x = -self.table.frame.width
            self.view.layoutIfNeeded()
        }
    }
    
    func toggle() {
        if self.isOpen {
            self.close()
        } else {
            self.open()
        }
    }
    
    @IBAction func swipeOn(_ sender: Any) {
        self.close()
    }
    
} // end of extension LeftMenu

