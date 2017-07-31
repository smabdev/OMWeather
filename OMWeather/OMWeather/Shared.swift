//
//  Shared.swift
//  OMWeather
//
//  Created by Alex on 16.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation


// синглтон для передачи данных
class Store {
    
    // получены ли данные в VC1 при первом запуске
    var isFirstDataLoad = false
    var localityName = ""
    var for5Days = Array (repeating: Weather.FiveDaysWeather(), count: 6)
    let dispatchGroup = DispatchGroup()
    
    // получение координат (VC1)
    var locationTask = false
    //получение названия места по координатам (VC1 & VC3)
    var geocodeTask = false
    //получение погоды по координатам (VC1 & VC3)
    var weatherTask = false
    //поиск места по введенной строке (VC1 & VC3)
    var timeZoneTask = false
    
    var sunPrognosis = Geocoder.SunPrognosis()

    
    static let shared = Store()
    private init () { }
}

let store = Store.shared
