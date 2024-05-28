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
        
        alert.addAction(UIAlertAction(title: "Пройти еще раз", style: .default) { _ in
            completion()
        })
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
