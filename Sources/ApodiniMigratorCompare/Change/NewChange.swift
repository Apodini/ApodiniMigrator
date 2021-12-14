//
// Created by Andreas Bauer on 07.12.21.
//

import Foundation

public protocol ChangeDeclaration {
    associatedtype Element: DeltaIdentifiable
    associatedtype Update
}

public struct EndpointChangeDeclaration: ChangeDeclaration {
    public typealias Element = Endpoint
    public typealias Update = EndpointUpdateChange
}

public enum EndpointUpdateChange {
    /// type: see ``EndpointIdentifier``
    case identifier(identifier: EndpointIdentifierChange)

    case communicationalPattern(
        from: CommunicationalPattern,
        to: CommunicationalPattern
        // TODO any kind of conversion?
    )

    // TODO we only have conversion in one direction!
    case response( // TODO this shall only be used if the Type completly CHANGED! which
                   //  is different to a renamed type (potentially having some other changes!)
                   //  this would affect the ProviderSupport resolving step as well!
                   // TODO do we consider name changes at all (yes via `allowTypeRename` only)?
                   //   how does a `.update name change on typeInfo manifest here?)
                   from: TypeInformation,
                   to: TypeInformation, // TODO annotate reference or scalar
                   backwardsConversion: Int,
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

public enum ParameterUpdateChange {
    case parameterType(
        from: ParameterType,
        to: ParameterType
    )

    case necessity(
        from: Necessity,
        to: Necessity,
        necessityMigration: Int
    )

    case type(
        from: TypeInformation,
        to: TypeInformation, // TODO annotate reference or scalar
        forwardMigration: Int, // TODO single direction migration?
        conversionWarning: String?
    )
}

public struct EndpointIdentifierChangeDeclaration: ChangeDeclaration {
    public typealias Element = AnyEndpointIdentifier
    public typealias Update = EndpointIdentifierUpdateChange
}

public enum EndpointIdentifierUpdateChange {
    case value(from: String, to: String)
}

public struct ModelChangeDeclaration: ChangeDeclaration {
    public typealias Element = TypeInformation
    public typealias Update = ModelUpdateChange
}

public enum ModelUpdateChange {
    // TODO case unsupported(change: UnsupportedModelChange)
    case rootType(from: TypeInformation.RootType, to: TypeInformation.RootType) // TODO we need the whole type description!

    // object
    case property(property: PropertyChange)

    // enum
    case `case`(case: EnumCaseChange)
    case rawValueType(
        from: TypeInformation, // TODO annotate reference or scalar
        to: TypeInformation
    )
    // TODO case rawValue(value:)
}

// TODO the decision if this is supported DEPENS on the client library type!!!!
public enum UnsupportedModelChange {
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

public enum PropertyUpdateChange {
    case necessity(
        from: Necessity,
        to: Necessity,
        necessityMigration: Int
    )

    case type(
        from: TypeInformation,
        to: TypeInformation,
        forwardMigration: Int, // TODO single direction migration?
        backwardMigration: Int,
        conversionWarning: String?
    )
}

public struct EnumCaseChangeDeclaration: ChangeDeclaration {
    public typealias Element = EnumCase
    public typealias Update = EnumCaseUpdateChange
}

public enum EnumCaseUpdateChange {
    case rawValueType(
        from: String,
        to: String
    )
}

public struct ServiceInformationChangeDeclaration: ChangeDeclaration {
    public typealias Element = ServiceInformation
    public typealias Update = ServiceInformationUpdateChange
}

public enum ServiceInformationUpdateChange { // TODO Codable
    case version(
        from: Version,
        to: Version
    )

    case http(
        from: HTTPInformation,
        to: HTTPInformation
    )

    case exporter(
        exporter: ApodiniExporterType,
        from: ExporterConfiguration, // TODO more granular? (e.g. encode/decode configuration?)
        to: ExporterConfiguration
    )
}

public typealias EndpointChange = ChangeEnum<EndpointChangeDeclaration>
public typealias ParameterChange = ChangeEnum<ParameterChangeDeclaration>
public typealias EndpointIdentifierChange = ChangeEnum<EndpointIdentifierChangeDeclaration>
public typealias ModelChange = ChangeEnum<ModelChangeDeclaration>
public typealias PropertyChange = ChangeEnum<PropertyChangeDeclaration>
public typealias EnumCaseChange = ChangeEnum<EnumCaseChangeDeclaration>
public typealias ServiceInformationChange = ChangeEnum<ServiceInformationChangeDeclaration>

// TODO MigrationGuide should validate (after checking provider support [is this relevant?]);
//   that for a single DeltaIdentifier, there either exists a addition, deletion or
//   one or multiple updates.
public enum ChangeEnum<Type: ChangeDeclaration> {
    // TODO provider support, addition/deletion pairs be treated as rename
    //   - update change be treated as deletion + addition

    // TODO ids are always old ids, can be used to match ids (if enabled)
    /// TODO only present if `allowEndpointIdentifierUpdate` is enabled!
    case idChange(
        from: DeltaIdentifier,
        to: DeltaIdentifier,
        similarity: Double?, // TODO check why these are all optionals?
        breaking: Bool = false,
        solvable: Bool = true
        // TODO also a provider support thingy?
    )
    // TODO this is only a specialty for the Endpoint which has a dedicated HandlerIdentifier!!!
    // TODO can we make this NEVER able, e.g. for Identifier changes?
    // TODO breaking, solvable, providerSupport(?)

    case addition(
        id: DeltaIdentifier, // TODO removable, included in element!
        added: Type.Element,
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
        id: DeltaIdentifier,
        removed: Type.Element? = nil, // TODO i would go for a always include but control encode via option!
        fallbackValue: Int? = nil,
        breaking: Bool = true,
        solvable: Bool = false
        // TODO addition provider support
    )

    case update(
        id: DeltaIdentifier,
        updated: Type.Update, // TODO name "content", "nested"
        breaking: Bool = true,
        solvable: Bool = true
        // TODO those are not encoded if the Update VALUE already contains those(?)
        //   maybe we can do a flat encoding?

        // TODO nested provider support
        // TODO update provider support??? (solved in idChange?)
    )
    // TODO unsupported update?

    // TODO remove those accessors?
    var isIdChange: Bool {
        if case .idChange = self {
            return true
        }
        return false
    }

    var isAddition: Bool {
        if case .addition = self {
            return true
        }
        return false
    }

    var isRemoval: Bool {
        if case .removal = self {
            return true
        }
        return false
    }

    var isUpdate: Bool {
        if case .update = self {
            return true
        }
        return false
    }

    var id: DeltaIdentifier {
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

    var breaking: Bool {
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

    var solvable: Bool {
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
