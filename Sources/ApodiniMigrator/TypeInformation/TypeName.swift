import Foundation

public struct TypeName: Value {
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case name, definedIn = "defined-in"
    }
    
    #warning("Include names of generic types as computed properties")
    public let name: String
    public let definedIn: String
    
    public var absoluteName: String {
        definedIn + "/" + name
    }

    public init(_ type: Any.Type) {
        var components = String(reflecting: type).split(character: ".")
        let name = String(describing: type)
        
        if components.last == name {
            components = components.dropLast()
        }
        
        self.init(name: name, definedIn: components.joined(separator: "/"))
    }

    public init(name: String, definedIn: String) {
        self.name = name.without("<").without(">").replacingOccurrences(of: ", ", with: "and")
        self.definedIn = definedIn
    }
    
    public init(name: String) {
        self.init(name: name, definedIn: name)
    }
}

extension TypeName: Comparable {
    public static func < (lhs: TypeName, rhs: TypeName) -> Bool {
        lhs.name < rhs.name
    }
}
