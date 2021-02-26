# Weather API

## Overview

Weather app allows users to check the weather for any of their favorite cities. All cities that are saved to Core Data will be listed on the initial view controller.

This app uses the Geobytes API to search for a city name as well as OpenWeatherMap API to access current weather data for selected cities. Weather App was completed as an assignment for Seneca College course in iOS Mobile Application Development by using fundamental principles as follows:

* Dependency Injection & Singleton Desing Pattern
* UISearchBar
* Network Request, API & Web Services
* Core Data & Persistence
* Core Data Stack, NSPersistentContainer and NSManagedObjectContext
* NSFetchRequest & NSFetchedResultsController

Language: Swift  
Assignment for: Seneca College - iOS Mobile Application Development course  


## Resources

Geobytes API: <https://geobytes.com/>
Weather API: <https://openweathermap.org/api>


## Setup

You need to replace you unique API Key for OpenWeatherMap API in the following static property of the `Service` class. This projects needs no additional setup.

```swift
static let apiKey = "Enter API Key Here"
```

## Contributing
Feel free to contribute to **Weather API**. Fork and clone this repository, then make a pull request once you have pushed your changes.


## Maintainers
m-ahmadian


## License
**Weather API** is available under the [MIT License](https://github.com/m-ahmadian/Weather-App/blob/master/LICENSE).
