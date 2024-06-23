//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by  Игорь on 28.05.2024.
//

import UIKit

class ResultAlertPresenter {
    static func show(in viewController: UIViewController, title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        // Устанавливаем идентификаторы для элементов алерта
        alert.title = title
        alert.message = message
        alert.view.accessibilityIdentifier = "GameResultsAlert" // Можно также установить на сам алерт
        
        let action = UIAlertAction(title: "Пройти еще раз", style: .default) { _ in
            completion()
        }
        action.accessibilityIdentifier = "GameResultsAction" // Идентификатор для кнопки "Пройти еще раз"
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
