import Foundation

public enum CustomDateFormat: String {
    case date = "dd.MM.yyyy"
    case year = "yyyy"
}

public extension DateFormatter {
    static var iSO8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter
    }()
}

public extension Date {
    func string(_ format: CustomDateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
