import SwiftUI

struct PreferencesView: View {
    @AppStorage(AppLanguage.preferenceKey) private var languageSelection = AppLanguage.system.rawValue
    @State private var launchAtLogin = LoginItemService.shared.isEnabled
    @ObservedObject private var excludeList = ExcludeListService.shared
    @State private var newKeyword = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("General") {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Language", selection: $languageSelection) {
                        Text("System Default").tag(AppLanguage.system.rawValue)
                        Text(verbatim: "English").tag(AppLanguage.english.rawValue)
                        Text(verbatim: "繁體中文").tag(AppLanguage.traditionalChinese.rawValue)
                        Text(verbatim: "日本語").tag(AppLanguage.japanese.rawValue)
                        Text(verbatim: "한국어").tag(AppLanguage.korean.rawValue)
                    }
                    .pickerStyle(.menu)

                    Toggle("Launch at login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) {
                            LoginItemService.shared.setEnabled(launchAtLogin)
                        }
                        .padding(.vertical, 4)
                }
            }

            GroupBox("Excluded Keywords") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Copied text containing any of the following strings will not be recorded.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        TextField("Enter keyword to exclude", text: $newKeyword)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { addKeyword() }

                        Button("Add") { addKeyword() }
                            .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if !excludeList.keywords.isEmpty {
                        Divider()

                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(excludeList.keywords.enumerated()), id: \.offset) { index, keyword in
                                    HStack {
                                        Text(keyword)
                                            .font(.system(.body, design: .monospaced))
                                        Spacer()
                                        Button {
                                            excludeList.remove(at: IndexSet(integer: index))
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("Remove Excluded Keyword")
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .frame(maxHeight: 160)
                    }
                }
                .padding(.vertical, 4)
            }

            Spacer()

            HStack {
                Spacer()
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
                HStack(spacing: 3) {
                    Text("Version")
                    Text(verbatim: version)
                    Text(verbatim: "(\(build))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(width: 400, height: 360)
        .environment(\.locale, AppLanguage.locale(for: languageSelection))
        .onChange(of: languageSelection) { _, newValue in
            NSApp.keyWindow?.title = String(localized: "Preferences", locale: AppLanguage.locale(for: newValue))
        }
    }

    private func addKeyword() {
        excludeList.add(newKeyword)
        newKeyword = ""
    }
}
