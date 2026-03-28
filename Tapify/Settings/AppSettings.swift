import Foundation
import Combine

/**
 AppSettings

 The single source of truth for user preferences.
 All properties are persisted to UserDefaults immediately on change.
 Conforms to ObservableObject so SwiftUI views react to changes.
 */
final class AppSettings: ObservableObject {

    // MARK: - Detection settings

    /// Acceleration delta threshold in g-force (0.05 = very sensitive, 0.50 = firm only)
    @Published var threshold: Double {
        didSet { UserDefaults.standard.set(threshold, forKey: Keys.threshold) }
    }

    @Published var tapSpeed: TapSpeed {
        didSet { UserDefaults.standard.set(tapSpeed.rawValue, forKey: Keys.tapSpeed) }
    }

    /// Master on/off switch — when false, TapDetector skips all samples
    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Keys.isEnabled) }
    }

    /// When true (Tap Test tab is active), detection runs but actions are suppressed
    @Published var isTestMode: Bool = false

    // MARK: - Action assignments

    @Published var singleTapAction: ActionType {
        didSet { UserDefaults.standard.set(singleTapAction.rawValue, forKey: Keys.singleTapAction) }
    }

    @Published var doubleTapAction: ActionType {
        didSet { UserDefaults.standard.set(doubleTapAction.rawValue, forKey: Keys.doubleTapAction) }
    }

    @Published var tripleTapAction: ActionType {
        didSet { UserDefaults.standard.set(tripleTapAction.rawValue, forKey: Keys.tripleTapAction) }
    }

    /// URL of the app to open for the .openApp action
    @Published var openAppURL: URL? {
        didSet { UserDefaults.standard.set(openAppURL, forKey: Keys.openAppURL) }
    }

    /// Bookmark data for the open-app URL (for persistence across launches)
    @Published var openAppBookmark: Data? {
        didSet { UserDefaults.standard.set(openAppBookmark, forKey: Keys.openAppBookmark) }
    }

    // MARK: - Convenience

    func action(for count: TapCount) -> ActionType {
        switch count {
        case .single: return singleTapAction
        case .double: return doubleTapAction
        case .triple: return tripleTapAction
        }
    }

    func setAction(_ action: ActionType, for count: TapCount) {
        switch count {
        case .single: singleTapAction = action
        case .double: doubleTapAction = action
        case .triple: tripleTapAction = action
        }
    }

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard

        threshold       = max(0.05, min(0.50, defaults.double(forKey: Keys.threshold).nonZero ?? 0.20))
        isEnabled       = defaults.object(forKey: Keys.isEnabled) as? Bool ?? true

        tapSpeed        = TapSpeed(rawValue: defaults.string(forKey: Keys.tapSpeed) ?? "") ?? .balanced

        singleTapAction = ActionType(rawValue: defaults.string(forKey: Keys.singleTapAction) ?? "") ?? .playPause
        doubleTapAction = ActionType(rawValue: defaults.string(forKey: Keys.doubleTapAction) ?? "") ?? .lockScreen
        tripleTapAction = ActionType(rawValue: defaults.string(forKey: Keys.tripleTapAction) ?? "") ?? .screenshot

        openAppURL      = defaults.url(forKey: Keys.openAppURL)
        openAppBookmark = defaults.data(forKey: Keys.openAppBookmark)
    }

    // MARK: - Keys

    private enum Keys {
        static let threshold        = "threshold"
        static let tapSpeed         = "tapSpeed"
        static let isEnabled        = "isEnabled"
        static let singleTapAction  = "singleTapAction"
        static let doubleTapAction  = "doubleTapAction"
        static let tripleTapAction  = "tripleTapAction"
        static let openAppURL       = "openAppURL"
        static let openAppBookmark  = "openAppBookmark"
    }
}

private extension Double {
    /// Returns nil if the value is 0.0 (unset UserDefaults default)
    var nonZero: Double? { self == 0.0 ? nil : self }
}
