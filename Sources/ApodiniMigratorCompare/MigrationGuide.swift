//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// This enum describes the document format version of the ``MigrationGuide``.
/// ``MigrationGuideDocumentVersion`` follows the SemVer versioning scheme.
public enum MigrationGuideDocumentVersion: String, Codable {
    public static let current: MigrationGuideDocumentVersion = .v2_1

    /// The original/legacy document format introduced with version 0.1.0.
    /// - Note: This version is assumed when no `version` field is present in the document root.
    ///     ApodiniMigrator supports parsing legacy documents till 0.3.0.
    case v1 = "1.0.0"
    /// The current document format and updated change model introduced with version 0.2.0.
    case v2 = "2.0.0"
    /// The document format introduced with version 0.3.0.
    case v2_1 = "2.1.0" // swiftlint:disable:this identifier_name
}

/// Migration guide
public struct MigrationGuide {
    /// A default summary. A free filed to use by providers of MigrationGuides.
    static let defaultSummary = "A summary of what changed between versions"

    /// A textual description of the migration guide
    public let summary: String

    /// Id of the old document from which the migration guide was generated
    public let id: UUID
    /// Old version
    public let from: Version
    /// New version
    public let to: Version
    private let _compareConfiguration: CompareConfiguration?
    /// Configuration used for the Comparators while generating the MigrationGuide.
    public var compareConfiguration: CompareConfiguration {
        self._compareConfiguration ?? .default
    }

    /// Captures any changes happening to the `ServiceInformation`, describing the web service.
    public var serviceChanges: [ServiceInformationChange]
    /// Captures any changes done to web service models.
    public var modelChanges: [ModelChange]
    /// Captures any changes done to web service endpoints.
    public var endpointChanges: [EndpointChange]


    /// Dictionary holding all registered convert scripts which are referenced from change objects
    public let scripts: [Int: JSScript]
    /// Dictionary holding all registered json values which are referenced from change objects
    public let jsonValues: [Int: JSONValue]
    /// A property that holds json representation of models that had a breaking change on their properties, e.g. rename, addition, deletion or property type change.
    /// This property is used for test cases in the client application
    public let objectJSONs: [String: JSONValue]

    /// An empty migration guide with no changes
    public static func empty(id: UUID = UUID()) -> MigrationGuide {
        .init(
            summary: Self.defaultSummary,
            id: id,
            from: .default,
            to: .default,
            comparisonContext: ChangeComparisonContext(configuration: nil, latestModels: [])
        )
    }

    /// Internal initializer of the Migration Guide
    init(
        summary: String,
        id: UUID,
        from: Version,
        to: Version,
        comparisonContext: ChangeComparisonContext
    ) {
        self.summary = summary
        self.id = id
        self.from = from
        self.to = to
        self._compareConfiguration = comparisonContext.configuration

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
        let documentsComparator = DocumentComparator(configuration: compareConfiguration, lhs: lhs, rhs: rhs)
        documentsComparator.compare()

        self.init(
            summary: Self.defaultSummary,
            id: lhs.id,
            from: lhs.serviceInformation.version,
            to: rhs.serviceInformation.version,
            comparisonContext: documentsComparator.context
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
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let documentVersion: MigrationGuideDocumentVersion
        do {
            documentVersion = try container.decodeIfPresent(MigrationGuideDocumentVersion.self, forKey: .documentVersion) ?? .v1
        } catch {
            // failed to decode APIDocumentVersion, probably because its an unknown version!
            throw CodingError.unsupportedDocumentVersion(version: try container.decode(String.self, forKey: .documentVersion))
        }

        // decode fields which are the same in all versions
        summary = try container.decode(String.self, forKey: .summary)
        id = try container.decode(UUID.self, forKey: .id)
        from = try container.decode(Version.self, forKey: .from)
        to = try container.decode(Version.self, forKey: .to)

        scripts = try container.decode([Int: JSScript].self, forKey: .scripts)
        jsonValues = try container.decode([Int: JSONValue].self, forKey: .jsonValues)
        objectJSONs = try container.decode([String: JSONValue].self, forKey: .objectJSONs)

        switch documentVersion {
        case .v1:
            if let legacyConfiguration = try container.decodeIfPresent(LegacyCompareConfiguration.self, forKey: .compareConfiguration) {
                self._compareConfiguration = CompareConfiguration(from: legacyConfiguration)
            } else {
                self._compareConfiguration = nil
            }

            let changes = try container.decode(LegacyChangeArray.self, forKey: .changes)

            var serviceChanges = [ServiceInformationChange]()
            var modelChanges = [ModelChange]()
            var endpointChanges = [EndpointChange]()

            try changes.migrate(serviceChanges: &serviceChanges, modelChanges: &modelChanges, endpointChanges: &endpointChanges)

            self.serviceChanges = serviceChanges
            self.modelChanges = modelChanges
            self.endpointChanges = endpointChanges
        case .v2, .v2_1:
            _compareConfiguration = try container.decodeIfPresent(CompareConfiguration.self, forKey: .compareConfiguration)

            serviceChanges = try container.decodeIfPresentOrInitEmpty([ServiceInformationChange].self, forKey: .serviceChanges)
            modelChanges = try container.decodeIfPresentOrInitEmpty([ModelChange].self, forKey: .modelChanges)
            endpointChanges = try container.decodeIfPresentOrInitEmpty([EndpointChange].self, forKey: .endpointChanges)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(summary, forKey: .summary)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(MigrationGuideDocumentVersion.current, forKey: .documentVersion)
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
    public static func == (lhs: MigrationGuide, rhs: MigrationGuide) -> Bool {lhs.summary == rhs.summary
            && lhs.id == rhs.id
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
