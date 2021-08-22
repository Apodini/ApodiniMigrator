//
//  MigrationGuide.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Migration guide
public struct MigrationGuide: Codable {
    /// A default summary
    static let defaultSummary = "A summary of what changed between versions"
    
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
    /// The service type the the content of the migration guide corresponds to
    public let serviceType: ServiceType
    /// The specification type
    public let specificationType: SpecificationType
    /// Id of the old document from which the migration guide was generated
    public let id: UUID?
    /// Old version
    public let from: Version
    /// New version
    public let to: Version
    /// Configuration used for comparison
    public let compareConfiguration: CompareConfiguration?
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
    public init(for lhs: Document, rhs: Document, compareConfiguration: CompareConfiguration = .default) {
        let changeContextNode = ChangeContextNode(compareConfiguration: compareConfiguration)
        
        let documentsComparator = DocumentComparator(
            lhs: lhs,
            rhs: rhs,
            changes: changeContextNode,
            configuration: rhs.metaData.encoderConfiguration
        )
        
        // Triggers the compare logic for all elements of both documents, and registers the changes in changeContextNode
        documentsComparator.compare()
        
        self.init(
            summary: Self.defaultSummary,
            serviceType: .rest,
            specificationType: .apodini,
            id: lhs.id,
            from: lhs.metaData.version,
            to: rhs.metaData.version,
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
        try .from(lhsDocumentPath.asPath, rhsDocumentPath.asPath, compareConfiguration: compareConfiguration)
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
