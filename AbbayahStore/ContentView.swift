//
//  ContentView.swift
//  AbbayahStore
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        SplashView()
            .task {
                // Ask for notification permission once
                NotificationService.shared.requestPermission()

                // Already signed in from a previous session — pull cart + notifications
                if auth.isLoggedIn {
                    await CartStore.shared.loadFromServer()
                    await NotificationService.shared.fetch()
                    NotificationService.shared.startPolling()
                }
            }
    }
}

#Preview {
    ContentView()
}
