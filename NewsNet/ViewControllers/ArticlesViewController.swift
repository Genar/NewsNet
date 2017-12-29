//
//  ArticlesViewController.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import UIKit
import CoreData

class ArticlesViewController : UIViewController {
    
    @IBOutlet weak var articlesSearchBar: UISearchBar!
    @IBOutlet weak var articlesTableView: UITableView!
    
    var source: Newspaper?
    var sourceNewspaper: SourceNewsPaper?
    private var query : String = ""
    private var fetchedArticlesRC: NSFetchedResultsController<ArticleNewsPaper>!
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let formatter = DateFormatter()
    private var token: NSKeyValueObservation?
    private var task: URLSessionDataTask?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        formatter.dateFormat = "MMM d, h:mm a"
        guard let newsPaperName = source?.name else {
            let articleStr = NSLocalizedString("articles", comment: "Articles")
            self.navigationItem.title = articleStr
            return
        }
        let newsFromStr = NSLocalizedString("news_from", comment: "")
        let newsFromNewspaperStr = String(format:newsFromStr, newsPaperName)
        self.navigationItem.title = newsFromNewspaperStr
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        guard let source = source else { return }
        if SimpleReachability.isConnectedToNetwork() {
            token = NewsManager.service.observe(\NewsManager.articles) { _, _ in
                DispatchQueue.main.async {

                    self.insertArticleInDDBB()
                    self.refreshArticlesFromDDBB()
                    self.articlesTableView.reloadData()
                }
            }
            NewsManager.service.fetchArticles(for: source)
        } else {
            self.refreshArticlesFromDDBB()
            self.articlesTableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        fetchedArticlesRC = nil
        token?.invalidate()
        NewsManager.service.resetArticles()
    }
    
    // MARK: - Private methods
    private func refreshArticlesFromDDBB() -> Void {
        
        let request = ArticleNewsPaper.fetchRequest() as NSFetchRequest<ArticleNewsPaper>
        if let srcNewsPaper = sourceNewspaper {
            if query.isEmpty {
                request.predicate = NSPredicate(format: "ownernewspaper = %@", srcNewsPaper)
            } else {
                request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ AND ownernewspaper = %@", query, srcNewsPaper)
            }
        }
        
        let sort = NSSortDescriptor(key: #keyPath(ArticleNewsPaper.published), ascending: false)
        request.sortDescriptors = [sort]
        do {
            fetchedArticlesRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedArticlesRC.delegate = self
            try fetchedArticlesRC.performFetch()
        } catch let err as NSError {
            print("\(err.userInfo)")
        }
    }
    
    private func insertArticleInDDBB() {
        
        NewsManager.service.articles.forEach { (article) in
            let articleDB = ArticleNewsPaper(entity: ArticleNewsPaper.entity(), insertInto: self.context)
            articleDB.author = article.author
            articleDB.imageUrl = article.imageURL
            articleDB.sourceUrl = article.sourceURL
            articleDB.published = article.published as NSDate?
            articleDB.snippet = article.snippet
            articleDB.title = article.title
            articleDB.ownernewspaper = sourceNewspaper
            downloadImage(from:article.imageURL, articleDB:articleDB)
        }
    }
    
    private func downloadImage(from url: URL?, articleDB: ArticleNewsPaper) {
        
        if let imgUrl = url {
            let task = URLSession.shared.dataTask(with: imgUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                articleDB.image = data as NSData
                DispatchQueue.main.async {
                     self.appDelegate.saveContext()
                }
            }
            task.resume()
            self.task = task
        }
    }
    
    private func searchText(hideKeyboard: Bool, searchBar: UISearchBar) {
        
        guard let txt = articlesSearchBar.text else {
            return
        }
        query = txt
        if hideKeyboard {
            searchBar.resignFirstResponder()
        }
        refreshArticlesFromDDBB()
        articlesTableView.reloadData()
    }
    
    private func cleanSearch() {
        
        query = ""
        refreshArticlesFromDDBB()
        articlesSearchBar.text = nil
        articlesSearchBar.resignFirstResponder()
        articlesTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension ArticlesViewController : UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let fetchRC = fetchedArticlesRC,
            let sections = fetchRC.sections,
            let objs = sections[section].objects else {
                return 0
        }
        
        return objs.count
    }
}

// MARK: - UITableViewDelegate
extension ArticlesViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        let fetchedArticle = fetchedArticlesRC.object(at: indexPath)
        cell.render(article: fetchedArticle, using: formatter)
        cell.article = Article(articleNewsPaper: fetchedArticle)
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension ArticlesViewController : UISearchBarDelegate {
    
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

// MARK: - NSFetchedResultsControllerDelegate
extension ArticlesViewController : NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        self.articlesTableView.reloadData()
        
//        let index = indexPath ?? (newIndexPath ?? nil)
//
//        guard let rowIndex = index else {
//            return
//        }
//
//        switch type {
//        case .insert:
//            articlesTableView.insertRows(at: [rowIndex], with: .left)
//        case .delete:
//            articlesTableView.deleteRows(at: [rowIndex], with: .left)
//        // case .move:
//        // case .update:
//        default:
//            break
//        }
    }
}

