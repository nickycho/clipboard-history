import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case traditionalChinese = "zh-Hant"
    case japanese = "ja"
    case korean = "ko"

    static let preferenceKey = "appLanguage"

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .system:
            Self.systemLocale
        default:
            Locale(identifier: rawValue)
        }
    }

    static var currentLocale: Locale {
        let selection = UserDefaults.standard.string(forKey: preferenceKey) ?? AppLanguage.system.rawValue
        return locale(for: selection)
    }

    static func locale(for selection: String) -> Locale {
        (AppLanguage(rawValue: selection) ?? .system).locale
    }

    private static var systemLocale: Locale {
        let language = Locale.preferredLanguages.first?.lowercased() ?? "en"
        if language.hasPrefix("zh") { return Locale(identifier: "zh-Hant") }
        if language.hasPrefix("ja") { return Locale(identifier: "ja") }
        if language.hasPrefix("ko") { return Locale(identifier: "ko") }
        return Locale(identifier: "en")
    }
}

@main
struct ClipboardHistoryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView()
        }
    }
}
