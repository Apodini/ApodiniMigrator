//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation


protocol Comparator {
    associatedtype ComparableElement: Value
    associatedtype ChangeElement: ChangeableElement
    
    var lhs: ComparableElement { get }
    var rhs: ComparableElement { get }
    
    func compare(_ context: ChangeComparisonContext, _ results: inout [Change<ChangeElement>])
}
