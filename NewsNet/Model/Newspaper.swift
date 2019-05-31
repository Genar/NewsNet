//
//  Newspaper.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import Foundation

class Newspaper : NSObject, Codable {
    
    let id: String
    let name: String
    let overview: String
    let category: String
    
    // Due to this class descends from NSObject,
    // so that "NewsAPI.service.observe(\.articles)"
    // can observe the articles information using KVO;
    // it is a requirement from KVO not use a name like
    // "description", because these names are already
    // defined in NSObjet (like also "id"), consequently, in the process of parsing
    // those names then they are replaced by another names (keys)
    // (for example "description" is replaced by "overview").
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case overview = "description"
        case category
    }
    
    init(id: String, name: String, overview: String, category: String) {
        
        self.id = id
        self.name = name
        self.overview = overview
        self.category = category
    }
    
    init(sourceNewsPaper: SourceNewsPaper?) {
        
        self.id = sourceNewsPaper?.id ?? ""
        self.name = sourceNewsPaper?.name ?? ""
        self.overview = sourceNewsPaper?.overview ?? ""
        self.category = sourceNewsPaper?.category ?? ""
    }
}
