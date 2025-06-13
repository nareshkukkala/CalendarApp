//
//  CalendarAppApp.swift
//  CalendarApp
//
//  Created by naresh kukkala on 12/06/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct CalendarAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        if granted {
                            print("✅ Notifications authorized")
                        } else {
                            print("❌ Notifications denied")
                        }
                    }
                }
        }
        .modelContainer(for: Event.self) { result in
            switch result {
            case .success(let container):
                MockEventSeeder.preload(into: container.mainContext)
            case .failure(let error):
                print("❌ Failed to initialize container: \(error)")
            }
        }
//        .modelContainer(for: Event.self)
    }
}
