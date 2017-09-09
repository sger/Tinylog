//
//  TLIAnalyticsTracker.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Mixpanel

final class TLIAnalyticsTracker: NSObject {

    class func createAlias(_ userID: String) {
        guard let mixpanel = Mixpanel.sharedInstance() else {
            fatalError()
        }
        mixpanel.createAlias(userID, forDistinctID: mixpanel.distinctId)
        mixpanel.identify(mixpanel.distinctId)

        let params = ["id": userID, "$name": userID, "$email": "\(userID)@tinylogapp.com"]

        mixpanel.registerSuperProperties(params as [AnyHashable: Any])
        mixpanel.people.set(params as [AnyHashable: Any])
    }

    class func trackMixpanelEvent(_ event: String!, properties: [String: String]! ) {
        guard let mixpanel = Mixpanel.sharedInstance() else {
            fatalError()
        }
        mixpanel.track(event, properties: properties)
    }
}
