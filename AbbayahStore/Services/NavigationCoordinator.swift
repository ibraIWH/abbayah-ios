import SwiftUI

/// Lets any screen ask the app to return all the way to the Home root,
/// instead of popping back one step at a time.
class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()

    /// Changing this value rebuilds the navigation stack, which clears every
    /// pushed screen and lands the user back at the root.
    @Published var rootID = UUID()

    func goHome() {
        rootID = UUID()
    }
}//
//  NavigationCoordinator.swift
//  AbbayahStore
//
//  Created by Ibrahim Hassan on 13/02/1448 AH.
//

