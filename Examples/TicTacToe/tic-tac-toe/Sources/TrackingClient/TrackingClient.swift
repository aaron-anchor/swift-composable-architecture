import Foundation
import Mixpanel

public struct TrackingClient {
    public let track: (String?, Properties?) -> Void
}

extension TrackingClient {
    public static func live(token: String) -> Self {
        Mixpanel.initialize(
            token: token,
            trackAutomaticEvents: true
        )

        return Self(
            track: { event, properties in
                Mixpanel.mainInstance().track(event: event, properties: properties)
            }
        )
    }
}
