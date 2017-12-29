//
//  NewsManager.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import Foundation

class NewsManager : NSObject {
    
    static let service = NewsManager()
    
    // Structure to hold the values got
    // from https requests
    private struct Response: Codable {
        
        let sources: [Newspaper]?
        let articles: [Article]?
    }
    
    private enum API {
        
        private static let basePath = "https://newsapi.org/v1"
        //
        // Go to https://newsapi.org/register to get your
        // free API key, and then replace your key in the
        // following constant
        //
        private static let key = "fed53a58581641b49024dc6bc854db8c"
        
        case sources
        case articles(Newspaper)
        
        func fetch(completion: @escaping (Data) -> ()) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: path()) { (data, response, error) in
                guard let data = data, error == nil else { return }
                completion(data)
            }
            task.resume()
        }
        
        private func path() -> URL {
            
            switch self {
            case .sources:
                return URL(string: "\(API.basePath)/sources")!
            case .articles(let source):
                return URL(string: "\(API.basePath)/articles?source=\(source.id)&apiKey=\(API.key)")!
            }
        }
    }
    
    // A) @objc tells de compiler to make this property available to Objective-C
    // B) dynamic tells de compiler not to make any optimization about the variable
    //    (like inlining) and the property is dispatched to Objective-C runtime
    //    so that the getter and setter can be replaced at runtime.
    // C) The main purpose of that, in this app, is to allow KVO (Key Value Observing)
    //    for the "sources" and "articles" properties.
    @objc dynamic private(set) var sources: [Newspaper] = []
    @objc dynamic private(set) var articles: [Article] = []
    
    func fetchSources() {
        
        API.sources.fetch { data in
            if let json = String(data: data, encoding: .utf8) {
                print(json)
            }
            do {
                if let sources = try JSONDecoder().decode(Response.self, from: data).sources {
                    self.sources = sources
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchArticles(for source: Newspaper) {
        
        // Sometimes the date is not "iso8601" compliant, so
        // we have to delete the miliseconds; that is:
        // “2018-01-04T21:22:30.028Z" -> “2018-01-04T21:22:30Z"
        let formatter = ISO8601DateFormatter()
        let customDateHandler: (Decoder) throws -> Date = { decoder in
            var string = try decoder.singleValueContainer()
                .decode(String.self)
            string.deleteMilliseconds()
            guard let date = formatter.date(from: string)
                else { return Date() }
            return date
        }
        
        API.articles(source).fetch { data in
            
            if let json = String(data: data, encoding: .utf8) {
                print(json)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(customDateHandler)
            do {
                if let articles = try decoder.decode(Response.self, from: data).articles {
                    self.articles = articles
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func resetArticles() {
        articles = []
    }
}

