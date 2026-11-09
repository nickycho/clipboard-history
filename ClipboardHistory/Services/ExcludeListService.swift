import Foundation

class ExcludeListService: ObservableObject {
    static let shared = ExcludeListService()

    private let userDefaultsKey = "excludedKeywords"

    @Published var keywords: [String] {
        didSet {
            UserDefaults.standard.set(keywords, forKey: userDefaultsKey)
        }
    }

    private init() {
        keywords = UserDefaults.standard.stringArray(forKey: "excludedKeywords") ?? []
    }

    func add(_ keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !keywords.contains(trimmed) else { return }
        keywords.append(trimmed)
    }

    func remove(at offsets: IndexSet) {
        offsets.reversed().forEach { keywords.remove(at: $0) }
    }

    func shouldExclude(_ content: String) -> Bool {
        keywords.contains { content.contains($0) }
    }
}
