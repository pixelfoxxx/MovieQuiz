//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 26/09/2023.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(with result: AlertModel)
}
