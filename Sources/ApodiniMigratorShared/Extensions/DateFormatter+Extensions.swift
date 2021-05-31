import Foundation

public enum CustomDateFormat: String {
    /// Date format, e.g. 01.02.2021
    case date = "dd.MM.yyyy"
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
