//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by  Игорь on 21.05.2024.
//
import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading

    private var askedQuestions: Set<Int> = []
    private var movies: [MostPopularMovie] = []

    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
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

            // Фильтрация доступных индексов
            let availableIndices = Array(0..<self.movies.count).filter { !self.askedQuestions.contains($0) }

            guard let index = availableIndices.randomElement() else {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }

            let movie = self.movies[index]

            do {
                let imageData = try Data(contentsOf: movie.resizedImageURL)
                let rating = Float(movie.rating) ?? 0
                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7

                let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
                self.askedQuestions.insert(index)

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func resetAskedQuestions() {
        askedQuestions.removeAll()
    }
}



//    private let questions: [QuizQuestion] = [
////        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
////        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
////        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
////        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
////        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
////        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
////        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
////        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
////        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
////        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
//    ]

  
