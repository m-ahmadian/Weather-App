//
//  InitialViewController.swift
//  Weather App
//
//  Created by Mehrdad on 2020-12-04.
//  Copyright © 2020 Seneca College. All rights reserved.
//

import UIKit
import CoreData

class InitialViewController: UIViewController {
    
    // MARK: Properties
    // A reference to the core data stack
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<City>!
    
    // MARK: Outlets
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Function to set up fetch request and fetched results contoller
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: "name", cacheName: nil)
        // Set the delegate to self
        fetchedResultsController.delegate = self
        
        // Performing fetch on fetchedResultsController with handling errors
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegates
        searchView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Call the method to configure out fetchedResultsController
        setUpFetchedResultsController()
        // Deleting the search text and reloading our tableView whenever this view is about to appear
        searchView.text = ""
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Injecting the dependency of core data stack and passing the selected city if needed, based on the segue destination
        if segue.identifier == "SearchViewController" {
            let searchVC = segue.destination as? SearchViewController
            searchVC?.dataController = dataController
        } else if segue.identifier == "DetailViewController" {
            let detailVC = segue.destination as? DetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC?.city = fetchedResultsController.object(at: indexPath)
            }
        }
    }
    
    
    // MARK: Helper Method
    
    // Method to delete the managed object
    func deleteCity(at indexPath: IndexPath) {
        // Get a reference to the object that needs to be deleted
        let cityToDelete = fetchedResultsController.object(at: indexPath)
        // Delete the object from the context and save it to persist data to the store
        dataController.viewContext.delete(cityToDelete)
        try? dataController.viewContext.save()
    }
}


// MARK: Extension for TableViewDelegate & DataSource methods
extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let city = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = city.country
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // Enabling the delete feature by calling its helper method
            deleteCity(at: indexPath)
        default:
            () // Unsupported
        }
    }
    
}


// MARK: Extension for SearchBarDelegate method
extension InitialViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Add a predicate to fetch city names that begin with the search text, if the text is not empty
        let predicate: NSPredicate?
        if !searchText.isEmpty {
            predicate = NSPredicate(format: "name BEGINSWITH[c] %@", searchText)
        } else {
            predicate = nil
        }
        fetchedResultsController.fetchRequest.predicate = predicate
            
        do {
            try fetchedResultsController.performFetch()
//            print("searching for \(searchText)")
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}


// MARK: Extension for FetchedResultsControllerDelegate methods to automatically track and update the UI
extension InitialViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .fade)
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
        case .move, .update:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
}
