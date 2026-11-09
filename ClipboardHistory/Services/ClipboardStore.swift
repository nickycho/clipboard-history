import Foundation
import GRDB

extension Notification.Name {
    static let clipboardStoreDidChange = Notification.Name("clipboardStoreDidChange")
}

class ClipboardStore: ObservableObject {
    private let database: Database
    private let maxItems = 500

    init(database: Database) {
        self.database = database
    }

    func add(content: String) {
        guard !content.isEmpty else { return }

        try? database.queue.write { db in
            if var existing = try ClipboardItem
                .filter(Column("content") == content)
                .fetchOne(db) {
                existing.createdAt = Date()
                try existing.update(db)
            } else {
                var item = ClipboardItem(id: nil, content: content, createdAt: Date(), isFavorite: false)
                try item.insert(db)
                try pruneIfNeeded(db)
            }
        }
        NotificationCenter.default.post(name: .clipboardStoreDidChange, object: nil)
    }

    func fetchAll() throws -> [ClipboardItem] {
        try database.queue.read { db in
            try ClipboardItem.order(Column("createdAt").desc).fetchAll(db)
        }
    }

    func fetchFavorites() throws -> [ClipboardItem] {
        try database.queue.read { db in
            try ClipboardItem
                .filter(Column("isFavorite") == true)
                .order(Column("createdAt").desc)
                .fetchAll(db)
        }
    }

    func toggleFavorite(_ item: ClipboardItem) {
        try? database.queue.write { db in
            var updated = item
            updated.isFavorite = !item.isFavorite
            try updated.update(db)
        }
    }

    func delete(_ item: ClipboardItem) {
        try? database.queue.write { db in
            try item.delete(db)
        }
    }

    private func pruneIfNeeded(_ db: GRDB.Database) throws {
        let total = try ClipboardItem.fetchCount(db)
        guard total > maxItems else { return }

        let overflow = total - maxItems
        let oldest = try ClipboardItem
            .filter(Column("isFavorite") == false)
            .order(Column("createdAt").asc)
            .limit(overflow)
            .fetchAll(db)

        for item in oldest {
            try item.delete(db)
        }
    }
}
