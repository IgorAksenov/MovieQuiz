//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by  Игорь on 22.05.2024.
//

import Foundation
protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func setup(delegate: QuestionFactoryDelegate)
    func resetAskedQuestions()
    func loadData()
}
