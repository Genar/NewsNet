//
//  NewsPaperViewController.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import UIKit
import CoreData

class NewsPaperViewController: UIViewController {
    
    @IBOutlet weak var newsPaperTableView: UITableView!
    @IBOutlet weak var newsPaperSearchBar: UISearchBar!
    
    private var query: String = ""
    private var fetchedNewsPapersRC: NSFetchedResultsController<SourceNewsPaper>!
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    private var token: NSKeyValueObservation?
    private var selectedNewspaper : Newspaper?
    private var selectedSourceNewspaper : SourceNewsPaper?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let titleStr = NSLocalizedString("newpapers", comment: "Newspapers")
        self.navigationItem.title = titleStr
        
        if SimpleReachability.isConnectedToNetwork() {
            token = NewsManager.service.observe(\NewsManager.sources) { _, _ in
                DispatchQueue.main.async {
                    self.insertNewsPaperInDDBB()
                    self.refreshNewsPaperFromDDBB()
                    self.newsPaperTableView.reloadData()
                }
            }
        
            NewsManager.service.fetchSources()
        } else {
            self.refreshNewsPaperFromDDBB()
            self.newsPaperTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "articlesSegue",
            let destination = segue.destination as? ArticlesViewController
            else { return }
        destination.source = self.selectedNewspaper
        destination.sourceNewspaper = self.selectedSourceNewspaper
    }
    
    private func refreshNewsPaperFromDDBB() {

        let request = SourceNewsPaper.fetchRequest() as NSFetchRequest<SourceNewsPaper>

        if !query.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        }
        let sort = NSSortDescriptor(key: #keyPath(SourceNewsPaper.name), ascending:true, selector: #selector(NSString.caseInsensitiveCompare(_:)))

        request.sortDescriptors = [sort]
        do {
            fetchedNewsPapersRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedNewsPapersRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func searchText(hideKeyboard: Bool, searchBar: UISearchBar) {
        
        guard let txt = newsPaperSearchBar.text else {
            return
        }
        query = txt
        if hideKeyboard {
            searchBar.resignFirstResponder()
        }
        refreshNewsPaperFromDDBB()
        newsPaperTableView.reloadData()
    }
    
    private func cleanSearch() {
        
        query = ""
        refreshNewsPaperFromDDBB()
        newsPaperSearchBar.text = nil
        newsPaperSearchBar.resignFirstResponder()
        newsPaperTableView.reloadData()
    }
    
    private func insertNewsPaperInDDBB() {

        NewsManager.service.sources.forEach { (newsPaper) in
            let newsPaperDB = SourceNewsPaper(entity: SourceNewsPaper.entity(), insertInto: self.context)
                newsPaperDB.id = newsPaper.id
                newsPaperDB.name = newsPaper.name
                newsPaperDB.overview = newsPaper.overview
                newsPaperDB.category = newsPaper.category
                self.appDelegate.saveContext()
        }
    }
    
}

// MARK: - UITableViewDelegate
extension NewsPaperViewController : UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let fetchRC = fetchedNewsPapersRC,
            let sections = fetchRC.sections,
            let objs = sections[section].objects else {
                return 0
        }
        return objs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fetchRC = fetchedNewsPapersRC else { return }
        let fetchedNewsPaper = fetchRC.object(at: indexPath)
        self.selectedSourceNewspaper = fetchedNewsPaper
        self.selectedNewspaper = Newspaper(sourceNewsPaper: fetchedNewsPaper)
        
        self.performSegue(withIdentifier: "articlesSegue", sender: self)
    }
}

// MARK: - UITableViewDataSource
extension NewsPaperViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsPaperCell", for: indexPath) as! NewsPaperTableViewCell
        let fetchedNewsPaper = fetchedNewsPapersRC.object(at: indexPath)
        cell.newspaper = Newspaper(sourceNewsPaper: fetchedNewsPaper)
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension NewsPaperViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchText(hideKeyboard: true, searchBar: searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.cleanSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText(hideKeyboard: false, searchBar: searchBar)
    }
}
