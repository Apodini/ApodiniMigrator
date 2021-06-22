//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
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
        case from
        case to
        case compareConfiguration = "compare-config"
        case changeContainer = "changes"
        case scripts
        case jsonValues = "json-values"
    }
    
    /// A textual description of the migration guide
    public let summary: String
    /// The service type the the content of the migration guide corresponds to
    public let serviceType: ServiceType
    /// The specification type
    public let specificationType: SpecificationType
    /// Old version
    public let from: Version
    /// New version
    public let to: Version
    /// Configuration used for comparison
    public let compareConfiguration: CompareConfiguration?
    /// Private change container that holds, encodes and decodes the changes
    private let changeContainer: ChangeContainer
    /// List of changes in the Migration Guide
    public var changes: [Change] {
        changeContainer.changes
    }
    /// Dictionary holding all registered convert scripts which are referenced from change objects
    public var scripts: [Int: JSScript]
    /// Dictionary holding all registered json values which are referenced from change objects
    public var jsonValues: [Int: JSONValue]
    
    /// A util property that serves to distribute changes to the elements that those belong to
    public var changeFilter: ChangeFilter {
        .init(self)
    }
    
    /// An empty migration guide with no changes
    public static var empty: MigrationGuide {
        .init(
            summary: Self.defaultSummary,
            serviceType: .rest,
            specificationType: .apodini,
            from: .default,
            to: .default,
            compareConfiguration: nil,
            changeContainer: .init(),
            scripts: [:],
            jsonValues: [:]
        )
    }
    
    /// Internal initializer of the Migration Guide
    init(
        summary: String,
        serviceType: ServiceType,
        specificationType: SpecificationType,
        from: Version,
        to: Version,
        compareConfiguration: CompareConfiguration?,
        changeContainer: ChangeContainer,
        scripts: [Int: JSScript],
        jsonValues: [Int: JSONValue]
    ) {
        self.summary = summary
        self.serviceType = serviceType
        self.specificationType = specificationType
        self.from = from
        self.to = to
        self.changeContainer = changeContainer
        self.compareConfiguration = compareConfiguration
        self.scripts = scripts
        self.jsonValues = jsonValues
    }
    
    /// Initializes the Migration Guide out of two Documents. Documents get compared
    /// and the changes can be accessed via `changes` of the new Migration Guide instance
    public init(for lhs: Document, rhs: Document, compareConfiguration: CompareConfiguration = .default) {
        let changeContainer = ChangeContainer(compareConfiguration: compareConfiguration)
        
        let documentsComparator = DocumentComparator(
            lhs: lhs,
            rhs: rhs,
            changes: changeContainer,
            configuration: rhs.metaData.encoderConfiguration
        )
        
        // Triggers the compare logic for all elements of both documents, and registers the changes in changeContainer
        documentsComparator.compare()
        
        self.init(
            summary: Self.defaultSummary,
            serviceType: .rest,
            specificationType: .apodini,
            from: lhs.metaData.version,
            to: rhs.metaData.version,
            compareConfiguration: changeContainer.compareConfiguration,
            changeContainer: changeContainer,
            scripts: changeContainer.scripts,
            jsonValues: changeContainer.jsonValues
        )
    }
    
    public static func from(_ lhsDocumentPath: Path, _ rhsDocumentPath: Path, compareConfiguration: CompareConfiguration = .default) throws -> MigrationGuide {
        .init(for: try .decode(from: lhsDocumentPath), rhs: try .decode(from: rhsDocumentPath), compareConfiguration: compareConfiguration)
    }
    
    public static func from(_ lhsDocumentPath: String, _ rhsDocumentPath: String, compareConfiguration: CompareConfiguration = .default) throws -> MigrationGuide {
        .init(for: try .decode(from: Path(lhsDocumentPath)), rhs: try .decode(from: Path(rhsDocumentPath)), compareConfiguration: compareConfiguration)
    }
}

extension MigrationGuide: Equatable {
    public static func == (lhs: MigrationGuide, rhs: MigrationGuide) -> Bool {
        var mutableLhs = lhs
        var mutableRhs = rhs
        mutableLhs.scripts = [:]
        mutableLhs.jsonValues = [:]
        
        mutableRhs.scripts = [:]
        mutableRhs.jsonValues = [:]
        
        return mutableLhs.json == mutableRhs.json && lhs.scripts == rhs.scripts && lhs.jsonValues == rhs.jsonValues
    }
    
}
