//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol describing a ``Directory`` which contains ``TargetDorectory``s.
///
/// The following two directories exist:
/// * ``Sources``
/// * ``Tests``
public protocol TargetContainingDirectory {
    /// The ``TargetDirectory``s contained in this directory.
    var targets: [TargetDirectory] { get }
}
