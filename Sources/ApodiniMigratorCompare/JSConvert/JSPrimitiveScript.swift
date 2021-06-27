//
//  JSPrimitiveScript.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

struct JSPrimitiveScript: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case from
        case to
        case convertFromTo = "from-to-convert"
        case convertToFrom = "to-from-convert"
    }
    
    /// From primitive type
    let from: PrimitiveType
    /// To primitive type
    let to: PrimitiveType
    /// JScript converting from to to
    let convertFromTo: JSScript
    /// JScript converting to to from
    let convertToFrom: JSScript
    
    /// Initializes a new `JSPrimitiveScript`
    init(from: PrimitiveType, to: PrimitiveType, convertFromTo: String, convertToFrom: String) {
        self.from = from
        self.to = to
        self.convertFromTo = .init(convertFromTo)
        self.convertToFrom = .init(convertToFrom)
    }
    
    /// Initializes a new `JSPrimitiveScript`
    init(fromType: ScalarType, toType: ScalarType, convertFromTo: String, convertToFrom: String) {
        self.from = fromType.representation
        self.to = toType.representation
        self.convertFromTo = .init(convertFromTo)
        self.convertToFrom = .init(convertToFrom)
    }
    
    static func script(from lhs: PrimitiveType, to rhs: PrimitiveType) -> JSPrimitiveScript {
        if lhs == rhs || lhs.scalarType == rhs.scalarType {
            return .init(from: lhs, to: rhs, convertFromTo: identityConvert, convertToFrom: identityConvert)
        }
        
        if [lhs, rhs].contains(.uuid) {
            let lhsIsUUID = lhs == .uuid
            let uuidConvert = JSPrimitiveScript.uuid(to: lhsIsUUID ? rhs : lhs)
            let convertFromTo = lhsIsUUID ? uuidConvert.convertFromTo : uuidConvert.convertToFrom
            let convertToFrom = lhsIsUUID ? uuidConvert.convertToFrom : uuidConvert.convertFromTo
            return .init(from: lhs, to: rhs, convertFromTo: convertFromTo.rawValue, convertToFrom: convertToFrom.rawValue)
        }
        
        var convertFromTo: JSScript = ""
        var convertToFrom: JSScript = ""
        
        if let combination = Self.combination(for: lhs, rhs: rhs) {
            let lhsIsFrom = combination.from.scalarType == lhs.scalarType
            convertFromTo = lhsIsFrom ? combination.convertFromTo : combination.convertToFrom
            convertToFrom = lhsIsFrom ? combination.convertToFrom : combination.convertFromTo
        }
        
        return .init(
            from: lhs,
            to: rhs,
            convertFromTo: convertFromTo.rawValue,
            convertToFrom: convertToFrom.rawValue
        )
    }
    
    static func allCombinations() -> [JSPrimitiveScript] {
        var output: [JSPrimitiveScript] = []
        let nonNulls = PrimitiveType.allCases.filter { $0 != .null }
        
        for primitiveType in nonNulls {
            nonNulls.forEach { primitive in
                if primitiveType != primitive {
                    output.append(.script(from: primitiveType, to: primitive))
                }
            }
        }
        
        return output.unique()
    }
}

// MARK: - Combinations
extension JSPrimitiveScript {
    static func combination(for lhs: PrimitiveType, rhs: PrimitiveType) -> JSPrimitiveScript? {
        defaults.first {
            ($0.from.scalarType == lhs.scalarType && $0.to.scalarType == rhs.scalarType)
                || ($0.from.scalarType == rhs.scalarType && $0.to.scalarType == lhs.scalarType)
        }
    }
    
    static var defaults: [JSPrimitiveScript] {
        [
            .boolString,
            .boolNumber,
            .boolUnsignedNumber,
            .boolFloat,
            .stringNumber,
            .stringUnsignedNumber,
            .stringFloat,
            .numberUnsignedNumber,
            .numberFloat,
            .unsignedFloat
        ]
    }
    
    static var boolString: JSPrimitiveScript {
        let convertBoolToString =
        """
        function convert(bool) {
            let parsed = JSON.parse(bool)
            return JSON.stringify(parsed ? 'YES' : 'NO')
        }
        """
        let convertStringToBool =
        """
        function convert(string) {
            let parsed = JSON.parse(string)
            return JSON.stringify(parsed == 'YES' ? true : false)
        }
        """
        return .init(from: .bool, to: .string, convertFromTo: convertBoolToString, convertToFrom: convertStringToBool)
    }
    
    static var boolNumber: JSPrimitiveScript {
        let convertBoolToNumber =
        """
        function convert(bool) {
            let parsed = JSON.parse(bool)
            return JSON.stringify(parsed ? 1 : 0)
        }
        """
        let convertNumberToBool =
        """
        function convert(number) {
            let parsed = JSON.parse(number)
            return JSON.stringify(parsed == 1 ? true : false)
        }
        """
        return .init(fromType: .bool, toType: .number, convertFromTo: convertBoolToNumber, convertToFrom: convertNumberToBool)
    }
    
    static var boolUnsignedNumber: JSPrimitiveScript {
        .init(
            fromType: .bool,
            toType: .unsignedNumber,
            convertFromTo: boolNumber.convertFromTo.rawValue,
            convertToFrom: boolNumber.convertToFrom.rawValue
        )
    }
    
    static var boolFloat: JSPrimitiveScript {
        .init(
            fromType: .bool,
            toType: .float,
            convertFromTo: boolNumber.convertFromTo.rawValue,
            convertToFrom: boolNumber.convertToFrom.rawValue
        )
    }
    
    static var stringNumber: JSPrimitiveScript {
        let convertStringToNumber =
        """
        function convert(string) {
            let parsed = parseInt(JSON.parse(string))
            return JSON.stringify(isNaN(parsed) ? 0 : parsed)
        }
        """
        
        let convertNumberToString =
        """
        function convert(number) {
            let parsed = JSON.parse(number)
            return JSON.stringify(parsed.toString())
        }
        """
        return .init(
            fromType: .string,
            toType: .number,
            convertFromTo: convertStringToNumber,
            convertToFrom: convertNumberToString
        )
    }
    
    static var stringUnsignedNumber: JSPrimitiveScript {
        .init(
            fromType: .string,
            toType: .unsignedNumber,
            convertFromTo: stringNumber.convertFromTo.rawValue,
            convertToFrom: stringNumber.convertToFrom.rawValue
        )
    }
    
    static var stringFloat: JSPrimitiveScript {
        let convertStringToFloat =
        """
        function convert(string) {
            let parsed = parseFloat(JSON.parse(string))
            return JSON.stringify(isNaN(parsed) ? 0 : parsed)
        }
        """
        
        return .init(
            fromType: .string,
            toType: .float,
            convertFromTo: convertStringToFloat,
            convertToFrom: stringNumber.convertToFrom.rawValue
        )
    }
    
    static var numberUnsignedNumber: JSPrimitiveScript {
        let convertNumberToUnsigned =
        """
        function convert(number) {
            let parsed = JSON.parse(number)
            return JSON.stringify(Math.max(0, parsed))
        }
        """
        return .init(
            fromType: .number,
            toType: .unsignedNumber,
            convertFromTo: convertNumberToUnsigned,
            convertToFrom: identityConvert
        )
    }
    
    static var numberFloat: JSPrimitiveScript {
        let numberToFloat =
        """
        function convert(int) {
            let parsed = JSON.parse(int)
            return parsed.toFixed(1)
        }
        """
        let floatToNumber =
        """
        function convert(float) {
            let parsed = JSON.parse(float)
            return Math.round(parsed)
        }
        """
        return .init(
            fromType: .number,
            toType: .float,
            convertFromTo: numberToFloat,
            convertToFrom: floatToNumber
        )
    }
    
    static var unsignedFloat: JSPrimitiveScript {
        let floatToUnsigned =
        """
        function convert(float) {
            let parsed = JSON.parse(float)
            return JSON.stringify(Math.max(0, Math.round(parsed)))
        }
        """
        return .init(
            fromType: .unsignedNumber,
            toType: .float,
            convertFromTo: numberFloat.convertFromTo.rawValue,
            convertToFrom: floatToUnsigned
        )
    }
    
    static func identity(for scalarType: ScalarType) -> JSPrimitiveScript {
        .init(from: scalarType.representation, to: scalarType.representation, convertFromTo: identityConvert, convertToFrom: identityConvert)
    }
    
    static var identities: [JSPrimitiveScript] {
        ScalarType.allCases.map { JSPrimitiveScript.identity(for: $0) }
    }

    private static var identityConvert: String {
        """
        function convert(input) {
            return JSON.stringify(JSON.parse(input))
        }
        """
    }
}

// MARK: - UUID
extension JSPrimitiveScript {
    static func stringify(argumentName: String? = nil, with content: String) -> String {
        """
        function convert(\(argumentName ?? "input")) {
            return JSON.stringify(\(content))
        }
        """
    }
    
    static func stringify(to primitiveType: PrimitiveType) -> String {
        """
        function convert(input) {
            return \(primitiveType.stringify)
        }
        """
    }
    
    static func uuid(to primitiveType: PrimitiveType) -> JSPrimitiveScript {
        let scalarType = primitiveType.scalarType
        
        if scalarType == .string {
            return .init(from: .uuid, to: primitiveType, convertFromTo: identityConvert, convertToFrom: identityConvert)
        }
        
        if [.bool, .null].contains(scalarType) {
            return .init(from: .uuid, to: primitiveType, convertFromTo: stringify(to: primitiveType), convertToFrom: stringify(to: .uuid))
        }
        
        let convertNumberToUUID =
        """
        function convert(number) {
            let string = JSON.parse(number).toString().split('.').join('').split('-').join('')
            var output = ""
            var inserted = 0
            let template = "aaaaaaaa-aaaa-2aaa-8aaa-aaaaaaaaaaaa"
            for (let i = 0; i < template.length; i++) {
                let current = template[i]
                if (current == 'a' && inserted < string.length) {
                    output += string[inserted]
                    inserted += 1
                    continue
                }
                output += current
            }
            return JSON.stringify(output)
        }
        """
        let convertUUIDToNumber =
        """
        function convert(uuid) {
          let string = JSON.parse(uuid).toString()
          let skippingIndexes = [8, 13, 14, 18, 19, 23];
          var intString = ""
          for (let i = 0; i < string.length; i++) {
            let current = parseInt(string[i])
            if (skippingIndexes.includes(i) || isNaN(current)) {
              continue
            }
            intString += current.toString()
          }
          return JSON.stringify(parseInt(intString));
        }
        """
        
        return .init(from: .uuid, to: primitiveType, convertFromTo: convertUUIDToNumber, convertToFrom: convertNumberToUUID)
    }
}

extension PrimitiveType {
    var stringify: String {
        "JSON.stringify(\(swiftType.jsonString))"
    }
}
