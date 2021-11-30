//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public class ReadMeFile: ResourceFile {
    public init(_ name: String = "README.md") {
        super.init(copy: name)
    }
}
