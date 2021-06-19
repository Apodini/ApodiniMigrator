//
//  File.swift
//  
//
//  Created by Eldi Cano on 19.06.21.
//

import Foundation



struct JSPrimitiveTypeConvertFunction: Value {
    
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case from
        case to
        case convertFromTo = "from-to-convert"
        case convertToFrom = "to-from-convert"
    }
    
    let from: PrimitiveType
    let to: PrimitiveType
    let convertFromTo: JSScript
    let convertToFrom: JSScript
    
    init(from: PrimitiveType, to: PrimitiveType, convertFromTo: String, convertToFrom: String) {
        self.from = from
        self.to = to
        self.convertFromTo = .init(convertFromTo)
        self.convertToFrom = .init(convertToFrom)
    }
    
    init(fromType: ScalarType, toType: ScalarType, convertFromTo: String, convertToFrom: String) {
        self.from = fromType.representation
        self.to = toType.representation
        self.convertFromTo = .init(convertFromTo)
        self.convertToFrom = .init(convertToFrom)
    }
    
    func sameCombination(with rhs: JSPrimitiveTypeConvertFunction) -> Bool {
        [from.scalarType, to.scalarType].equalsIgnoringOrder(to: [rhs.from.scalarType, rhs.to.scalarType])
    }
    
    static func identity(for scalarType: ScalarType) -> JSPrimitiveTypeConvertFunction {
        return .init(from: scalarType.representation, to: scalarType.representation, convertFromTo: identityConvert, convertToFrom: identityConvert)
    }
    
    static var identities: [JSPrimitiveTypeConvertFunction] {
        ScalarType.allCases.map { JSPrimitiveTypeConvertFunction.identity(for: $0) }
    }

    private static var identityConvert: String {
        """
        function convert(input) {
            return JSON.stringify(JSON.parse(input))
        }
        """
    }
    
    static var boolString: JSPrimitiveTypeConvertFunction {
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
    
    static var boolNumber: JSPrimitiveTypeConvertFunction {
        let convertBoolToNumber =
        """
        function convert(bool) {
            let parsed = JSON.parse(bool)
            return JSON.stringify(parsed ? 1 : 0)
        }
        """
        let convertNumberToBool =
        """
        function convert(string) {
            let parsed = JSON.parse(string)
            return JSON.stringify(parsed == 1 ? true : false)
        }
        """
        return .init(fromType: .bool, toType: .number, convertFromTo: convertBoolToNumber, convertToFrom: convertNumberToBool)
    }
    
    static var boolUnsignedNumber: JSPrimitiveTypeConvertFunction {
        .init(fromType: .bool, toType: .unsignedNumber, convertFromTo: boolNumber.convertFromTo.rawValue, convertToFrom: boolNumber.convertToFrom.rawValue)
    }
    
    static var boolFloat: JSPrimitiveTypeConvertFunction {
        .init(fromType: .bool, toType: .float, convertFromTo: boolNumber.convertFromTo.rawValue, convertToFrom: boolNumber.convertToFrom.rawValue)
    }
    
    static var stringNumber: JSPrimitiveTypeConvertFunction {
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
        return .init(fromType: .string, toType: .number, convertFromTo: convertStringToNumber, convertToFrom: convertNumberToString)
    }
    
    static var stringUnsignednumber: JSPrimitiveTypeConvertFunction {
        .init(fromType: .string, toType: .unsignedNumber, convertFromTo: stringNumber.convertFromTo.rawValue, convertToFrom: stringNumber.convertToFrom.rawValue)
    }
    
    static var stringFloat: JSPrimitiveTypeConvertFunction {
        let convertStringToFloat =
        """
        function convert(string) {
            let parsed = parseFloat(JSON.parse(string))
            return JSON.stringify(isNaN(parsed) ? 0 : parsed)
        }
        """
        
        return .init(fromType: .string, toType: .float, convertFromTo: convertStringToFloat, convertToFrom: stringNumber.convertToFrom.rawValue)
    }
    
    static var numberUnsignedNumber: JSPrimitiveTypeConvertFunction {
        let convertNumberToUnsigned =
        """
        function convert(number) {
            let parsed = JSON.parse(number)
            return JSON.stringify((parsed < 0) ? 0 : parsed)
        }
        """
        return .init(fromType: .number, toType: .unsignedNumber, convertFromTo: convertNumberToUnsigned, convertToFrom: identityConvert)
    }
    
    
    static var numberFloat: JSPrimitiveTypeConvertFunction {
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
        return .init(fromType: .number, toType: .float, convertFromTo: numberToFloat, convertToFrom: floatToNumber)
    }
    
    static var unsignedFloat: JSPrimitiveTypeConvertFunction {
        let floatToUnsigned =
        """
        function convert(float) {
            let parsed = JSON.parse(float)
            return JSON.stringify((parsed < 0) ? 0 : Math.round(parsed))
        }
        """
        return .init(fromType: .unsignedNumber, toType: .float, convertFromTo: numberFloat.convertFromTo.rawValue, convertToFrom: floatToUnsigned)
    }
    
    /// add int to uuid, uuid to int
    
    static var defaults: [JSPrimitiveTypeConvertFunction] {
        [
            .init(
                fromType: .null,
                toType: .null,
                convertFromTo: "",
                convertToFrom: ""
            )
        ]
    }
}
