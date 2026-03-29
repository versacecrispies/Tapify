import SwiftUI
import AppKit

struct ActionsView: View {
    @ObservedObject var settings: AppSettings
    @State private var showingAppPicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("Actions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.primaryText)
                    Text("Assign an action to each tap pattern.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryText)
                }

                ForEach(TapCount.allCases, id: \.rawValue) { count in
                    ActionRow(
                        count:    count,
                        settings: settings,
                        showingAppPicker: $showingAppPicker
                    )
                }

                // Open App path display
                if settings.singleTapAction == .openApp ||
                   settings.doubleTapAction == .openApp ||
                   settings.tripleTapAction == .openApp {
                    Card {
                        HStack(spacing: 10) {
                            Image(systemName: "app.badge")
                                .foregroundColor(Theme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("App to open")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Theme.primaryText)
                                Text(settings.openAppURL?.lastPathComponent
                                        .replacingOccurrences(of: ".app", with: "") ?? "None selected")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.secondaryText)
                            }
                            Spacer()
                            Button("Choose…") {
                                pickApp()
                            }
                            .buttonStyle(AccentButtonStyle())
                        }
                    }
                }

                // Run Shortcut name input
                if settings.singleTapAction == .runShortcut ||
                   settings.doubleTapAction == .runShortcut ||
                   settings.tripleTapAction == .runShortcut {
                    Card {
                        HStack(spacing: 10) {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(Theme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Shortcut name")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Theme.primaryText)
                                TextField("e.g. Morning Routine", text: $settings.shortcutName)
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.primaryText)
                                    .textFieldStyle(.plain)
                            }
                        }
                    }
                }

                // Run Custom Command input
                if settings.singleTapAction == .runCustomCommand ||
                   settings.doubleTapAction == .runCustomCommand ||
                   settings.tripleTapAction == .runCustomCommand {
                    Card {
                        HStack(spacing: 10) {
                            Image(systemName: "terminal")
                                .foregroundColor(Theme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Shell command")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Theme.primaryText)
                                TextField("e.g. say hello", text: $settings.customCommand)
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.primaryText)
                                    .textFieldStyle(.plain)
                                    .fontDesign(.monospaced)
                            }
                        }
                    }
                }

                Spacer(minLength: 8)
            }
            .padding(Theme.cardPadding)
        }
    }

    private func pickApp() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.application]
        panel.title = "Choose an Application"
        if panel.runModal() == .OK, let url = panel.url {
            settings.openAppURL = url
        }
    }
}

// MARK: - Single action row

struct ActionRow: View {
    let count: TapCount
    @ObservedObject var settings: AppSettings
    @Binding var showingAppPicker: Bool

    private var binding: Binding<ActionType> {
        Binding(
            get: { settings.action(for: count) },
            set: { settings.setAction($0, for: count) }
        )
    }

    var body: some View {
        Card {
            HStack(spacing: 12) {
                // Tap count icon
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: count.dotSymbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(count.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.primaryText)
                    Text(binding.wrappedValue.shortName)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.secondaryText)
                }

                Spacer()

                // Action picker
                Picker("", selection: binding) {
                    ForEach(ActionType.allCases) { action in
                        HStack {
                            Image(systemName: action.systemImage)
                            Text(action.rawValue)
                        }
                        .tag(action)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 180)
                .accentColor(Theme.primaryText)
            }
        }
    }
}

// MARK: - Accent button style

struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Theme.primaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(configuration.isPressed
                        ? Theme.surfaceHover : Theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
            .cornerRadius(6)
    }
}
