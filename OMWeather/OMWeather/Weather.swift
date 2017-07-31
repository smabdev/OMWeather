//
//  Weather_class.swift
//  OMWeather
//
//  Created by Alex on 15.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import CoreLocation
import SwiftHTTP
import SwiftyJSON

class Weather {
    
    // что получается в 40а экземплярах от OWM ответа
    struct Weather {
        var date = ""
        var tempNow = 0
        var icon = ""
        var description = ""
        var mainDescription = ""
        var minTemp = 0
        var maxTemp = 0
        var windSpeed = 0.0
        var windAngle = 0.0
        var pressure = 0
        var humidity = 0
        
    }
    
    // пять экземпляров
    public struct FiveDaysWeather {
        var weekDay = ""
        var date = ""
        var iconDay = ""
        var iconNight = ""
        var dayDescription = ""
        var nightDescription = ""
        
        var maxTemp = 0
        var maxHumidity = 0
        var maxPressure = 0
        var maxWindSpeed = 0.0
        
        var minTemp = 0
        var minHumidity = 0
        var minPressure = 0
        var minWindSpeed = 0.0
        

        subscript(index: Int) -> CGFloat {
            get {
                switch index {
                case 0: return CGFloat(maxTemp)
                case 1: return CGFloat(maxHumidity)
                case 2: return CGFloat(maxPressure)
                case 3: return CGFloat(maxWindSpeed)
                case 4: return CGFloat(minTemp)
                case 5: return CGFloat(minHumidity)
                case 6: return CGFloat(minPressure)
                case 7: return CGFloat(minWindSpeed)
                default: return 0
                }
            }
        }
    }
    
    var forDay = Weather()
    var forWeek = [Weather]()
    var for5Days = [FiveDaysWeather]()
    
    
    // получение JSON с погодой от сервера HTTP (VC1 & VC3)
    func getWeather (siteLocation: CLLocationCoordinate2D)  {
        
        store.dispatchGroup.enter()
        var httpHeader = "http://api.openweathermap.org/data/2.5/forecast?lat=%@&lon=%@&units=metric&APPID=%@"
        httpHeader = String(format: httpHeader, siteLocation.latitude.description, siteLocation.longitude.description, OPEN_WEATHER_MAP_KEY)
        
        do {
            let opt = try HTTP.GET(httpHeader)
   
            opt.start { response in
                if let err = response.error {
                    print("error in weather request: \(err.localizedDescription)")
                    store.dispatchGroup.leave()
                   // "The request timed out."
                    return  //also notify app of failure as needed
                }
                self.parseJSON (data: response.data)
                self.getFiveDaysWeather()
                store.weatherTask = true
                store.dispatchGroup.leave()
            }
        } catch let error {
            print("got an error creating the weather request: \(error)")
            store.dispatchGroup.leave()
        }

    }
    
    
    //  парсит JSON с погодой, раскладывает в массив 
    private func parseJSON (data: Data) {
        
        var jsonArray =  JSON(data: data)
        var listItem = Weather()
        
        var i = 0
        let JSONitems = jsonArray["cnt"].int
        forWeek.removeAll()
        repeat {
            
            let list = jsonArray["list", i]
            
            listItem.date = list["dt_txt"].description
            
            listItem.tempNow = Int(round(list["main", "temp"].double!))
            listItem.minTemp = Int(floor(list["main", "temp_min"].double!))
            listItem.maxTemp = Int(ceil(list["main", "temp_max"].double!))
            
            listItem.pressure = Int((list["main", "grnd_level"].double! * 0.750062))
            listItem.humidity = list["main", "humidity"].int!
   
            listItem.windSpeed = list["wind", "speed"].double!
            listItem.windAngle = list["wind", "deg"].double!
            
            listItem.icon = list["weather", 0,  "icon"].description
            listItem.description = list["weather", 0,  "description"].description.uppercased()
            listItem.mainDescription = list["weather", 0,  "main"].description.uppercased()
            
            forWeek.append(listItem)
            i += 1
        
        } while i != JSONitems
        // удаление погоды за прошлые 3 часа
        forWeek.remove(at: 0)
    }
    
    
    
    //  делает массив с погодой на 5 дней для VC2
    private func getFiveDaysWeather () {
        
        var oneDay = FiveDaysWeather()
        for5Days.removeAll()

        var date = Date()
        
        for _ in 0...5 {
            oneDay.weekDay = date.toFormat_EEE()
            oneDay.date  = date.toFormat_ddMM()
            date = date.addingTimeInterval(TimeInterval(86400))
            for5Days.append(oneDay)
//            print (oneDay)
        }
        
        
        
        var i = 0
        var i2 = 0
        var temp = [Int]()
        var windSpeed  = [Double]()
        var pressure = [Int]()
        var humidity = [Int]()
        
        repeat {
        repeat {
            temp.append(forWeek[i2].tempNow)
            windSpeed.append(forWeek[i2].windSpeed)
            pressure.append(forWeek[i2].pressure)
            humidity.append(forWeek[i2].humidity)
     
            // дневные иконки для 15:00, ночные для 24:00
            if forWeek[i2].date.hasSuffix("15:00:00") {
                for5Days[i].iconDay = forWeek[i2].icon
                for5Days[i].dayDescription = forWeek[i2].mainDescription
            }
            if forWeek[i2].date.hasSuffix("00:00:00") {
                for5Days[i].iconNight = forWeek[i2].icon
                for5Days[i].nightDescription = forWeek[i2].mainDescription
            }
            
            i2 += 1
        } while i2 != forWeek.count && forWeek[i2].date.hasSuffix("00:00:00") != true

            // не определена дневная погода (при неполном дне в начале/конце)
            if for5Days[i].iconDay == "" {
              //  var index = i2
                var index = i2-1
                repeat {
                    if forWeek[index].icon.hasSuffix("d") {
                        for5Days[i].iconDay = forWeek[index].icon
                        for5Days[i].dayDescription = forWeek[index].mainDescription
                        break
                    }
                    index -= 1
                } while index > 0
                
                if for5Days[i].iconDay == "" {
                    for index in i2 ..< forWeek.count {
                        if forWeek[index].icon.hasSuffix("d") {
                            for5Days[i].iconDay = forWeek[index].icon
                            for5Days[i].dayDescription = forWeek[index].mainDescription
                            break
                        }
                    }
                }
                
                if for5Days[i].iconDay == ""  {
                    for5Days[i].iconDay = forWeek[i2].icon
                    for5Days[i].dayDescription = forWeek[i2].mainDescription
                }
            }
            
            // не определена ночная погода (при неполном дне в начале/конце)
            if for5Days[i].iconNight == "" {
                var index = i2
                repeat {
                    if forWeek[index].icon.hasSuffix("n") {
                        for5Days[i].iconNight = forWeek[index].icon
                        for5Days[i].nightDescription = forWeek[index].mainDescription
                        break
                    }
                    index -= 1
                } while index > 0
                
                if for5Days[i].iconNight == "" {
                    for index in i2 ..< forWeek.count {
                        if forWeek[index].icon.hasSuffix("n") {
                            for5Days[i].iconNight = forWeek[index].icon
                            for5Days[i].nightDescription = forWeek[index].mainDescription
                            break
                        
                        }
                    }
                }
                if for5Days[i].iconNight == ""  {
                    for5Days[i].iconNight = forWeek[i2].icon
                    for5Days[i].nightDescription = forWeek[i2].mainDescription
                }
            }
                    

            for5Days[i].minTemp = temp.min()!
            for5Days[i].maxTemp = temp.max()!
            for5Days[i].minWindSpeed = windSpeed.min()!
            for5Days[i].maxWindSpeed = windSpeed.max()!
            for5Days[i].minPressure = pressure.min()!
            for5Days[i].maxPressure = pressure.max()!
            for5Days[i].minHumidity = humidity.min()!
            for5Days[i].maxHumidity = humidity.max()!
            
            temp.removeAll()
            windSpeed.removeAll()
            pressure.removeAll()
            humidity.removeAll()
            i += 1
    } while i2 != forWeek.count
    

        
        forDay = forWeek[0]
        forDay.minTemp = for5Days[0].minTemp
        forDay.maxTemp = for5Days[0].maxTemp
        for5Days[0].weekDay = "TODAY"
        
    }
    
    
    func saveToDefaults() {
        UserDefaults.standard.set(store.localityName, forKey: "localityName")
        UserDefaults.standard.set(forDay.tempNow, forKey: "tempNow")
        
        UserDefaults.standard.set(forDay.icon, forKey: "icon")
        UserDefaults.standard.set(forDay.description, forKey: "description")
        
        UserDefaults.standard.set(forDay.minTemp, forKey: "minTemp")
        UserDefaults.standard.set(forDay.maxTemp, forKey: "maxTemp")
        
        UserDefaults.standard.set(forDay.windSpeed, forKey: "windSpeed")
        UserDefaults.standard.set(forDay.pressure, forKey: "pressure")
        UserDefaults.standard.set(forDay.humidity, forKey: "humidity")
        
        
        UserDefaults.standard.set(store.sunPrognosis.sunriseTime, forKey: "sunriseTime")
        UserDefaults.standard.set(store.sunPrognosis.sunsetTime, forKey: "sunsetTime")
        UserDefaults.standard.set(store.sunPrognosis.percent, forKey: "percent")
        UserDefaults.standard.set(store.sunPrognosis.isDayTime, forKey: "isDayTime")
    }
    
    
    func loadFromDefaults() -> Bool {
        
        if UserDefaults.standard.object(forKey: "localityName") == nil {
            return false
        }
        
        store.localityName = UserDefaults.standard.object(forKey: "localityName") as! String
        forDay.tempNow = UserDefaults.standard.integer(forKey: "tempNow")

        forDay.icon = UserDefaults.standard.object(forKey: "icon") as! String
        forDay.description = UserDefaults.standard.object(forKey: "description") as! String

        forDay.minTemp = UserDefaults.standard.integer(forKey: "minTemp")
        forDay.maxTemp = UserDefaults.standard.integer(forKey: "maxTemp")
        
        forDay.windSpeed = UserDefaults.standard.double(forKey: "windSpeed")
        forDay.pressure = UserDefaults.standard.integer(forKey: "pressure")
        forDay.humidity = UserDefaults.standard.integer(forKey: "humidity")
        
        store.sunPrognosis.sunriseTime = UserDefaults.standard.object(forKey: "sunriseTime") as! String
        store.sunPrognosis.sunsetTime = UserDefaults.standard.object(forKey: "sunsetTime") as! String
        store.sunPrognosis.percent = UserDefaults.standard.double(forKey: "percent")
        store.sunPrognosis.isDayTime = UserDefaults.standard.bool(forKey: "isDayTime")
        
        return true
        
    }

 
}

