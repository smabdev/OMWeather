//
//  Geocoder_class.swift
//  OMWeather
//
//  Created by Alex on 15.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftHTTP
import SwiftyJSON
import Solar

class Geocoder {
    
    // имя, получаемое по координатам для VC1
    var localityName: String?
    // нахождение устройства, определяется по CoreLocation для VC1
    var userLocation = CLLocationCoordinate2D()

    // координаты при поиске места по названию в VC3
    var searchedLocation = CLLocationCoordinate2D()
    
    // имя, получаемое после поиска по имени
    var searchedName: String?
    // результат последнего поиска для VC3
    var lastSearchResult = ""
    
    var timeZoneId: TimeZone?
    var timeZoneOffset: TimeInterval?
    var sunrise = ""
    var sunset = ""
    
    // время восхода и заката для временного пояса и координат устройства
    struct SunPrognosis {
        var sunriseTime = ""
        var sunsetTime = ""
        var percent = 0.0
        var isDayTime = false
    }
    
    var sunPrognosis = SunPrognosis()
    
    
    
    // название местности по координатам (VC1)
    func getSiteName(siteLocation: CLLocationCoordinate2D) {
        
        store.dispatchGroup.enter()
        var httpHeader = "https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&key=%@&language=en"
        httpHeader = String(format: httpHeader, siteLocation.latitude.description, siteLocation.longitude.description, GOOGLE_APIS_KEY)
        
        do {
            let opt = try HTTP.GET(httpHeader)
            
            opt.start { response in
                if let err = response.error {
                    print("error in GoogleGeocode request: \(err.localizedDescription)")
                    store.dispatchGroup.leave()
                    return
                }

                let data = response.data
                let jsonArray =  JSON(data: data)
//                 print (jsonArray.description )
      
                let count = jsonArray["results", 0, "address_components"].count
                for i in 0 ..< count {
                    let types = jsonArray["results", 0, "address_components", i, "types"].array
                    if ((types?.contains("country"))! && (types?.contains("political"))!) || ((types?.contains("locality"))! && (types?.contains("political"))!) {
                        self.localityName = jsonArray["results", 0, "address_components", i, "long_name"].description
                    //   self.localityName = jsonArray["results"][1]["formatted_address"].description
                        store.geocodeTask = true
                        break
                    }
                }
                store.dispatchGroup.leave()
            }
        } catch let error {
            print("error in GoogleGeocode task:  \(error)")
            store.dispatchGroup.leave()
        }
        
    }
    
    
    
    
        // название местности по строке поиска (VC3)
    func searchSite (testedLocality: String) {
    
        store.dispatchGroup.enter()
        var httpHeader = "https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=%@&region=GB&language=en-GB"
        httpHeader = String(format: httpHeader, testedLocality.replacingOccurrences(of: " ", with: "+"), GOOGLE_APIS_KEY)
    
        do {
            let opt = try HTTP.GET(httpHeader)
    
            opt.start { response in
                if let err = response.error {
                    print("error in GoogleGeocode request: \(err.localizedDescription)")
                    store.dispatchGroup.leave()
                    return
                }

                let data = response.data
                let jsonArray =  JSON(data: data)
//                print (jsonArray.description )
                
                store.geocodeTask = true
                self.searchedName = self.getSiteDescription(jsonArray: jsonArray)
                store.dispatchGroup.leave()
            }
            
            } catch let error {
                print("error in GoogleGeocode task:  \(error) ")
                store.dispatchGroup.leave()
        }
    }
 
    
    // парсинг названия местности, координат
    private func getSiteDescription(jsonArray: JSON) -> String? {
        
        let count = jsonArray["results", 0, "address_components"].count
        var localityName = ""
        var countryCode = ""
        
        // ответ не получен
        if jsonArray["status"].description != "OK" {
            return nil
        }
//        print (jsonArray.description)
        // имя местности
      //  localityName = jsonArray["results", 0, "address_components", count-1, "long_name"].description
        var i = count-2
        while i >= 0 {
            let types = jsonArray["results", 0, "address_components", i, "types"].array
            if (types?.contains("locality"))! || (types?.contains("establishment"))! ||  (types?.contains("administrative_area_level_1"))! {
                localityName = jsonArray["results", 0, "address_components", i, "long_name"].description
         //       break
            }
            i -= 1
        }
        
        // код страны
        for i in 0 ..< count {
            let types = jsonArray["results", 0, "address_components", i, "types"].array
            if (types?.contains("country"))!  {
                countryCode = jsonArray["results", 0, "address_components", i, "short_name"].description
                break
            }
        }
        
        if localityName == "" || countryCode == "" {
            return nil
        }
        
        searchedLocation.latitude = jsonArray["results", 0, "geometry", "location", "lat"].double!
        searchedLocation.longitude = jsonArray["results", 0, "geometry", "location", "lng"].double!
        return localityName + ", " + countryCode
    }
    
    
    
    
    // временная зона по координатам
    func getTimeZone (siteLocation: CLLocationCoordinate2D) {
        
        store.dispatchGroup.enter()
        var httpHeader = "https://maps.googleapis.com/maps/api/timezone/json?location=%@,%@&timestamp=%@&key=%@&language=en"

        httpHeader = String(format: httpHeader, siteLocation.latitude.description, siteLocation.longitude.description, Date().timeIntervalSince1970.description, GOOGLE_APIS_KEY)
        
        do {
            let opt = try HTTP.GET(httpHeader)
            
            opt.start { response in
                if let err = response.error {
                    print("error in GoogleTimeZone request: \(err.localizedDescription)")
                    store.dispatchGroup.leave()
                    return
                }
                
                let data = response.data
                let jsonArray =  JSON(data: data)
//                print (jsonArray.description )
                
                if jsonArray["status"].description == "OK" {
                    store.timeZoneTask = true
                    self.timeZoneId = TimeZone(identifier: jsonArray["timeZoneId"].description)
                    self.timeZoneOffset = jsonArray["dstOffset"].double! + jsonArray["rawOffset"].double!
                }
                  store.dispatchGroup.leave()
                
            }   
        } catch let error {
            print("error in GoogleTimeZone task:  \(error)")
            store.dispatchGroup.leave()
        }
    }
    

    // время восхода и заката для временного пояса и координат
    func getSunPrognosis (location: CLLocationCoordinate2D, timeZoneId: TimeZone, timeZoneOffset: TimeInterval) -> SunPrognosis {
        
        struct Day {
            var sunItem = Date()
            var description = ""
        }

        let currentTimeZona = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT())
        var days = Array(repeating: Day(), count: 6)
        
        // не отдает значений sunrise и sunset при latitude > 65.74 (полярные день и ночь)
        let solar = Solar(forDate: Date(), withTimeZone: timeZoneId, latitude: location.latitude, longitude: location.longitude)
        if solar?.sunrise == nil || solar?.sunset == nil{
            sunPrognosis.sunriseTime = "∞"
            sunPrognosis.sunsetTime  = "∞"
            sunPrognosis.percent = 0.5
            sunPrognosis.isDayTime = true
            return sunPrognosis
        }
        
        
        var i = 0
        repeat {
            days[i].sunItem = (Solar(forDate: Date() + TimeInterval ((i/2-1) * 60*60*24), withTimeZone: timeZoneId, latitude: location.latitude, longitude: location.longitude)?.sunrise)!
            days[i].description = "sunrise"
            
            days[i+1].sunItem = (Solar(forDate: Date() + TimeInterval ((i/2-1) * 60*60*24), withTimeZone: timeZoneId, latitude: location.latitude, longitude: location.longitude)?.sunset)!
            days[i+1].description = "sunset"
            
            i += 2
        } while i != days.count
        
        days = days.sorted {
            (day1, day2) -> Bool in
            return day1.sunItem < day2.sunItem
        }
        
        i = 0
        repeat {
            if (solar?.date)! < days[i].sunItem  {
                break
            }
            i += 1
        } while i != days.count
        
        if days[i].description == "sunset" {
            sunPrognosis.isDayTime = true
        } else {
            sunPrognosis.isDayTime = false
        }
        sunPrognosis.percent = ( (solar?.date.timeIntervalSince1970)! - days[i-1].sunItem.timeIntervalSince1970 ) / ( days[i].sunItem.timeIntervalSince1970 - days[i-1].sunItem.timeIntervalSince1970 )
     
        // время sunriseTime, sunSetTime - местное для (solar.lat, solar.lon)
        sunPrognosis.sunriseTime = ((solar?.sunrise)! + timeZoneOffset - currentTimeZona).toFormat_HHmm()
        sunPrognosis.sunsetTime  = ((solar?.sunset)! + timeZoneOffset - currentTimeZona).toFormat_HHmm()
        
        return sunPrognosis
    }
    
    

}

