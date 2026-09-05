import SwiftUI
import UserNotifications

@main
struct AbbayahStoreApp: App {
    @StateObject private var auth = AuthService.shared
    @StateObject private var cart = CartStore.shared
    @StateObject private var favourites = FavouritesService.shared
    @StateObject private var nav = NavigationCoordinator.shared

    // Lets banners appear even while the app is open (foreground)
    @UIApplicationDelegateAdaptor(NotificationDelegate.self) private var notifDelegate

    init() {
        UINavigationBar.appearance().tintColor = .black
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(cart)
                .environmentObject(favourites)
                .environmentObject(nav)
        }
    }
}

// Without this, iOS hides banners while your app is in the foreground.
// This delegate tells iOS to show them anyway.
class NotificationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
