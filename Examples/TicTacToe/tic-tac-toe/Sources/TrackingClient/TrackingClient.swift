import Foundation
import Mixpanel
import Segment

public struct TrackingClient {
    public var track: (String, [String: Any]?) -> Void
}

extension TrackingClient {
    public static func live(token: String) -> TrackingClient {

        let configuration = AnalyticsConfiguration(writeKey: token)
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = true
        Analytics.setup(with: configuration)

        return TrackingClient(
            track: { event, properties in
                Analytics.shared().track(event, properties: properties)
            }
        )
    }
}
