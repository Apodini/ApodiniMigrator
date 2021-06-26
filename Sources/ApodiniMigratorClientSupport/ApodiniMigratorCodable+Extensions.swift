import Foundation
@_implementationOnly import JavaScriptCore
// swiftlint:disable line_length function_parameter_count
/// ApodiniMigratorCodable extension
public extension ApodiniMigratorCodable {
    /// A function that creates an instance of type `Self` with empty values
    static func defaultValue() throws -> Self {
        try JSONStringBuilder.instance(Self.self)
    }
    
    /// A function that creates an instance of type `Self` from a valid json string
    static func instance(from jsonValue: JSONValue) throws -> Self {
        try Self.decoder.decode(Self.self, from: jsonValue.rawValue.data(using: .utf8) ?? Data())
    }
    
    /// A function that creates an instance of type `Self` from data
    static func instance(from data: Data) throws -> Self {
        try Self.decoder.decode(Self.self, from: data)
    }
    
    /// Creates an instance of type `Self`, out of an `ApodiniMigratorEncodable` value
    /// ```swift
    /// // MARK: - Code example
    /// struct Student: Codable {
    ///     let name: String
    ///     let matrNr: UUID
    /// }
    ///
    /// struct Developer: Codable {
    ///     let id: UUID
    ///     let name: String
    /// }
    /// ```
    /// In order to create a `Developer` instance out of a `Student`,
    /// the function would expect a `Student` instance for the `value` argument,
    /// and a valid javaScript code that handles the convertion
    /// ```swift
    /// let student = Student(name: "John", id: UUID())
    /// ```
    /// ```javascript
    /// function convert(input) {
    ///     let parsed = JSON.parse(input)
    ///     return JSON.stringify({ 'id' : parsed.matrNr, 'name' : parsed.name })
    /// }
    /// ```
    /// Steps inside the functions:
    /// 1. Creates a valid json represantion of `value` argument
    /// 2. Parses the function name of the javascript
    /// 3. Retrieves the `json` string returned from the javascript `convert` function with the input of Step 1.
    /// 4. The string data is used to decode the new `Developer` instance
    /// 5. The developer instance as defined in the script, is created with `id` from `matrNr` and `name` from `name` of the student
    /// 6. In case that the script is invalid, the instance is created with default empty values, e.g `Developer(name: "", id: UUID())`
    ///
    /// - Throws: if decoding fails
    static func from<E: ApodiniMigratorEncodable>(_ value: E, script: JSScript) throws -> Self {
        try fromValue(value, script: script)
    }
}

/// ApodiniMigratorCodable fileprivate extension
fileprivate extension ApodiniMigratorCodable {
    /// The function that handles the javascript code evaluation
    /// In case of invalidity of the script, the instance is created with default empty values
    /// - Parameters:
    ///     - jsonArgs: array with valid json strings, that will be passed in the same order as arguments in the `script`
    ///     - script: the script that will have as input the `jsonArgs` and handles the convertion
    /// - Throws: if decoding fails
    static func initialize(from jsonArgs: [String], script: JSScript) throws -> Self {
        let context = JSContext()
        let scriptString = script.rawValue
        let functionName = scriptString.functionName()
        
        context?.evaluateScript(scriptString)
        
        let result = context?.objectForKeyedSubscript(functionName)?.call(withArguments: jsonArgs)?.toString()
        
        guard let data = result?.data(using: .utf8) else {
//            return try defaultValue() /// TODO adjust
            fatalError("failed")
        }
        
        do {
            return try Self.decode(from: data)
        } catch {
            // return try defaultValue()
            fatalError("\(error)")
        }
    }
}

public extension ApodiniMigratorCodable {
    /// Creates an instance of type `Self`, by means of an `ApodiniMigratorEncodable`
    ///
    /// ```swift
    /// // MARK: - Code example
    /// struct Student: Codable {
    ///     let name: String
    ///     let friend: Developer
    /// }
    ///
    /// struct Developer: Codable {
    ///     let id: UUID
    ///     let name: String
    /// }
    /// ```
    /// In order to create a `Student` instance the function would expect
    /// an `arg` and a `script` that are compatible, while javaScript code handles the convertion
    /// ```swift
    /// let arg = Developer(id: UUID(), name: "Swift Developer")
    /// ```
    /// - Note: the `arg` must be first parsed inside the function
    /// ```javascript
    /// function convert(input) {
    ///     let parsedInput = JSON.parse(input)
    ///     return JSON.stringify({ 'name' : "John", 'friend' : parsedInput })
    /// }
    /// ```
    /// Called with `arg` and the javascript string, the function creates a `Student`:
    /// ```swift
    /// let student = Student(name: "John", friend: arg)
    /// ```
    /// - Parameters:
    ///     - arg: `EncodableContainer` that hold the encodable value to be passed as argument in the script
    ///     - script: a valid js script that handles the convertion
    /// - Throws: The function throws if decoding fails
    static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self {
        try initialize(from: [arg.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable, E4: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, arg4: E4, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js(), arg4.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable, E4: ApodiniMigratorEncodable, E5: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, arg4: E4, arg5: E5, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js(), arg4.js(), arg5.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable, E4: ApodiniMigratorEncodable, E5: ApodiniMigratorEncodable, E6: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, arg4: E4, arg5: E5, arg6: E6, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js(), arg4.js(), arg5.js(), arg6.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable, E4: ApodiniMigratorEncodable, E5: ApodiniMigratorEncodable, E6: ApodiniMigratorEncodable, E7: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, arg4: E4, arg5: E5, arg6: E6, arg7: E7, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js(), arg4.js(), arg5.js(), arg6.js(), arg7.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable, E4: ApodiniMigratorEncodable, E5: ApodiniMigratorEncodable, E6: ApodiniMigratorEncodable, E7: ApodiniMigratorEncodable, E8: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, arg4: E4, arg5: E5, arg6: E6, arg7: E7, arg8: E8, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js(), arg4.js(), arg5.js(), arg6.js(), arg7.js(), arg8.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable, E4: ApodiniMigratorEncodable, E5: ApodiniMigratorEncodable, E6: ApodiniMigratorEncodable, E7: ApodiniMigratorEncodable, E8: ApodiniMigratorEncodable, E9: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, arg4: E4, arg5: E5, arg6: E6, arg7: E7, arg8: E8, arg9: E9, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js(), arg4.js(), arg5.js(), arg6.js(), arg7.js(), arg8.js(), arg9.js()], script: script)
    }
    
    /// Creates an instance of type `Self`, by means of the `value` properties of `argX`
    /// - Note: See documentation for the single argument function:
    /// ```swift
    /// static func fromValue<E: ApodiniMigratorEncodable>(_ arg: E, script: JSScript) throws -> Self
    /// ```
    static func fromValues<E1: ApodiniMigratorEncodable, E2: ApodiniMigratorEncodable, E3: ApodiniMigratorEncodable, E4: ApodiniMigratorEncodable, E5: ApodiniMigratorEncodable, E6: ApodiniMigratorEncodable, E7: ApodiniMigratorEncodable, E8: ApodiniMigratorEncodable, E9: ApodiniMigratorEncodable, E10: ApodiniMigratorEncodable>(_ arg1: E1, _ arg2: E2, _ arg3: E3, arg4: E4, arg5: E5, arg6: E6, arg7: E7, arg8: E8, arg9: E9, arg10: E10, script: JSScript) throws -> Self {
        try initialize(from: [arg1.js(), arg2.js(), arg3.js(), arg4.js(), arg5.js(), arg6.js(), arg7.js(), arg8.js(), arg9.js(), arg10.js()], script: script)
    }
}

extension ApodiniMigratorEncodable {
    func js() -> String {
        let data = (try? Self.encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}

fileprivate extension String {
    /// A function to be applied on js scripts to retrieve the name of the function
    func functionName() -> String {
        let dropFunction = without("function ")
        
        if let idx = dropFunction.firstIndex(of: "(") {
            return String(dropFunction[dropFunction.startIndex ..< idx])
        }
        return self // the invalidity of the script is handled by creating defaultValue for Decodable type
    }
    
    /// A function to be applied on js scripts to retrieve the names of the input arguments
    func args() -> [String] {
        if
            let openingBracketIndex = firstIndex(of: "("),
            let closingBracketIndex = firstIndex(of: ")")
        {
            guard openingBracketIndex <= closingBracketIndex else {
                return []
            }
            
            let args = String(self[openingBracketIndex ..< closingBracketIndex].dropFirst())
            return args.split(string: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        return []
    }
}
// swiftlint:enable line_length function_parameter_count
