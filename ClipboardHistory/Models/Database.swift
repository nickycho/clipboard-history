import Foundation
import GRDB

class Database {
    static let shared = Database()

    let queue: DatabaseQueue

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbDir = appSupport.appendingPathComponent("ClipboardHistory")
        try? FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
        let dbPath = dbDir.appendingPathComponent("history.sqlite").path

        queue = try! DatabaseQueue(path: dbPath)
        try! migrate()
    }

    private func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_create_clipboard_items") { db in
            try db.create(table: "clipboard_items") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("content", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("isFavorite", .boolean).notNull().defaults(to: false)
            }
            try db.create(index: "index_clipboard_items_on_content", on: "clipboard_items", columns: ["content"])
        }

        try migrator.migrate(queue)
    }
}
