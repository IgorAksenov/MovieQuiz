//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by  Игорь on 23.06.2024.
//


import UIKit

final class MovieQuizPresenter {
    let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?

    init(statisticService: StatisticServiceProtocol) {
        self.statisticService = StatisticService()
   
           
        }

    var correctAnswersCount: Int {
        return correctAnswers
    }

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
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    private func didAnswer(isYes: Bool) {
        viewController?.disableButtonsForOneSecond()
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }

    func showNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        if isLastQuestion() {
            showQuizResults()
        } else {
            switchToNextQuestion()
            viewController.requestNextQuestion()
        }
        viewController.enableButtons()
    }

    private func showQuizResults() {
        guard let viewController = viewController else { return }
        let message = makeResultsMessage()
        ResultAlertPresenter.show(in: viewController, title: "Этот раунд окончен!", message: message) { [weak self] in
            self?.restartGame()
            viewController.requestNextQuestion()
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

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let questionStep = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quizStep: questionStep)
        }
    }

    // Изменяем видимость метода didAnswer
    
}
