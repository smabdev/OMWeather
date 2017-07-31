//
//  ViewController.swift
//  OMWeather
//
//  Created by Alex on 14.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftHTTP
import SwiftyJSON
import Solar


class WeatherForCurrentPlace: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var siteNameLabel: UILabel!
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
    
    let locationManager = CLLocationManager()
    var reloadDataTimer = Timer()
    var geocoder = Geocoder()
    var weather = Weather()
    var sunConstraint = NSLayoutConstraint()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.scaleFonts()
        
        if weather.loadFromDefaults() == true {
            repaintVC1()
        }
        
        for constraint in view.constraints {
            if constraint.identifier == "sunConstraint" {
                sunConstraint = constraint
            }
        }

        view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "sky-2"))
        weatherImage.layer.cornerRadius = weatherImage.frame.height/2
        tabBarController?.tabBar.backgroundImage = UIImage()
        UITabBar.appearance().clipsToBounds = true    
     //   tabBarController?.tabBar.setValue(true, forKey: "_hidesShadow")
    //    UITabBar.appearance().layer.borderWidth = 0.0
        
        for item in (tabBarController?.tabBar.items)! {
            item.isEnabled = false
        }
        
        reloadDataTimer = Timer.scheduledTimer(timeInterval: 60*60*3, target: self, selector: #selector(self.refreshAll), userInfo: nil, repeats: true)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    

    

    
    // серые пятна под кнопками tabBar
    override func viewDidAppear(_ animated: Bool) {
        if (tabBarController?.tabBar.items?[1].isEnabled)! == true {
            return
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
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // получение координат 
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if store.locationTask {
            return
        }
        store.locationTask = true
        locationManager.stopUpdatingLocation()
        geocoder.userLocation = locations[0].coordinate
        
        store.geocodeTask = false
        store.weatherTask = false
        store.timeZoneTask = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.geocoder.getSiteName(siteLocation: self.geocoder.userLocation)
            self.weather.getWeather(siteLocation: self.geocoder.userLocation)
            self.geocoder.getTimeZone(siteLocation: self.geocoder.userLocation)
            store.dispatchGroup.wait()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if store.geocodeTask && store.weatherTask && store.timeZoneTask {
                self.afterUpload()
            }
        }
        
    }


        // после чтения из сети
    func afterUpload() {

        store.localityName = geocoder.localityName!    // имя места для VC3 при первой загрузке
        store.for5Days = weather.for5Days              // погода для VC2
        store.sunPrognosis = geocoder.getSunPrognosis (location: geocoder.userLocation, timeZoneId: geocoder.timeZoneId!, timeZoneOffset: geocoder.timeZoneOffset!)
        repaintVC1()
        // включение кнопок tabBar при первой загрузке
        if store.isFirstDataLoad == false {
            store.isFirstDataLoad = true
            
            DispatchQueue.main.async {
                self.tabBarController?.tabBar.items![0].isEnabled = true
                self.tabBarController?.tabBar.items![1].isEnabled = true
                self.tabBarController?.tabBar.items![2].isEnabled = true
            }
        }
        
    }
    
    
    
    
    // кнопка "обновить"
    @IBAction func refreshAll(_ sender: Any) {
        if UIApplication.shared.isNetworkActivityIndicatorVisible == true {
            return
        }
        // проверка очередей или задач
        store.locationTask = false
        locationManager.startUpdatingLocation()
    }
    
    
   func repaintVC1() {
    
    DispatchQueue.main.async {
        self.siteNameLabel.text = store.localityName
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
    
        if store.sunPrognosis.isDayTime  {
            self.startImage.image = #imageLiteral(resourceName: "sun-1")
            self.endImage.image = #imageLiteral(resourceName: "moon-1")
            self.skyItem.image = #imageLiteral(resourceName: "sun-2")
            self.lineImage.image = #imageLiteral(resourceName: "line-day")
            self.sunRiseLabel.text = store.sunPrognosis.sunriseTime
            self.sunDownLabel.text = store.sunPrognosis.sunsetTime
        } else {
            self.startImage.image = #imageLiteral(resourceName: "moon-1")
            self.endImage.image = #imageLiteral(resourceName: "sun-1")
            self.skyItem.image = #imageLiteral(resourceName: "moon-2")
            self.lineImage.image = #imageLiteral(resourceName: "line-night")
            self.sunRiseLabel.text = store.sunPrognosis.sunsetTime
            self.sunDownLabel.text = store.sunPrognosis.sunriseTime
        }

        self.sunConstraint.constant = self.lineImage.frame.width * CGFloat(store.sunPrognosis.percent)
     
    }
    weather.saveToDefaults()
    }
    



}

