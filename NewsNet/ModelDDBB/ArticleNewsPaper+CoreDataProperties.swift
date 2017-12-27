//
//  ArticleNewsPaper+CoreDataProperties.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//
//

import Foundation
import CoreData


extension ArticleNewsPaper {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleNewsPaper> {
        return NSFetchRequest<ArticleNewsPaper>(entityName: "ArticleNewsPaper")
    }

    @NSManaged public var author: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: URL?
    @NSManaged public var published: NSDate?
    @NSManaged public var snippet: String?
    @NSManaged public var sourceUrl: URL?
    @NSManaged public var title: String?
    @NSManaged public var ownernewspaper: SourceNewsPaper?

}
