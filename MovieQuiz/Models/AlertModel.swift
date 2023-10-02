//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 26/09/2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
