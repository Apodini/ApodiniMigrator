//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO duplication
func findExecutable(named binaryName: String) -> URL? {
    guard let searchPaths = ProcessInfo.processInfo.environment["PATH"]?.components(separatedBy: ":") else {
        return nil
    }
    for searchPath in searchPaths {
        let executableUrl = URL(fileURLWithPath: searchPath, isDirectory: true)
            .appendingPathComponent(binaryName, isDirectory: false)
        if FileManager.default.fileExists(atPath: executableUrl.path) {
            return executableUrl
        }
    }
    return nil
}

internal func shell(executableURL: URL, _ args: [String], environment: [String: String]? = nil) throws {
    let process = Process()
    process.arguments = args
    process.executableURL = executableURL

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    process.environment = ProcessInfo.processInfo.environment.merging(environment ?? [:]) { $1 } // $1 is the "new" value

    try process.run()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

    let output = String(decoding: outputData, as: UTF8.self)
    let errorOutput = String(decoding: errorData, as: UTF8.self)

    if !output.isEmpty {
        print(output)
    }
    if !errorOutput.isEmpty {
        print(errorOutput)
    }

    process.waitUntilExit()
}
