//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 26/09/2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(with model: AlertModel)
}

final class AlertPresenter: AlertPresenterDelegate {
    
    private let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentAlert(with model: AlertModel) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alertController.addAction(action)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
