//
// Created by Andreas Bauer on 07.12.21.
//

import Foundation


public enum ServiceInformationChange { // TODO Codable
    // TODO version?
    case http(
        from: HTTPInformation,
        to: HTTPInformation
    )

    case exporter(
        exporter: ApodiniExporterType,
        from: ExporterConfiguration, // TODO more granular? (e.g. encode/decode configuration?)
        to: ExporterConfiguration
    )

    // TODO breaking/ solvable!
}



public protocol ChangeDeclaration {
    associatedtype Element: DeltaIdentifiable // TODO can be removed?

    // TODO those seem to be always Int?
    associatedtype AdditionDefaultValue
    associatedtype RemovalFallbackValue

    associatedtype Update
}

public struct EndpointChangeDeclaration: ChangeDeclaration {
    public typealias Element = Endpoint

    public typealias AdditionDefaultValue = Void // TODO void codable conformance?
    public typealias RemovalFallbackValue = Void

    public typealias Update = EndpointUpdateChange
}

public enum EndpointUpdateChange {
    // TODO identifier string representation enough?
    /// type: see ``EndpointIdentifier``
    case identifier( // TODO might want to consider if we want to support addition/removal?
                     type: String,
                     from: AnyEndpointIdentifier, // TODO generify type?
                     to: AnyEndpointIdentifier
    )

    // TODO we only have conversion in one direction!
    case response( // TODO this shall only be used if the Type completly CHANGED! which
                   //  is different to a renamed type (potentially having some other changes!)
                   //  this would affect the ProviderSupport resolving step as well!
                   // TODO do we consider name changes at all (yes via `allowTypeRename` only)?
                   //   how does a `.update name change on typeInfo manifest here?)
                   from: TypeInformation,
                   to: TypeInformation,
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

    public typealias AdditionDefaultValue = Int // TODO json type int
    public typealias RemovalFallbackValue = Int // TODO actually Void!

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
        to: TypeInformation,
        forwardMigration: Int, // TODO single direction migration?
        conversionWarning: String?
    )
}

public struct ObjectChangeDeclaration: ChangeDeclaration {
    public typealias Element = TypeInformation

    public typealias AdditionDefaultValue = Int // TODO are they (unused i think)??
    public typealias RemovalFallbackValue = Int

    public typealias Update = ObjectUpdateChange
}

public enum ObjectUpdateChange {
    case unsupported(change: UnsupportedModelChange)
    case property(property: PropertyChange)
}



public struct EnumChangeDeclaration: ChangeDeclaration {
    public typealias Element = TypeInformation

    public typealias AdditionDefaultValue = Int // TODO unused I think?
    public typealias RemovalFallbackValue = Int

    public typealias Update = EnumUpdateChange
}

public enum EnumUpdateChange {
    case unsupported(change: UnsupportedModelChange)
    case property(property: PropertyChange)
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

    public typealias AdditionDefaultValue = Int
    public typealias RemovalFallbackValue = Int

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

    public typealias AdditionDefaultValue = Int // TODO not needed!!
    public typealias RemovalFallbackValue = Int

    public typealias Update = EnumCaseUpdateChange


}

public enum EnumCaseUpdateChange {
    case rawValueType(
        from: String,
        to: String
    )
}

public typealias EndpointChange = ChangeEnum<EndpointChangeDeclaration>
public typealias ParameterChange = ChangeEnum<ParameterChangeDeclaration>
public typealias ObjectChange = ChangeEnum<ObjectChangeDeclaration>
public typealias EnumChange = ChangeEnum<EnumChangeDeclaration>
public typealias PropertyChange = ChangeEnum<PropertyChangeDeclaration>
public typealias EnumCaseChange = ChangeEnum<EnumCaseChangeDeclaration>

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
        defaultValue: Type.AdditionDefaultValue? = nil,
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
        fallbackValue: Type.RemovalFallbackValue? = nil,
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
}
