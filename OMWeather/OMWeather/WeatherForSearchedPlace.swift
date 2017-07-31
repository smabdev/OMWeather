//
//  ViewController3.swift
//  OMWeather
//
//  Created by Alex on 14.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwiftyJSON
import CoreLocation

class WeatherForSearchedPlace: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var sunDownLabel: UILabel!
    @IBOutlet weak var lineImage: UIImageView!
    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var endImage: UIImageView!
    @IBOutlet weak var skyItem: UIImageView!
    
    var geocoder = Geocoder()
    var weather = Weather()

    var reloadDataTimer = Timer()
    var sunConstraint = NSLayoutConstraint()
    
    var leftMenu = LeftMenu()
    var isLeftMenuClick = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "sky-2"))
        view.scaleFonts()
        
        leftMenu = LeftMenu(view: self.view)
        leftMenu.mask.addTarget(self, action: #selector(leftMaskViewClick), for: .touchUpInside)
        leftMenu.table.delegate = self
        leftMenu.table.dataSource = self
        leftMenu.loadFromDefaults()
        
        
        for constraint in view.constraints {
            if constraint.identifier == "sunConstraint" {
                sunConstraint = constraint
            }
        }
  
        for  subview in (tabBarController?.view.subviews[1].subviews)! {
            if subview is UIControl == false {
                continue
            }
            let frame = CGRect(origin: CGPoint(x: subview.center.x - 49/2, y: self.view.frame.height-49), size: CGSize(width: 49, height: 49))
            let view = UIView(frame: frame)
            view.backgroundColor = UIColor.white
            view.layer.opacity = 0.3
            view.layer.cornerRadius = 49/3
            self.view.addSubview(view)
        }
    
        reloadDataTimer = Timer.scheduledTimer(timeInterval: 60*60*3, target: self, selector: #selector(self.searchClick), userInfo: nil, repeats: true)

        textField.layer.borderColor = UIColor.blue.cgColor
        textField.backgroundColor = UIColor.clear
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 25)
        textField.placeholder = "Write you site here"
        
        // автоматическая загрузка погоды при первом входе на VC3
        
        if leftMenu.items.count > 0 {
            textField.text = leftMenu.items[0].locationName
            geocoder.searchedName = leftMenu.items[0].locationName
            isLeftMenuClick = true
        } else {
            textField.text = store.localityName
            geocoder.searchedName = store.localityName
            isLeftMenuClick = false
        }
        searchClick(Any.self)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func editingDidBegin(_ sender: Any) {
        textField.text = ""
    }
    
    @IBAction func searchClickOnKeyboard(_ sender: Any) {
        isLeftMenuClick = false
        searchClick(Any.self)
    }
    
    
    // кнопка поиска справа от поля textField
    @IBAction func searchClick(_ sender: Any) {

        if isLeftMenuClick == false && (textField.text!.isValidForGeocodeSearch == false || UIApplication.shared.isNetworkActivityIndicatorVisible == true) {
            textField.text = geocoder.lastSearchResult
            return
        }
        view.endEditing(true)
        
        store.geocodeTask = false
        store.weatherTask = false
        store.timeZoneTask = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.geocoder.searchSite(testedLocality: self.textField.text!)
            store.dispatchGroup.wait()
            
            if store.geocodeTask == false || self.geocoder.searchedName == nil {
                DispatchQueue.main.async {
                    self.textField.text = self.geocoder.lastSearchResult
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else {
                self.notifiFromSearchSite()
            } 
        }
    }
    
    
    func notifiFromSearchSite() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.weather.getWeather(siteLocation: self.geocoder.searchedLocation)
            self.geocoder.getTimeZone(siteLocation: self.geocoder.searchedLocation)
            store.dispatchGroup.wait()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if store.geocodeTask && store.weatherTask && store.timeZoneTask {
                
                self.leftMenu.addItem(locationName: self.geocoder.searchedName!, lat: self.geocoder.searchedLocation.latitude, lon: self.geocoder.searchedLocation.longitude)
                
                self.repaintVC3()
            }
        }
    }
    
    @IBAction func leftMenuClick(_ sender: Any) {
        view.endEditing(true)
        textField.text = geocoder.lastSearchResult
        leftMenu.table.reloadData()
        leftMenu.open()
    }
    
    func leftMaskViewClick() {
        leftMenu.close()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  leftMenu.items.count
    }
    
    // отрисовка таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leftMenu.getCell(index: (indexPath as NSIndexPath).row)
        cell.textLabel?.font = weatherDescriptionLabel.font
        return cell
    }
    
    //  нажатие на tableView cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        leftMenu.close()
        
        textField.text = leftMenu.items[indexPath.row].locationName
        geocoder.lastSearchResult = leftMenu.items[indexPath.row].locationName
        isLeftMenuClick = true
        searchClick(Any.self)    
    }
    
    
    func repaintVC3() {

        let sunPrognosis = geocoder.getSunPrognosis (location: geocoder.searchedLocation, timeZoneId: geocoder.timeZoneId!, timeZoneOffset: geocoder.timeZoneOffset!)
        
        DispatchQueue.main.async {
            self.geocoder.lastSearchResult = self.geocoder.searchedName!
            self.textField.text = self.geocoder.searchedName!

            self.tempLabel.text = self.weather.forDay.tempNow.description + "°"
            self.weatherImage.image = weatherIcons[self.weather.forDay.icon]
            self.weatherDescriptionLabel.text = self.weather.forDay.description
            
            self.minTempLabel.text = self.weather.forDay.minTemp.description + "°"
            self.maxTempLabel.text = self.weather.forDay.maxTemp.description + "°"
            
            var windSpeed = self.weather.forDay.windSpeed.description
            windSpeed.characters.removeLast()
            self.windLabel.text = windSpeed + " m/s"
            self.pressureLabel.text = self.weather.forDay.pressure.description + " mm"
            self.humidityLabel.text = self.weather.forDay.humidity.description + " %"
            
            if sunPrognosis.isDayTime  {
                self.startImage.image = #imageLiteral(resourceName: "sun-1")
                self.endImage.image = #imageLiteral(resourceName: "moon-1")
                self.skyItem.image = #imageLiteral(resourceName: "sun-2")
                self.lineImage.image = #imageLiteral(resourceName: "line-day")
                self.sunRiseLabel.text = sunPrognosis.sunriseTime
                self.sunDownLabel.text = sunPrognosis.sunsetTime
            } else {
                self.startImage.image = #imageLiteral(resourceName: "moon-1")
                self.endImage.image = #imageLiteral(resourceName: "sun-1")
                self.skyItem.image = #imageLiteral(resourceName: "moon-2")
                self.lineImage.image = #imageLiteral(resourceName: "line-night")
                self.sunRiseLabel.text = sunPrognosis.sunsetTime
                self.sunDownLabel.text = sunPrognosis.sunriseTime
            }
           
            self.sunConstraint.constant = self.lineImage.frame.width * CGFloat(sunPrognosis.percent)
        }
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touches.first) != nil {
            view.endEditing(true)
            textField.text = geocoder.lastSearchResult
        }
        super.touchesBegan(touches, with: event)
    }


}
