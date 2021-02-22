//
//  SearchViewController.swift
//  Weather App
//
//  Created by Mehrdad on 2020-12-04.
//  Copyright © 2020 Seneca College. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    // MARK: Properties
    // A reference to the returned URLSession Task to cancel after a new request is initiated - To handle slow connections and avoid unnecessary newtwork requests
    var currentSearchTask: URLSessionTask?
    // An optional array of strings to hold the city search network response
    var cities: [String]?
    // An instance of core data stack that is injected during the sender (prepare for segue) of the presenting view
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<City>!
    
    
    // MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    

    // Function to set up fetch request and fetched results contoller
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegates and fetchedResultsController
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setUpFetchedResultsController()
        
    }
    
    
    // MARK: Helper Methods
    // Method to add the selected city to the context and persist the data to the store
    func addCity(name: String) {
        // Instantiating the managed object associated with the main context
        let city = City(context: dataController.viewContext)
        // separate city name from province and country in the response string
        city.name = name.components(separatedBy: ",")[0]
        city.country = name.components(separatedBy: ",")[2]
        try? dataController.viewContext.save()
        
        // Configure and present the alertVC
        let alertVC = UIAlertController(title: "Successful", message: "\(city.name ?? "") has been added to the list of your cities", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Pop to the root vc after data being persisted and user is presented with a successful message
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(okAction)
        alertVC.view.layoutIfNeeded()
        present(alertVC, animated: true, completion: nil)
    }
    
}


// MARK: Extension - UITableViewDelgate & DataSource Methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        
        let city = cities?[indexPath.row]
        cell.textLabel?.text = city?.components(separatedBy: ",")[0] ?? ""
        
        if let count = city?.count {
            guard count > 2 && cell.textLabel?.text != nil else {
                return cell
            }
            cell.detailTextLabel?.text = city?.components(separatedBy: ",")[2] ?? ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cityName = cities?[indexPath.row] {
            addCity(name: cityName)
        }
    }
    
}


// MARK: Extension - UISearchBarDelegate Method
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Cancel the previous task when a new one is initiated - Enhances performance for slow connections
        currentSearchTask?.cancel()
        guard searchText.count > 2 else {
            cities?.removeAll()
            tableView.reloadData()
            return
        }
        
        currentSearchTask = Service.searchForCity(url: Service.Endpoints.getCity(searchText).url, completion: handleSearchCityResponse(cities:error:))
    }
    
    
    
    // Helper Method - Completion Handler
    func handleSearchCityResponse(cities: [String]?, error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
        // Fills the cities array with the API response, to power the tableView dataSource
        self.cities = cities
        tableView.reloadData()
    }
    
}


extension SearchViewController: NSFetchedResultsControllerDelegate {
    
}
