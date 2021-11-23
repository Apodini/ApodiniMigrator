//
// Created by Andreas Bauer on 15.11.21.
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
    print(String(decoding: outputData, as: UTF8.self))
    print(String(decoding: errorData, as: UTF8.self))

    process.waitUntilExit()
}
