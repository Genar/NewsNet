//
//  newsPaperTableViewCell.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import UIKit

class NewsPaperTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var newspaper: Newspaper? {
        
        didSet {
            guard let newspaper = newspaper else { return }
            nameLabel.text = newspaper.name
            overviewLabel.text = newspaper.overview
            categoryLabel.text = newspaper.category.capitalized
        }
    }
}
