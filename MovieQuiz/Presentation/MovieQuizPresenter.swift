//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by  Игорь on 23.06.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactory?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticServiceImplementation() // Example, replace with your implementation if needed
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    var correctAnswersCount: Int {
        return correctAnswers
    }

    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Game Logic
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }

        viewController?.disableButtons()
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.resetImageViewStyle()
            self.proceedToNextQuestionOrResults()
            self.viewController?.enableButtons()
        }
    }

    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            showQuizResults()
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    private func showQuizResults() {
        guard let viewController = viewController else { return }
        let message = makeResultsMessage()
        ResultAlertPresenter.show(in: viewController as! UIViewController, title: "Этот раунд окончен!", message: message) { [weak self] in
            self?.restartGame()
            self?.questionFactory?.requestNextQuestion()
        }
    }

    private func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let totalAccuracyString = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGameDate = DateFormatter.localizedString(from: statisticService.bestGame.date, dateStyle: .short, timeStyle: .short)
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество игр: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(bestGameDate))
        Средняя точность: \(totalAccuracyString)%
        """
        return message
    }
}
