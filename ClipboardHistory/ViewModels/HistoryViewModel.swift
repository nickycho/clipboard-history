import AppKit
import Combine

class HistoryViewModel: ObservableObject {
    @Published var items: [ClipboardItem] = []

    private let store: ClipboardStore
    private var cancellables = Set<AnyCancellable>()

    init(store: ClipboardStore) {
        self.store = store
        NotificationCenter.default.publisher(for: .clipboardStoreDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &cancellables)
        reload()
    }

    func reload() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let result = (try? self.store.fetchAll()) ?? []
            DispatchQueue.main.async { self.items = result }
        }
    }

    func toggleFavorite(_ item: ClipboardItem) {
        store.toggleFavorite(item)
        reload()
    }

    func delete(_ item: ClipboardItem) {
        store.delete(item)
        reload()
    }

    func copyToClipboard(_ item: ClipboardItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
    }
}
