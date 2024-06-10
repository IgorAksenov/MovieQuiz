//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by  Игорь on 28.05.2024.
//

import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }

    var totalAccuracy: Double {
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
        let total = userDefaults.integer(forKey: Keys.total.rawValue)
        return total > 0 ? (Double(correct) / Double(total)) * 100 : 0
    }

    var gamesCount: Int {
        return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }

    var bestGame: GameResult {
        guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
              let record = try? JSONDecoder().decode(GameResult.self, from: data) else {
            return GameResult(correct: 0, total: 0, date: Date())
        }
        return record
    }

    func store(correct count: Int, total amount: Int) {
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let total = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        userDefaults.set(correct, forKey: Keys.correct.rawValue)
        userDefaults.set(total, forKey: Keys.total.rawValue)
        
        let gamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue) + 1
        userDefaults.set(gamesCount, forKey: Keys.gamesCount.rawValue)
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            if let data = try? JSONEncoder().encode(currentGame) {
                userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            }
        }
    }
}
