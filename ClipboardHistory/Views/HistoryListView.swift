import SwiftUI

struct HistoryListView: View {
    @ObservedObject var viewModel: HistoryViewModel
    let onClose: () -> Void

    @State private var searchText = ""
    @State private var selectedIndex: Int? = nil

    private var displayedItems: [ClipboardItem] {
        guard !searchText.isEmpty else { return viewModel.items }
        return viewModel.items.filter { $0.content.localizedStandardContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $searchText)

            if displayedItems.isEmpty {
                Spacer()
                Text(viewModel.items.isEmpty ? "No clipboard history" : "No matching results")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(displayedItems.enumerated()), id: \.offset) { index, item in
                                ClipboardItemRow(
                                    item: item,
                                    searchText: searchText,
                                    onCopy: {
                                        viewModel.copyToClipboard(item)
                                        onClose()
                                    },
                                    onToggleFavorite: {
                                        viewModel.toggleFavorite(item)
                                    },
                                    onDelete: {
                                        viewModel.delete(item)
                                    }
                                )
                                .background(selectedIndex == index ? Color(NSColor.selectedContentBackgroundColor).opacity(0.25) : Color.clear)
                                .id(index)
                                Divider()
                                    .padding(.horizontal, 12)
                            }
                        }
                    }
                    .onChange(of: selectedIndex) { newIndex in
                        if let idx = newIndex {
                            withAnimation { proxy.scrollTo(idx, anchor: .center) }
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.reload() }
        .onChange(of: searchText) { _ in
            selectedIndex = displayedItems.isEmpty ? nil : 0
        }
        .onKeyPress(.upArrow) {
            moveSelection(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            moveSelection(by: 1)
            return .handled
        }
        .onKeyPress(.return) {
            if let idx = selectedIndex, idx < displayedItems.count {
                viewModel.copyToClipboard(displayedItems[idx])
                onClose()
            }
            return .handled
        }
        .onKeyPress(.escape) {
            onClose()
            return .handled
        }
    }

    private func moveSelection(by delta: Int) {
        guard !displayedItems.isEmpty else { return }
        let current = selectedIndex ?? -1
        let next = max(0, min(displayedItems.count - 1, current + delta))
        selectedIndex = next
    }
}
