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
        case serviceType = "service-type"
        case specificationType = "api-spec"
        case id = "document-id"
        case from
        case to
        case compareConfiguration = "compare-config"
        case changeContextNode = "changes"
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
    public let compareConfiguration: CompareConfiguration? // TODO this is imporant!
    /// Private change context node that holds, encodes and decodes the changes
    private let changeContextNode: ChangeContextNode
    /// List of changes in the Migration Guide
    public var changes: [Change] {
        changeContextNode.changes
    }
    /// Dictionary holding all registered convert scripts which are referenced from change objects
    public var scripts: [Int: JSScript]
    /// Dictionary holding all registered json values which are referenced from change objects
    public var jsonValues: [Int: JSONValue]
    
    /// A property that holds json representation of models that had a breaking change on their properties, e.g. rename, addition, deletion or property type change.
    /// This property is used for test cases in the client application
    public var objectJSONs: [String: JSONValue]
    
    /// An empty migration guide with no changes
    public static var empty: MigrationGuide {
        .init(
            summary: Self.defaultSummary,
            serviceType: .rest,
            specificationType: .apodini,
            id: nil,
            from: .default,
            to: .default,
            compareConfiguration: nil,
            changeContextNode: .init()
        )
    }
    
    /// Internal initializer of the Migration Guide
    init(
        summary: String,
        serviceType: ServiceType,
        specificationType: SpecificationType,
        id: UUID?,
        from: Version,
        to: Version,
        compareConfiguration: CompareConfiguration?,
        changeContextNode: ChangeContextNode
    ) {
        self.summary = summary
        self.serviceType = serviceType
        self.specificationType = specificationType
        self.id = id
        self.from = from
        self.to = to
        self.changeContextNode = changeContextNode
        self.compareConfiguration = compareConfiguration
        self.scripts = changeContextNode.scripts
        self.jsonValues = changeContextNode.jsonValues
        self.objectJSONs = changeContextNode.objectJSONs
    }
    
    /// Initializes the Migration Guide out of two Documents. Documents get compared
    /// and the changes can be accessed via `changes` of the new Migration Guide instance
    public init(for lhs: APIDocument, rhs: APIDocument, compareConfiguration: CompareConfiguration = .default) {
        let changeContextNode = ChangeContextNode(compareConfiguration: compareConfiguration)
        
        let documentsComparator = DocumentComparator(
            lhs: lhs,
            rhs: rhs,
            changes: changeContextNode,
            configuration: .default // TODO make this configurable
        )
        
        // Triggers the compare logic for all elements of both documents, and registers the changes in changeContextNode
        documentsComparator.compare()
        
        self.init(
            summary: Self.defaultSummary,
            serviceType: .rest,
            specificationType: .apodini,
            id: lhs.id,
            from: lhs.serviceInformation.version,
            to: rhs.serviceInformation.version,
            compareConfiguration: changeContextNode.compareConfiguration,
            changeContextNode: changeContextNode
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
        mutableLhs.scripts = [:]
        mutableLhs.jsonValues = [:]
        mutableLhs.objectJSONs = [:]
        
        mutableRhs.scripts = [:]
        mutableRhs.jsonValues = [:]
        mutableRhs.objectJSONs = [:]
        
        return mutableLhs.json == mutableRhs.json
            && lhs.scripts == rhs.scripts
            && lhs.jsonValues == rhs.jsonValues
            && lhs.objectJSONs == rhs.objectJSONs
    }
}
