//
//  ViewController.swift
//  NotificationTest
//
//  Created by Stanislav  Kosatkin on 07.03.2020.
//  Copyright © 2020 Stanislav  Kosatkin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct Notification {
        struct Category {
            static let tutorial = "tutorial"
        }
        struct Action {
            static let readLater = "readLater"
            static let showDetails = "showDetails"
            static let unsubscribe = "unsubscribe"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserNotificationsCenter()
    }

    // MARK: Handlers
    @IBAction func scheduleLocalNotification(_ sender: Any) {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization { (success) in
                    guard success else {
                        return
                    }
                }
                self.scheduleLocalNotification()
            case .authorized:
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            default:
                print("Unknown notification status: \(notificationSettings.authorizationStatus)")
            }
        }
    }
    
    // MARK: Private methods
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    private func configureUserNotificationsCenter() {
        UNUserNotificationCenter.current().delegate = self
        
        let actionReadLater = UNNotificationAction(identifier: Notification.Action.readLater, title: "Read Later", options: [])
        let actionShowDetails = UNNotificationAction(identifier: Notification.Action.showDetails, title: "Show Details", options: [.foreground])
        let actionUnsubscribe = UNNotificationAction(identifier: Notification.Action.unsubscribe, title: "Unsubscribe", options: [.destructive, .authenticationRequired])
        
        let tutorialCategory = UNNotificationCategory(identifier: Notification.Category.tutorial, actions: [actionReadLater, actionShowDetails, actionUnsubscribe], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([tutorialCategory])
    }
    
    private func scheduleLocalNotification() {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "Cocoacasts"
        notificationContent.subtitle = "Local Notifications"
        notificationContent.body = "In this tutorial, you learn how to schedule local notifications with the Notifications framework."
        notificationContent.categoryIdentifier = Notification.Category.tutorial
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
        
        let notificatioRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificatioRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notification.Action.readLater:
            print("Save Totorial For Later")
        case Notification.Action.unsubscribe:
            print("Unsubscribe Reader")
        default:
            print("Other Action \(response.actionIdentifier)")
        }
        
        completionHandler()
    }
}
