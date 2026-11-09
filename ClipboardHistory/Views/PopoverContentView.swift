import SwiftUI

struct PopoverContentView: View {
    @AppStorage(AppLanguage.preferenceKey) private var languageSelection = AppLanguage.system.rawValue
    @State private var selectedTab: Tab = .history
    @StateObject private var historyViewModel: HistoryViewModel
    @StateObject private var favoritesViewModel: FavoritesViewModel

    enum Tab {
        case history, favorites
    }

    let onClose: () -> Void
    let onOpenPreferences: () -> Void

    init(store: ClipboardStore, onClose: @escaping () -> Void, onOpenPreferences: @escaping () -> Void) {
        _historyViewModel = StateObject(wrappedValue: HistoryViewModel(store: store))
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(store: store))
        self.onClose = onClose
        self.onOpenPreferences = onOpenPreferences
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabButton(title: "History", isSelected: selectedTab == .history) {
                    selectedTab = .history
                    historyViewModel.reload()
                }
                TabButton(title: "Favorites", isSelected: selectedTab == .favorites) {
                    selectedTab = .favorites
                    favoritesViewModel.reload()
                }
                Spacer()
                Menu {
                    Button {
                        onOpenPreferences()
                    } label: {
                        Label("Preferences", systemImage: "gearshape")
                    }

                    Divider()

                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Label("Quit", systemImage: "power")
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .accessibilityLabel("App Menu")
                .padding(.trailing, 8)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Divider()

            switch selectedTab {
            case .history:
                HistoryListView(viewModel: historyViewModel, onClose: onClose)
            case .favorites:
                FavoritesListView(viewModel: favoritesViewModel, onClose: onClose)
            }
        }
        .frame(width: 480, height: 600)
        .environment(\.locale, AppLanguage.locale(for: languageSelection))
    }
}

private struct TabButton: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .primary : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color(NSColor.selectedContentBackgroundColor).opacity(0.15)
                        : Color.clear
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
