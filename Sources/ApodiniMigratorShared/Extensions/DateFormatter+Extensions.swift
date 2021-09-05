//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum CustomDateFormat: String {
    /// Date format, e.g. 01.02.2021
    case date = "dd.MM.yy"
    /// Year of the date, e.g 2021
    case year = "yyyy"
}

public extension Date {
    /// String representation of self as defined by `format`
    func string(_ format: CustomDateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
    
    /// Returns a date from the given components
    static func makeDate(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components) ?? Date()
    }
    
    /// Date used for file header comment of test files
    static var testsDate: Date {
        .makeDate(year: 2020, month: 8, day: 15)
    }
}
