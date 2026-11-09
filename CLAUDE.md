# ClipboardHistory — Claude Code 開發指引

## 專案概述

macOS menu bar app，用 Swift + SwiftUI 開發，記錄剪貼簿文字歷史，支援快速搜尋、我的最愛，以及全域快捷鍵。

## 技術棧

- **語言**：Swift 5.9+
- **UI**：SwiftUI
- **資料庫**：SQLite via [GRDB.swift](https://github.com/groue/GRDB.swift)
- **最低系統需求**：macOS 14 Sonoma
- **發佈方式**：Direct download `.dmg`，需 Apple Developer 簽名 + Notarize

## 專案結構

```
ClipboardHistory/
├── App/
│   ├── ClipboardHistoryApp.swift      # App entry point，設定 menu bar
│   └── AppDelegate.swift              # NSApplicationDelegate
├── Models/
│   ├── ClipboardItem.swift            # GRDB record model
│   └── Database.swift                 # DatabaseQueue 設定與 migration
├── Services/
│   ├── ClipboardMonitor.swift         # Polling 監聽（0.5s interval）
│   ├── ClipboardStore.swift           # CRUD 操作（新增、去重、上限管理）
│   └── LoginItemService.swift         # SMAppService 自動啟動管理
├── Views/
│   ├── PopoverContentView.swift       # 根視圖，含分頁切換
│   ├── HistoryListView.swift          # History 分頁
│   ├── FavoritesListView.swift        # 我的最愛分頁
│   ├── ClipboardItemRow.swift         # 每筆 item 的 row view
│   └── SearchBarView.swift            # 搜尋框
├── ViewModels/
│   ├── HistoryViewModel.swift         # History 列表狀態管理
│   └── FavoritesViewModel.swift       # 我的最愛狀態管理
└── Resources/
    └── Assets.xcassets                # menu bar icon
```

## 核心設計決策

### Clipboard 監聽

- 使用 `Timer` 每 **0.5 秒**輪詢 `NSPasteboard.general.changeCount`
- 若 `changeCount` 有變化，讀取 `string(forType: .string)`
- 過濾 `NSPasteboard.general.types` 包含 `"org.nspasteboard.ConcealedType"` 的項目（密碼管理器標記的敏感內容），直接跳過不記錄

### 資料模型（GRDB）

```swift
struct ClipboardItem: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var content: String
    var createdAt: Date
    var isFavorite: Bool
}
```

### 去重邏輯

新內容進來時：
1. 查詢是否已存在相同 `content`
2. 若存在：更新 `createdAt` 為現在，移到列表最上方
3. 若不存在：插入新紀錄，並檢查總筆數是否超過 **500 筆**，超過則刪除最舊的非我的最愛項目

### NSPopover 設定

- 大小：**480 × 600**
- `behavior = .transient`（點外面自動關閉）
- 點擊 menu bar icon 或按 `⌘⇧V` 觸發顯示

### 全域快捷鍵

使用 `NSEvent.addGlobalMonitorForEvents(matching: .keyDown)` 監聽 `⌘⇧V`，於 App 內觸發 Popover 顯示。

### 鍵盤導航

- `↑` / `↓`：移動 focus 到上一筆/下一筆
- `Enter`：複製選中項目到 clipboard，關閉 Popover
- `Esc`：關閉 Popover

### 選取後行為

點擊（或 Enter）某筆 item 後：
1. 寫入 `NSPasteboard.general`
2. 關閉 Popover

## 開發注意事項

- App 為 **menu bar only**，不出現在 Dock，`LSUIElement = YES` 設定於 `Info.plist`
- 使用 `SMAppService.mainApp.register()` / `.unregister()` 管理 Login Item
- GRDB DatabaseQueue 使用單例，透過 `@EnvironmentObject` 或 dependency injection 傳遞
- SwiftUI Popover 內的 `List` 需處理 focus state 以支援鍵盤導航
- 所有 DB 操作在 background queue 執行，UI 更新回到 main thread

## 不在 MVP 範圍內

- 圖片/檔案 clipboard 支援
- App 黑名單（來源 app 過濾）
- 自訂快捷鍵
- iCloud 同步
- App Store 上架
