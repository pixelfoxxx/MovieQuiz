//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 25/09/2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
