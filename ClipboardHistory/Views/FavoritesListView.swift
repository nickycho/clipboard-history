import SwiftUI

struct FavoritesListView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    let onClose: () -> Void

    @State private var searchText = ""

    private var displayedItems: [ClipboardItem] {
        guard !searchText.isEmpty else { return viewModel.items }
        return viewModel.items.filter { $0.content.localizedStandardContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $searchText)

            if displayedItems.isEmpty {
                Spacer()
                Text(viewModel.items.isEmpty ? "No favorites yet" : "No matching results")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(displayedItems, id: \.id) { item in
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
                            Divider()
                                .padding(.horizontal, 12)
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.reload() }
    }
}
