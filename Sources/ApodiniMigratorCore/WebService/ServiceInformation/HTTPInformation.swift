//
// Created by Andreas Bauer on 06.12.21.
//

import Foundation

public struct HTTPInformation: Value {
    let hostname: String
    let port: Int

    // TODO e.g. add reserved paths (e.g. the apodini path?)
    // TODO http version?
}
