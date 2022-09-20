import Foundation
import Mixpanel
import Segment

public struct TrackingClient {
    public var track: (String, [String: Any]?) -> Void
}

extension TrackingClient {
    public static func live(token: String) -> TrackingClient {
        return TrackingClient(
            track: { event, properties in
                // TBD
            }
        )
    }
}
