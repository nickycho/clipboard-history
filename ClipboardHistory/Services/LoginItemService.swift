import Foundation
import ServiceManagement

class LoginItemService {
    static let shared = LoginItemService()

    private init() {}

    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func registerIfNeeded() {
        guard SMAppService.mainApp.status == .notRegistered else { return }
        try? SMAppService.mainApp.register()
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // 忽略錯誤，使用者可以手動在系統設定中調整
        }
    }
}
