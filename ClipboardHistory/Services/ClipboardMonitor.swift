import AppKit
import Foundation

class ClipboardMonitor {
    private let store: ClipboardStore
    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount

    init(store: ClipboardStore) {
        self.store = store
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        // 跳過密碼管理器標記的敏感內容
        if let types = pasteboard.types, types.contains(NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")) {
            return
        }

        guard let content = pasteboard.string(forType: .string), !content.isEmpty else { return }

        guard !ExcludeListService.shared.shouldExclude(content) else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.store.add(content: content)
        }
    }
}
