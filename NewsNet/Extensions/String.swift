//
//  String.swift
//  NewsNet
//
//  Created by Genaro Codina Reverter on 27/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import Foundation

extension String {
    
    func deletingCharacters(in characters: CharacterSet) -> String {
        
        return self.components(separatedBy: characters).filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    mutating func deleteMilliseconds() {
        
        if count == 24 {
            let range = index(endIndex, offsetBy: -5)..<index(endIndex, offsetBy: -1)
            removeSubrange(range)
        }
    }
}
