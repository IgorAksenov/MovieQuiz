//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by  Игорь on 24.06.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func disableButtons()
    func enableButtons()
    func resetImageViewStyle()
}
