//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 16/10/2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
