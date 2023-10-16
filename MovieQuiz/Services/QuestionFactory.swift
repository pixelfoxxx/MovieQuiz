//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 24/09/2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
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
            
            //MARK: - Question Generator
            
            let rating = Float(movie.rating) ?? 0
            let year = Int(movie.year) ?? 0
            let questionsAndAnswers = [
                ("Is the rating of this movie higher than 7?", rating > 7),
                ("Was this movie filmed before the year 2000?", year < 2000),
                ("Was this movie filmed after the year 2010?", year > 2010),
                ("Was this movie filmed after the year 2020?", year > 2020),
                ("Was this movie filmed before the year 1980?", year > 1980)
            ]
            
            let (questionText, correctAnswer) = questionsAndAnswers.randomElement() ?? ("Is the rating of this movie higher than 7?", false)
            
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
