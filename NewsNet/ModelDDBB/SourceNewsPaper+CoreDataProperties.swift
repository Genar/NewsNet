//
//  SourceNewsPaper+CoreDataProperties.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//
//

import Foundation
import CoreData


extension SourceNewsPaper {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SourceNewsPaper> {
        return NSFetchRequest<SourceNewsPaper>(entityName: "SourceNewsPaper")
    }

    @NSManaged public var category: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var overview: String?
    @NSManaged public var article: NSSet?

}

// MARK: Generated accessors for article
extension SourceNewsPaper {

    @objc(addArticleObject:)
    @NSManaged public func addToArticle(_ value: ArticleNewsPaper)

    @objc(removeArticleObject:)
    @NSManaged public func removeFromArticle(_ value: ArticleNewsPaper)

    @objc(addArticle:)
    @NSManaged public func addToArticle(_ values: NSSet)

    @objc(removeArticle:)
    @NSManaged public func removeFromArticle(_ values: NSSet)

}
