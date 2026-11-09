import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var preferencesWindow: NSWindow?
    private var globalHotKeyMonitor: Any?
    private let database = Database.shared
    private let clipboardStore: ClipboardStore
    private let clipboardMonitor: ClipboardMonitor

    override init() {
        clipboardStore = ClipboardStore(database: database)
        clipboardMonitor = ClipboardMonitor(store: clipboardStore)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupGlobalHotKey()
        clipboardMonitor.start()
        LoginItemService.shared.registerIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor.stop()
        if let monitor = globalHotKeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: String(localized: "Clipboard History", locale: AppLanguage.currentLocale))
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 480, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverContentView(store: clipboardStore, onClose: { [weak self] in
                self?.popover.close()
            }, onOpenPreferences: { [weak self] in
                self?.openPreferences()
            })
        )
    }

    func openPreferences() {
        if preferencesWindow == nil {
            let controller = NSHostingController(rootView: PreferencesView())
            let window = NSWindow(contentViewController: controller)
            window.title = String(localized: "Preferences", locale: AppLanguage.currentLocale)
            window.styleMask = [.titled, .closable]
            window.setContentSize(NSSize(width: 400, height: 360))
            window.center()
            window.isReleasedWhenClosed = false
            preferencesWindow = window
        }
        popover.performClose(nil)
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setupGlobalHotKey() {
        globalHotKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // ⌘⇧V: keyCode 9 = V, modifiers = command + shift
            if event.keyCode == 9 &&
               event.modifierFlags.contains(.command) &&
               event.modifierFlags.contains(.shift) {
                DispatchQueue.main.async {
                    self?.togglePopover()
                }
            }
        }
    }

    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            guard let button = statusItem.button else { return }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func closePopover() {
        popover.close()
    }
}
