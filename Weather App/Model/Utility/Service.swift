//
//  Service.swift
//  Weather App
//
//  Created by Mehrdad on 2020-12-04.
//  Copyright © 2020 Seneca College. All rights reserved.
//

import Foundation

class Service {
    
    // Creating a shared instanse for Singleton design pattern - However, Dependency Injection design pattern is used for this app
    static let shared = Service()
    private init() {}
    
    // API Key
    static let apiKey = "Enter API Key Here"
    
    enum Endpoints {
        static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
        static let apiKeyParam = "&appid=\(apiKey)"
        
        case getCity(String)
        case getCityWeather(String)
        
        var stringValue: String {
            switch self {
            case .getCity(let query):
                // Enable adding space in the query by setting addingPercentEncoding to urlQueryAllowed
                return "http:// /AutoCompleteCity?callback=?&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            case .getCityWeather(let city):
                // Enable adding space in the city name search by setting addingPercentEncoding
                return Endpoints.baseURL + "?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" + "&units=metric" + Endpoints.apiKeyParam
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    
    // A GET request class func with generics and discardableResult attribute for the return type if it's not being used
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    
    // A class func to use in the SearchViewController to search for the city using a GET request from Geobytes Web API
    class func searchForCity(url: URL, completion: @escaping ([String]?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            // If we drop the first and last two characters of the response, we will get and array of Strings
            let stringData = String(data: data, encoding: .utf8)
            let str1 = stringData?.dropFirst(2)
            let str2 = str1?.dropLast(2)
            
            if let convertedData = str2?.data(using: .utf8) {
                do {
                    let response = try JSONSerialization.jsonObject(with: convertedData, options: []) as? [String]
                        DispatchQueue.main.async {
                            completion(response, nil)
                        }
                    } catch {
                    DispatchQueue.main.async {
                        completion([], error)
                        }
                    }
            }
        }
        task.resume()
        return task
    }
    
    
}
