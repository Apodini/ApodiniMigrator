//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

// TODO facade approach
//  - endpoint addition: just regenerate
//  - endpoint deletion: stub (via extension?)
//  - endpoint rename: typealias (for protocol, and Client implementation?) => potential name conflicts
//  - Path Change/rpc method name change: extension?
//  - Operation changed: (no impact, BUT communicational pattern not considered)
//  - Response type changed: extension, but potential conflict with new response type! => Migration via JSScript?
//  - Parameter kind (leightweight, etc) change: not applicable
//  - Necessity of parameter: translates into a model change
//  - Type of parameter: translates  into a model change (requires new overloads?)
//  - New Parameter added: translate into a model change!
//  - Parameter deleted: translate into a model change!

// TODO custom solution won't support Interceptors!

// TODO top level parameter changes are weird to handle!
