//
//  UIViewController+.swift
//  Stepic
//
//  Created by 강민수 on 3/28/25.
//

import UIKit

extension UIViewController {
    
    func configureMainButtonButtonConfiguration(title: String) -> UIButton.Configuration {
        var titleContainer = AttributeContainer()
        titleContainer.font = .titleSmall
        
        var configuration = UIButton.Configuration.filled()
        configuration.attributedTitle = AttributedString(title, attributes: titleContainer)
        configuration.baseBackgroundColor = .accentPrimary
        configuration.baseForegroundColor = .white
        
        return configuration
    }
    
    func presentToSettingAppWithLocation() {
        let alertController = UIAlertController(
            title: .StringLiterals.Alert.locationAlertTitle,
            message: .StringLiterals.Alert.locationAlertMessage,
            preferredStyle: .alert
        )
        
        let goToSettingAlertAction = UIAlertAction(
            title: .StringLiterals.Alert.locationAlertGoToSetting,
            style: .default
        ) { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingURL)
        }
        
        let cancelAlertAction = UIAlertAction(
            title: .StringLiterals.Alert.locationAlertCancel,
            style: .cancel
        )
        
        alertController.addAction(goToSettingAlertAction)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true)
    }
    
    func presentWarningAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: .StringLiterals.Alert.genericAlertConfirm,
            style: .default
        )
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    func dismissToRoot() {
        var presentingVC = self
        while let parent = presentingVC.presentingViewController {
            presentingVC = parent
        }
        
        presentingVC.dismiss(animated: true)
    }
    
    func presentSaveConfirmationAlert(
        title: String,
        message: String,
        onConfirm: @escaping () -> Void
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(
            title: .StringLiterals.Alert.alertSave,
            style: .default
        ) { _ in
            onConfirm()
        }
        
        let cancelAction = UIAlertAction(
            title: .StringLiterals.Alert.locationAlertCancel,
            style: .cancel
        )
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
