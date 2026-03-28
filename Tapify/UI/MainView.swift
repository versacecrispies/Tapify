import SwiftUI

struct MainView: View {
    @ObservedObject var settings:  AppSettings
    @ObservedObject var detector:  TapDetector

    @State private var selectedTab: Tab = .dashboard

    enum Tab: CaseIterable {
        case dashboard, actions, test

        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .actions:   return "Actions"
            case .test:      return "Tap Test"
            }
        }

        var icon: String {
            switch self {
            case .dashboard: return "waveform"
            case .actions:   return "bolt.fill"
            case .test:      return "hand.tap.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.title) { tab in
                    TabButton(
                        tab:      tab,
                        selected: selectedTab == tab,
                        action:   { selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 4)

            Divider()
                .background(Theme.divider)

            // Tab content
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView(settings: settings, detector: detector)
                case .actions:
                    ActionsView(settings: settings)
                case .test:
                    KnockTestView(detector: detector, settings: settings)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.background)
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { newTab in
            settings.isTestMode = (newTab == .test)
        }
    }
}

// MARK: - Tab Button

private struct TabButton: View {
    let tab: MainView.Tab
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(selected ? Theme.accent : Theme.secondaryText)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                selected
                ? Theme.accentSoft
                : Color.clear
            )
            .cornerRadius(7)
        }
        .buttonStyle(.plain)
    }
}
