//
//  CityWeatherResponse.swift
//  Weather App
//
//  Created by Mehrdad on 2020-12-04.
//  Copyright © 2020 Seneca College. All rights reserved.
//

import Foundation

struct CityWeatherResponse: Codable {
    let main: Main
    let name: String
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
    
}
