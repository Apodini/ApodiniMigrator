//
// Created by Andreas Bauer on 06.12.21.
//

import Foundation

public struct HTTPInformation: Value, LosslessStringConvertible {
    public var description: String {
        "\(hostname):\(port)"
    }

    let hostname: String
    let port: Int

    // TODO https/http

    // TODO e.g. add reserved paths (e.g. the apodini path?)
    // TODO http version?

    public init(hostname: String, port: Int = 80) {
        self.hostname = hostname
        self.port = port
    }

    public init?(_ description: String) { // TODO test that it works!
        guard let colonIndex = description.lastIndex(of: ":") else {
            return nil
        }

        self.hostname = String(description[description.startIndex ... colonIndex])

        let portString = String(description[description.index(after: colonIndex) ... description.endIndex])
        guard let port = Int(portString) else {
            return nil
        }
        self.port = port
    }
}
