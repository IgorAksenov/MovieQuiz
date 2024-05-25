//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by  Игорь on 22.05.2024.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
} 
