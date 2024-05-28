//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by  Игорь on 26.05.2024.
//
import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case correctAnswers
        case totalQuestions
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
    }

    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }

    private var totalQuestions: Int {
        get {
            storage.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }

    var totalAccuracy: Double {
        guard totalQuestions > 0 else {
            return 0.0
        }
        return (Double(correctAnswers) / (10 * Double(gamesCount))) * 100.0
    }

    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        totalQuestions += amount
        gamesCount += 1

        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.correct > bestGame.correct {
            bestGame = currentGameResult
        }
    }
}

