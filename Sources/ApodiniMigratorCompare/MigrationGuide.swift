//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum MigrationGuideDocumentVersion: String, Codable {
    case v1 = "1.0.0"
    case v2 = "2.0.0"
}

/// Migration guide
public struct MigrationGuide {
    /// A default summary
    static let defaultSummary = "A summary of what changed between versions" // TODO really needed?

    /// A textual description of the migration guide
    public let summary: String

    /// Id of the old document from which the migration guide was generated
    public let id: UUID? // TODO why is this optional?
    public let documentVersion: MigrationGuideDocumentVersion
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
        self.documentVersion = .v2
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
            latestModels: Array(rhs.models)
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

extension MigrationGuide: Codable {
    public enum CodingError: Error {
        case unsupportedDocumentVersion(version: String)
    }

    private enum CodingKeys: String, CodingKey {
        case summary
        case id = "document-id"
        case documentVersion = "version"
        case from
        case to
        case compareConfiguration = "compare-config"
        case serviceChanges
        case modelChanges
        case endpointChanges
        case scripts
        case jsonValues = "json-values"
        case objectJSONs = "updated-json-representations"

        // legacy fields
        case changes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);

        let documentVersion: MigrationGuideDocumentVersion
        do {
            try documentVersion = container.decodeIfPresent(MigrationGuideDocumentVersion.self, forKey: .documentVersion) ?? .v1
        } catch {
            // failed to decode APIDocumentVersion, probably because its an unknown version!
            throw CodingError.unsupportedDocumentVersion(version: try container.decode(String.self, forKey: .documentVersion))
        }

        // decode fields which are the same in all versions
        try summary = container.decode(String.self, forKey: .summary)
        try id = container.decodeIfPresent(UUID.self, forKey: .id)
        try from = container.decode(Version.self, forKey: .from)
        try to = container.decode(Version.self, forKey: .to)

        try scripts = container.decode([Int: JSScript].self, forKey: .scripts)
        try jsonValues = container.decode([Int: JSONValue].self, forKey: .jsonValues)
        try objectJSONs = container.decode([String: JSONValue].self, forKey: .objectJSONs)

        switch documentVersion {
        case .v1:
            if let legacyConfiguration = try container.decodeIfPresent(LegacyCompareConfiguration.self, forKey: .compareConfiguration) {
                self.compareConfiguration = CompareConfiguration(from: legacyConfiguration)
            } else {
                self.compareConfiguration = nil
            }

            let changes = try container.decode(LegacyChangeArray.self, forKey: .changes)

            var serviceChanges = [ServiceInformationChange]()
            var modelChanges = [ModelChange]()
            var endpointChanges = [EndpointChange]()

            try changes.migrate(serviceChanges: &serviceChanges, modelChanges: &modelChanges, endpointChanges: &endpointChanges)

            self.serviceChanges = serviceChanges
            self.modelChanges = modelChanges
            self.endpointChanges = endpointChanges
        case .v2:
            try compareConfiguration = container.decodeIfPresent(CompareConfiguration.self, forKey: .compareConfiguration)

            try serviceChanges = container.decodeIfPresentOrInitEmpty([ServiceInformationChange].self, forKey: .serviceChanges)
            try modelChanges = container.decodeIfPresentOrInitEmpty([ModelChange].self, forKey: .modelChanges)
            try endpointChanges = container.decodeIfPresentOrInitEmpty([EndpointChange].self, forKey: .endpointChanges)
        }

        self.documentVersion = .v2
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(summary, forKey: .summary)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(documentVersion, forKey: .documentVersion)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encodeIfPresent(compareConfiguration, forKey: .compareConfiguration)

        try container.encodeIfNotEmpty(serviceChanges, forKey: .serviceChanges)
        try container.encodeIfNotEmpty(modelChanges, forKey: .modelChanges)
        try container.encodeIfNotEmpty(endpointChanges, forKey: .endpointChanges)

        try container.encode(scripts, forKey: .scripts)
        try container.encode(jsonValues, forKey: .jsonValues)
        try container.encode(objectJSONs, forKey: .objectJSONs)
    }
}

extension MigrationGuide: Equatable {
    /// :nodoc:
    public static func == (lhs: MigrationGuide, rhs: MigrationGuide) -> Bool {
        lhs.summary == rhs.summary
            && lhs.id == rhs.id
            && lhs.documentVersion == rhs.documentVersion
            && lhs.from == rhs.from
            && lhs.to == rhs.to
            && lhs.compareConfiguration == rhs.compareConfiguration
            && lhs.serviceChanges.json(prettyPrinted: false) == rhs.serviceChanges.json(prettyPrinted: false)
            && lhs.modelChanges.json(prettyPrinted: false) == rhs.modelChanges.json(prettyPrinted: false)
            && lhs.endpointChanges.json(prettyPrinted: false) == rhs.endpointChanges.json(prettyPrinted: false)
            && lhs.scripts == rhs.scripts
            && lhs.jsonValues == rhs.jsonValues
            && lhs.objectJSONs == rhs.objectJSONs
    }
}
