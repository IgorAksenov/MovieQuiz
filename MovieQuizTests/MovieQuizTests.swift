//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by  Игорь on 17.06.2024.
//


import XCTest
@testable import MovieQuiz

// Мок-объект для ViewController
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) { }
    func highlightImageBorder(isCorrectAnswer: Bool) { }
    func showLoadingIndicator() { }
    func hideLoadingIndicator() { }
    func showNetworkError(message: String) { }
    func disableButtons() { }
    func enableButtons() { }
    func resetImageViewStyle() { }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Создаем мок-объект ViewController
        let viewControllerMock = MovieQuizViewControllerMock()
        
        // Создаем объект MovieQuizPresenter
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        // Создаем тестовый вопрос
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        // Конвертируем модель в ViewModel
        let viewModel = sut.convert(model: question)
        
        // Проверяем, что ViewModel соответствует ожидаемым значениям
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
