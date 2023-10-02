//
//  BestGame.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 30/09/2023.
//

import Foundation

struct BestGame: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension BestGame: Comparable {
    
    private var accuracy: Double {
        return Double(correct) / Double(total)
    }
    
    static func < (lhs: BestGame, rhs: BestGame) -> Bool {
        lhs.accuracy < rhs.accuracy
    }
}
