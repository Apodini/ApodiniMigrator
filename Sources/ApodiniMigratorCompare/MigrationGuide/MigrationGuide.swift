//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct NewMigrationGuide {
    let summary: String
    let id: String // TODO id?

    // TODO version change?

    // TODO service changes
    //  - version?
    //  - HTTPInformation (port, hostname)
    //  - Exporter Configuration (added removed exporters?)
    //    - REST: encoder, decoder configuration!

    // TODO endpoint changes
    //  - self addition
    //  - self removal
    //  - self update:
    //    - identifier:
    //      - operation, commPattern, path                [UPDATE]
    //      - gRPC? (added, removed, change?)             [UPDATE, REMOVE?, ADD?]
    //    - parameter (kind of property change?):
    //      - self addition
    //      - self removal
    //      - self update
    //        - kind/location (leightweight, content, etc)  [UPDATE]  (from, to, id)
    //        - necessity (isn't it also type info)?        [UPDATE]  (from, to, id, typeInfo?)
    //        - TypeInformation                             [UPDATE]  (from ,to, conversion stuff)
    //        - name                                        [UPDATE]
    //    - response type: (migration etc?)

    // TODO object changes
    //  - self addition
    //  - self removal
    //  - self update:
    //    - name?
    //    - property:
    //      - self addition:
    //      - self removal:
    //      - self update:
    //        - name:
    //        - necessity
    //        - TypeInformation
    //
    // TODO enum changes
    //  - self addition
    //  - self removal
    //  - self update:
    //    - rawValue Type: Unsupported Change!
    //    - case:
    //      - self add:
    //      - self remove:
    //      - self update:
    //        - rawValue
    //        - name

    // TODO scripts, json values, objects?,
}

/// Migration guide
public struct MigrationGuide: Codable {
    /// A default summary
    static let defaultSummary = "A summary of what changed between versions" // TODO really needed?
    
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case summary
        case id = "document-id"
        case from
        case to
        case compareConfiguration = "compare-config"
        case serviceChanges
        case modelChanges
        case endpointChanges
        case scripts
        case jsonValues = "json-values"
        case objectJSONs = "updated-json-representations"
    }
    
    /// A textual description of the migration guide
    public let summary: String

    /// Id of the old document from which the migration guide was generated
    public let id: UUID?
    /// Old version
    public let from: Version
    /// New version
    public let to: Version
    /// Configuration used for comparison TODO detailed!
    public let compareConfiguration: CompareConfiguration?
    /// Private change context node that holds, encodes and decodes the changes
    // TODO private let changeContextNode: ChangeContextNode
    /// List of changes in the Migration Guide
    //public var changes: [Change] {
    //    changeContextNode.changes
    //}

    // TODO those are still not encodable!
    public let serviceChanges: [ServiceInformationChange]
    public let modelChanges: [ModelChange]
    public let endpointChanges: [EndpointChange]


    /// Dictionary holding all registered convert scripts which are referenced from change objects
    public let scripts: [Int: JSScript]
    /// Dictionary holding all registered json values which are referenced from change objects
    public let jsonValues: [Int: JSONValue]
    /// A property that holds json representation of models that had a breaking change on their properties, e.g. rename, addition, deletion or property type change.
    /// This property is used for test cases in the client application
    public let objectJSONs: [String: JSONValue]
    
    /// An empty migration guide with no changes
    public static var empty: MigrationGuide {
        .init(
            summary: Self.defaultSummary,
            id: nil,
            from: .default,
            to: .default,
            comparisonContext: ChangeComparisonContext(configuration: nil, latestModels: [])
        )
    }
    
    /// Internal initializer of the Migration Guide
    init(
        summary: String,
        id: UUID?,
        from: Version,
        to: Version,
        comparisonContext: ChangeComparisonContext
    ) {
        self.summary = summary
        self.id = id
        self.from = from
        self.to = to
        // TODO replace with non optional stored property, but encode optional style!
        self.compareConfiguration = comparisonContext.configuration == .default ? nil : comparisonContext.configuration

        self.serviceChanges = comparisonContext.serviceChanges
        self.modelChanges = comparisonContext.modelChanges
        self.endpointChanges = comparisonContext.endpointChanges

        self.scripts = comparisonContext.scripts
        self.jsonValues = comparisonContext.jsonValues
        self.objectJSONs = comparisonContext.objectJSONs
    }
    
    /// Initializes the Migration Guide out of two Documents. Documents get compared
    /// and the changes can be accessed via `changes` of the new Migration Guide instance
    public init(for lhs: APIDocument, rhs: APIDocument, compareConfiguration: CompareConfiguration? = nil) {
        // TODO don't like how all the expensive comparison bootstrapping is but in the init!
        let comparisonContext = ChangeComparisonContext(
            configuration: compareConfiguration,
            latestModels: Array(rhs.types.values)
        )
        
        let documentsComparator = DocumentComparator(lhs: lhs, rhs: rhs)
        // Triggers the compare logic for all elements of both documents, and record the changes in the contex
        documentsComparator.compare(comparisonContext)

        // TODO MigrationGuide should validate (after checking provider support [is this relevant?]);
        //   that for a single DeltaIdentifier, there either exists a addition, deletion or
        //   one or multiple updates.
        //  => tricky as this would need to be nested!
        
        self.init(
            summary: Self.defaultSummary,
            id: lhs.id,
            from: lhs.serviceInformation.version,
            to: rhs.serviceInformation.version,
            comparisonContext: comparisonContext
        )
    }
    
    /// Returns the migration guide by comparing documents at the specified paths
    public static func from(
        _ lhsDocumentPath: Path,
        _ rhsDocumentPath: Path,
        compareConfiguration: CompareConfiguration = .default
    ) throws -> MigrationGuide {
        .init(for: try .decode(from: lhsDocumentPath), rhs: try .decode(from: rhsDocumentPath), compareConfiguration: compareConfiguration)
    }
    
    /// Returns the migration guide by comparing documents at the specified paths
    public static func from(
        _ lhsDocumentPath: String,
        _ rhsDocumentPath: String,
        compareConfiguration: CompareConfiguration = .default
    ) throws -> MigrationGuide {
        try .from(Path(lhsDocumentPath), Path(rhsDocumentPath), compareConfiguration: compareConfiguration)
    }
}

extension MigrationGuide: Equatable {
    /// :nodoc:
    public static func == (lhs: MigrationGuide, rhs: MigrationGuide) -> Bool {
        var mutableLhs = lhs
        var mutableRhs = rhs
        // TODO equatable is fucked!
        /*mutableLhs.scripts = [:]
        mutableLhs.jsonValues = [:]
        mutableLhs.objectJSONs = [:]
        
        mutableRhs.scripts = [:]
        mutableRhs.jsonValues = [:]
        mutableRhs.objectJSONs = [:]
         */
        return mutableLhs.json == mutableRhs.json
            && lhs.scripts == rhs.scripts
            && lhs.jsonValues == rhs.jsonValues
            && lhs.objectJSONs == rhs.objectJSONs
    }
}
