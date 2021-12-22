//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation


protocol Comparator {
    associatedtype Element: Value
    associatedtype ChangeType: ChangeableElement // TODO naming!
    
    var lhs: Element { get }
    var rhs: Element { get }

    // var changes: ChangeCollection { get }
    
    func compare(_ context: ChangeComparisonContext, _ results: inout [Change<ChangeType>])
}
