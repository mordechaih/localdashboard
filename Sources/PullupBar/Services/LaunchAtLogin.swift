import Foundation
import ServiceManagement

/// Thin wrapper over `SMAppService.mainApp` so PullupBar can launch itself at login. The system
/// (not `UserDefaults`) is the source of truth, so the toggle reads `isEnabled` and applies changes
/// via `setEnabled(_:)`. Only meaningful when running from a real app bundle (e.g. `/Applications`);
/// `register()` fails for a raw `swift run` binary.
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Registers or unregisters the app as a login item. Returns whether the requested state was
    /// achieved so the caller can revert the toggle on failure.
    @discardableResult
    static func setEnabled(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            return true
        } catch {
            NSLog("PullupBar: launch-at-login \(enabled ? "register" : "unregister") failed: \(error)")
            return false
        }
    }
}
