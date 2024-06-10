//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by  Игорь on 25.05.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    func show(in viewController: UIViewController, model: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol {
    func show(in viewController: UIViewController, model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
