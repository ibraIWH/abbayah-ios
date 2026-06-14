import SwiftUI

@main
struct AbbayahStoreApp: App {
    @StateObject private var auth = AuthService.shared
    @StateObject private var cart = CartStore.shared
    @StateObject private var favourites = FavouritesService.shared

    init() {
        UINavigationBar.appearance().tintColor = .black
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(cart)
                .environmentObject(favourites)
        }
    }
}
