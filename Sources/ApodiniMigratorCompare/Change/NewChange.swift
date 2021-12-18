//
// Created by Andreas Bauer on 07.12.21.
//

import Foundation

public protocol ChangeDeclaration {
    associatedtype Element: DeltaIdentifiable, Codable
    associatedtype Update: Codable
}

public struct EndpointChangeDeclaration: ChangeDeclaration {
    public typealias Element = Endpoint
    public typealias Update = EndpointUpdateChange
}

public enum EndpointUpdateChange: Codable {
    /// type: see ``EndpointIdentifier``
    case identifier(identifier: EndpointIdentifierChange)

    case communicationalPattern(
        from: CommunicationalPattern,
        to: CommunicationalPattern
    )

    case response(
        // TODO checking, if this change is due to name change! (affects provider support!)
        from: TypeInformation,
        to: TypeInformation, // TODO annotate: reference or scalar
        backwardsConversion: Int, // TODO we only have conversion in one direction
        // TODO reanme "migration"
        conversionWarning: String? = nil
    )

    case parameter(
        parameter: ParameterChange
        // TODO anything other than that?
        // TODO this nesting duplicates required and solvable parameters!

    )

    // TODO errors?
}


public struct ParameterChangeDeclaration: ChangeDeclaration {
    public typealias Element = Parameter
    public typealias Update = ParameterUpdateChange
}

public enum ParameterUpdateChange: Codable {
    case parameterType(
        from: ParameterType,
        to: ParameterType
    )

    case necessity(
        from: Necessity,
        to: Necessity,
        necessityMigration: Int?
    )

    case type(
        from: TypeInformation,
        to: TypeInformation, // TODO annotate: reference or scalar
        forwardMigration: Int, // TODO single direction migration?
        conversionWarning: String?
    )
}

public struct EndpointIdentifierChangeDeclaration: ChangeDeclaration {
    public typealias Element = AnyEndpointIdentifier
    public typealias Update = EndpointIdentifierUpdateChange
}

public enum EndpointIdentifierUpdateChange: Codable {
    case value(from: AnyEndpointIdentifier, to: AnyEndpointIdentifier)
}

public struct ModelChangeDeclaration: ChangeDeclaration {
    public typealias Element = TypeInformation
    public typealias Update = ModelUpdateChange
}

public enum ModelUpdateChange: Codable {
    // common
    case rootType(
        from: TypeInformation.RootType,
        to: TypeInformation.RootType,
        newModel: TypeInformation
    )

    // .object
    case property(property: PropertyChange)

    // .enum
    case `case`(case: EnumCaseChange)
    case rawValueType(
        from: TypeInformation, // TODO annotate: reference or scalar
        to: TypeInformation
    )
}

// TODO the decision if this is supported DEPENS on the client library type!!!!
public enum UnsupportedModelChange { // TODO remove
    // TODO we always had a textual description for those?
    case kindChange(
        from: TypeInformation.RootType,
        to: TypeInformation.RootType
    )
    case enumRawValue(
        from: TypeInformation,
        to: TypeInformation
    )
}


public struct PropertyChangeDeclaration: ChangeDeclaration {
    public typealias Element = TypeProperty
    public typealias Update = PropertyUpdateChange
}

public enum PropertyUpdateChange: Codable {
    case necessity(
        from: Necessity,
        to: Necessity,
        necessityMigration: Int
    )

    case type(
        from: TypeInformation,
        to: TypeInformation,
        forwardMigration: Int,
        backwardMigration: Int,
        conversionWarning: String?
    )
}

public struct EnumCaseChangeDeclaration: ChangeDeclaration {
    public typealias Element = EnumCase
    public typealias Update = EnumCaseUpdateChange
}

public enum EnumCaseUpdateChange: Codable {
    case rawValueType(
        from: String,
        to: String
    )
}

public typealias EndpointChange = ChangeEnum<EndpointChangeDeclaration>
public typealias ParameterChange = ChangeEnum<ParameterChangeDeclaration>
public typealias EndpointIdentifierChange = ChangeEnum<EndpointIdentifierChangeDeclaration>
public typealias ModelChange = ChangeEnum<ModelChangeDeclaration>
public typealias PropertyChange = ChangeEnum<PropertyChangeDeclaration>
public typealias EnumCaseChange = ChangeEnum<EnumCaseChangeDeclaration>

public protocol AnyChange {
    associatedtype Definition: ChangeDeclaration

    var id: DeltaIdentifier { get }
    var type: NewChangeType { get }

    var breaking: Bool { get }
    var solvable: Bool { get }
}

fileprivate extension AnyChange {
    func typed() -> ChangeEnum<Definition> {
        guard let change = self as? ChangeEnum<Definition> else {
            fatalError("Encountered `AnyChange` which isn't of expected type `ChangeEnum`!")
        }
        return change
    }
}

public enum NewChangeType: String, Codable { // TODO rename once migrated
    case idChange
    case addition
    case removal
    case update
}

public enum ChangeEnum<Definition: ChangeDeclaration>: AnyChange {
    // TODO provider support, addition/deletion pairs be treated as rename
    //   - update change be treated as deletion + addition

    /// TODO only present if `allowEndpointIdentifierUpdate` is enabled!
    case idChange(
        from: DeltaIdentifier,
        to: DeltaIdentifier,
        similarity: Double?, // TODO check why these are all optionals?
        breaking: Bool = false,
        solvable: Bool = true
        // TODO also a provider support thingy?
    )

    case addition(
        id: DeltaIdentifier, // TODO removable, included in element!
        added: Definition.Element,
        defaultValue: Int? = nil,
        breaking: Bool = false,
        solvable: Bool = true
        // TODO addition provider support
    )

    /// Describes a change where the element was completely removed.
    ///
    /// removed: Optional a description of the element which was removed.
    ///     Typically the based element is still in the original interface description document.
    case removal(
        id: DeltaIdentifier, // TODO this would be duplicate if below field is required!
        removed: Definition.Element? = nil,
        fallbackValue: Int? = nil,
        breaking: Bool = true,
        solvable: Bool = false
        // TODO addition provider support
    )

    case update(
        id: DeltaIdentifier,
        updated: Definition.Update,
        breaking: Bool = true,
        solvable: Bool = true
        // TODO those are not encoded if the Update VALUE already contains those(?)
    )

    public var id: DeltaIdentifier {
        switch self {
        case let .idChange(from, _, _, _, _):
            return from
        case let .addition(id, _, _, _, _):
            return id
        case let .removal(id, _, _, _, _):
            return id
        case let .update(id, _, _, _):
            return id
        }
    }

    public var breaking: Bool {
        switch self {
        case let .idChange(_, _, _, breaking, _):
            return breaking
        case let .addition(_, _, _, breaking, _):
            return breaking
        case let .removal(_, _, _, breaking, _):
            return breaking
        case let .update(_, _, breaking, _):
            return breaking
        }
    }

    public var solvable: Bool {
        switch self {
        case let .idChange(_, _, _, _, solvable):
            return solvable
        case let .addition(_, _, _, _, solvable):
            return solvable
        case let .removal(_, _, _, _, solvable):
            return solvable
        case let .update(_, _, _, solvable):
            return solvable
        }
    }
}

// MARK: IdChange
public extension ChangeEnum {
    struct IdentifierChange {
        public let from: DeltaIdentifier
        public let to: DeltaIdentifier
        public let similarity: Double?
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledIdentifierChange: IdentifierChange? {
        guard case let .idChange(from, to, similarity, breaking, solvable) = self else {
            return nil
        }
        return IdentifierChange(from: from, to: to, similarity: similarity, breaking: breaking, solvable: solvable)
    }
}

// MARK: AdditionChange
public extension ChangeEnum {
    struct AdditionChange {
        public let id: DeltaIdentifier
        public let added: Definition.Element
        public let defaultValue: Int?
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledAdditionChange: AdditionChange? {
        guard case let .addition(id, added, defaultValue, breaking, solvable) = self else {
            return nil
        }
        return AdditionChange(id: id, added: added, defaultValue: defaultValue, breaking: breaking, solvable: solvable)
    }
}

// MARK: RemovalChange
public extension ChangeEnum {
    struct RemovalChange {
        public let id: DeltaIdentifier
        public let removed: Definition.Element?
        public let fallbackValue: Int?
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledRemovalChange: RemovalChange? {
        guard case let .removal(id, removed, fallbackValue, breaking, solvable) = self else {
            return nil
        }
        return RemovalChange(id: id, removed: removed, fallbackValue: fallbackValue, breaking: breaking, solvable: solvable)
    }
}

// MARK: UpdateChange
public extension ChangeEnum {
    struct UpdateChange {
        public let id: DeltaIdentifier
        public let updated: Definition.Update
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledUpdateChange: UpdateChange? {
        guard case let .update(id, updated, breaking, solvable) = self else {
            return nil
        }
        return UpdateChange(id: id, updated: updated, breaking: breaking, solvable: solvable)
    }

    init(from model: UpdateChange) { // TODO init for everybody
        self = .update(id: model.id, updated: model.updated, breaking: model.breaking, solvable: model.solvable)
    }
}

// MARK: UnsupportedChange
public struct NewUnsupportedChange<Definition: ChangeDeclaration> {
    public let change: ChangeEnum<Definition>
    public let description: String
}

public extension ChangeEnum {
    func classifyUnsupported(description: String) -> NewUnsupportedChange<Definition> {
        NewUnsupportedChange(change: self, description: description)
    }
}

public extension Array where Element: AnyChange {
    // TODO keep for anything?
    internal func genericFilter<Result>(for type: NewChangeType, map: KeyPath<ChangeEnum<Element.Definition>, Result>) -> [Result] {
        self
            .filter({ $0.type == type })
            .map { $0.typed()[keyPath: map] }
    }

    // TODO similar thing for the models? (e.g. EncodingMethod, DecodingMethod ...)
    func of(base element: Element.Definition.Element) -> [Element] {
        self.filter { $0.id == element.deltaIdentifier }
    }
}

// MARK: ChangeType
extension ChangeEnum {
    public var type: NewChangeType {
        switch self {
        case .idChange:
            return .idChange
        case .addition:
            return .addition
        case .removal:
            return .removal
        case .update:
            return .update
        }
    }
}

// MARK: Codable
extension ChangeEnum: Codable {
    private enum CodingKeys: String, CodingKey {
        case type

        case id
        case breaking
        case solvable

        case from
        case to
        case similarity

        case added
        case defaultValue

        case removed
        case fallbackValue

        case updated

        // TODO provider support
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(NewChangeType.self, forKey: .type)

        switch type {
        case .idChange:
            self = .idChange(
                from: try container.decode(DeltaIdentifier.self, forKey: .from),
                to: try container.decode(DeltaIdentifier.self, forKey: .to),
                similarity: try container.decodeIfPresent(Double.self, forKey: .similarity),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
            )
        case .addition:
            self = .addition(
                id: try container.decode(DeltaIdentifier.self, forKey: .id),
                added: try container.decode(Definition.Element.self, forKey: .added),
                defaultValue: try container.decodeIfPresent(Int.self, forKey: .defaultValue),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
            )
        case .removal:
            self = .removal(
                id: try container.decode(DeltaIdentifier.self, forKey: .id),
                removed: try container.decodeIfPresent(Definition.Element.self, forKey: .removed),
                fallbackValue: try container.decodeIfPresent(Int.self, forKey: .fallbackValue),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
            )
        case .update:
            self = .update(
                id: try container.decode(DeltaIdentifier.self, forKey: .id),
                updated: try container.decode(Definition.Update.self, forKey: .updated),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .idChange(from, to, similarity, breaking, solvable):
            try container.encode(NewChangeType.idChange, forKey: .type)

            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encodeIfPresent(similarity, forKey: .similarity)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        case let .addition(id, added, defaultValue, breaking, solvable):
            try container.encode(NewChangeType.addition, forKey: .type)

            try container.encode(id, forKey: .id)
            try container.encode(added, forKey: .added)
            try container.encodeIfPresent(defaultValue, forKey: .added)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        case let .removal(id, removed, fallbackValue, breaking, solvable):
            try container.encode(NewChangeType.removal, forKey: .type)

            try container.encode(id, forKey: .id)
            try container.encodeIfPresent(removed, forKey: .removed)
            try container.encodeIfPresent(fallbackValue, forKey: .fallbackValue)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        case let .update(id, updated, breaking, solvable):
            // TODO do not encode breaking/solvable if nested update?
            try container.encode(NewChangeType.update, forKey: .type)

            try container.encode(id, forKey: .id)
            try container.encode(updated, forKey: .updated)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        }
    }
}
