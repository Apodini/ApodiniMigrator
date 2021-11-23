//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public protocol TargetContainingDirectory {
    var targets: [TargetDirectory] { get }
}
