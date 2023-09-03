//
//  MovieQuizModels.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 03/09/2023.
//

import Foundation
import UIKit

// для состояния "Вопрос показан"
struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

// для состояния "Результат квиза"
struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

// для состояния "Результат ответа"
struct QuizAnswerResultModel {
    let answer: Bool
}
