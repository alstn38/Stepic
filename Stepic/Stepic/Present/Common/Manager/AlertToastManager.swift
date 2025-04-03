//
//  AlertToastManager.swift
//  Stepic
//
//  Created by 강민수 on 4/3/25.
//

import UIKit

import Toast

final class AlertToastManager {
    
    static func showToastAtPresentedView(message: String) {
        DispatchQueue.main.async {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first,
                let view = window.rootViewController?.presentedViewController?.view
            else { return }

            view.makeToast(message)
        }
    }
}
