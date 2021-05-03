import Foundation

struct TypeName: ComparableProperty { // TODO add generics
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case name, definedIn = "defined-in"
    }
    
    let name: String
    let definedIn: String

    init(_ type: Any.Type) {
        var components = String(reflecting: type).split(character: ".")
        let name = String(describing: type)
        
        if components.last == name {
            components = components.dropLast()
        }
        
        self.init(name: name, definedIn: components.joined(separator: "/"))
    }

    init(name: String, definedIn: String) {
        self.name = name
        self.definedIn = definedIn
    }

    init(definedIn: String) {
        self.definedIn = definedIn
        
        if let name = definedIn.split(separator: ".").last {
            self.name = String(name)
        } else {
            name = definedIn
        }
    }
}
