import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let searchText: String
    let onCopy: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    private var displayText: String {
        guard !searchText.isEmpty else { return item.content }
        let content = item.content
        guard let range = content.range(of: searchText, options: .caseInsensitive) else { return content }
        let matchStart = content.distance(from: content.startIndex, to: range.lowerBound)
        guard matchStart > 20 else { return content }
        let snippetStart = content.index(range.lowerBound, offsetBy: -15, limitedBy: content.startIndex) ?? content.startIndex
        return "..." + content[snippetStart...]
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(displayText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Text(item.createdAt, style: .relative)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isHovered {
                HStack(spacing: 8) {
                    Button {
                        onToggleFavorite()
                    } label: {
                        Image(systemName: item.isFavorite ? "star.fill" : "star")
                            .foregroundColor(item.isFavorite ? .yellow : .secondary)
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.isFavorite ? "Remove from Favorites" : "Add to Favorites")

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Delete")
                }
                .padding(.leading, 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(isHovered ? Color(NSColor.selectedContentBackgroundColor).opacity(0.15) : Color.clear)
        .onHover { isHovered = $0 }
        .onTapGesture { onCopy() }
    }
}

extension Date {
}
