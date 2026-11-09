import Foundation
import GRDB

struct ClipboardItem: Codable, FetchableRecord, MutablePersistableRecord {
    var id: Int64?
    var content: String
    var createdAt: Date
    var isFavorite: Bool

    static let databaseTableName = "clipboard_items"

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
