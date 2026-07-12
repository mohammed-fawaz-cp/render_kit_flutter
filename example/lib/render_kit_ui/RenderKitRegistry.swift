import SwiftUI

struct RenderKitRegistry {
    static let screens: [String: ([String: Any], @escaping (String, [String: Any]) -> Void) -> AnyView] = [
        "IncomingCallScreen": { state, onEvent in
            AnyView(IncomingCallScreen(state: state, onEvent: onEvent))
        }
    ]
}
