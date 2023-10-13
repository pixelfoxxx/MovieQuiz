//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 24/09/2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    //MARK: - Properties
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    //MARK: - Init
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    //MARK: - Functions
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let questionsAndAnswers = [
                ("Рейтинг этого фильма больше чем 7?", rating > 7),
                ("Рейтинг этого фильма меньше чем 7?", rating < 7)
            ]
            
            let (questionText, correctAnswer) = questionsAndAnswers.randomElement() ?? ("Рейтинг этого фильма больше чем 7?", false)
            
            let question = QuizQuestion(
                image: imageData,
                text: questionText,
                correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
