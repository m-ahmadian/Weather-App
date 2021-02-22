//
//  DetailViewController.swift
//  Weather App
//
//  Created by Mehrdad on 2020-12-05.
//  Copyright © 2020 Seneca College. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: Properties
    var city: City!
    
    // MARK: Outlets
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the view title with the corresponding city name
        self.title = city.name
        
        // Call Weather API to get the selected city weather response and set its humidity and temp attributes
        Service.taskForGETRequest(url: Service.Endpoints.getCityWeather(city.name ?? "").url, response: CityWeatherResponse.self, completion: handleCityWeatherResponse(response:error:))
    }
    
    
    // MARK: Helper Method - Completion Handler
    func handleCityWeatherResponse(response: Decodable?, error: Error?) {
        guard let response = response as? CityWeatherResponse else {
            print(error?.localizedDescription ?? "")
                return
        }
//            print(Service.Endpoints.getCityWeather(self.city.name!).url)
            DispatchQueue.main.async {
                self.humidityLabel.text = "\(String(describing: response.main.humidity))"
                self.tempLabel.text = "\(String(describing: Int(response.main.temp)))"
            }
    }

}
