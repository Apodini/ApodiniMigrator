//
// Created by Andreas Bauer on 13.11.21.
//

import Foundation
import ArgumentParser
import SwiftProtobufPluginLibrary

@main
struct ProtocPlugin: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "asdf",
        version: "0.1.2"
    )

    @Argument(parsing: .remaining, help: nil, completion: .directory)
    var paths: [String] = []

    func run() throws {
        if paths.isEmpty {
            generateFromStdin()
        } else {
            print("Received arguments: \(paths)")
        }
    }

    @discardableResult
    private func generateFromStdin() -> Int32 {
        let requestData = FileHandle.standardInput.readDataToEndOfFile()

        // TODO "PROTOC_GEN_SWIFT_LOG_REQUEST"

        let request: Google_Protobuf_Compiler_CodeGeneratorRequest
        do {
            try request = Google_Protobuf_Compiler_CodeGeneratorRequest(serializedData: requestData)
        } catch {
            Stderr.print("Request failed to decode: \(error)")
            return 1
        }

        let generator = CodePrinter()

        // request.protoFile.first?.sourceCodeInfo

        let json: String
        do {
            try json = request.jsonString()
        } catch {
            Stderr.print("Failed to convert to json string: \(error)")
            return 1
        }

        let url = URL(fileURLWithPath: "./TESTFILES/dump.json")
        do {
            try json.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            Stderr.print("Failed to write dump data: \(error)")
            return 1
        }

        return 0
    }
}

class Stderr { // TODO rename/redo?
    static func print(_ s: String) {
        let out = "\(s)\n"
        if let data = out.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}
