//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Юрий Клеймёнов on 26/09/2023.
//

import UIKit

class AlertPresenter: AlertPresenterDelegate {
    
    private let VC: UIViewController
    
    init(VC: UIViewController) {
        self.VC = VC
    }
    
    func presentAlert(with result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        
        VC.present(alert, animated: true, completion: nil)
    }
}
