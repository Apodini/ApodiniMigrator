//
//  DateFormatter+Extensions.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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
}
