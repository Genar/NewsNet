//
//  Article.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import Foundation

class Article : NSObject, Codable {
    
    let author: String?
    let title: String
    let snippet: String
    let sourceURL: URL?
    let imageURL: URL?
    let published: Date?
    
    // Due to this class descends from NSObject,
    // so that "NewsAPI.service.observe(\.articles)"
    // can observe the articles information using KVO;
    // it is a requirement from KVO not use a name like
    // "description", because these names are already
    // defined in NSObjet; consequently, in the process of parsing
    // those names then they are replaced by another names (keys)
    // (for example "description" is replaced by "snippet").
    enum CodingKeys: String, CodingKey {
        
        case author
        case title
        case snippet = "description"
        case sourceURL = "url"
        case imageURL = "urlToImage"
        case published = "publishedAt"
    }
    
    init(author: String, title: String, snippet: String, sourceURL: URL, imageURL: URL, image: Data, published: Date) {
        
        self.author = author
        self.title = title
        self.snippet = snippet
        self.sourceURL = sourceURL
        self.imageURL = imageURL
        self.published = published
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        sourceURL = try container.decode(URL.self, forKey: .sourceURL)
        imageURL = try container.decode(URL.self, forKey: .imageURL)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        published = try container.decodeIfPresent(Date.self, forKey: .published)
        let rawSnippet = try container.decode(String.self, forKey: .snippet)
        snippet = rawSnippet.deletingCharacters(in: CharacterSet.newlines)
    }
    
    init(articleNewsPaper: ArticleNewsPaper?) {
        
        self.author = articleNewsPaper?.author ?? ""
        self.title = articleNewsPaper?.title ?? ""
        self.published = articleNewsPaper?.published as Date?
        self.snippet = articleNewsPaper?.snippet ?? ""
        self.sourceURL = articleNewsPaper?.sourceUrl ?? nil
        self.imageURL = articleNewsPaper?.imageUrl ?? nil
    }
}

