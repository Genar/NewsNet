//
//  ArticleTableViewCell.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    
    private var task: URLSessionDataTask?
    private var photoImage:UIImage?
    private let formatter = DateFormatter()
    
    func render(article: ArticleNewsPaper, using formatter: DateFormatter) {
        
        if let img = article.image as Data? {
            photoImage = UIImage(data: img)
        }
    }
    
    var article: Article? {
        
        didSet {
            guard let article = article else { return }
            
            if let published = article.published {
                publishedLabel.text = published.description
            } else {
                publishedLabel.text = nil
            }
            titleLabel.text = article.title
            snippetLabel.text = article.snippet
            if let img = self.photoImage {
                photoImageView.image = img
            } else {
                photoImageView.image = nil
            }
        }
    }
}
