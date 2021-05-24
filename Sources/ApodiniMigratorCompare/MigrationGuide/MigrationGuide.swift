//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct MigrationGuide: Codable {
    static let defaultSummary = "Here would be a nice summary what changed between versions"
    
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case summary
        case serviceType
        case specificationType = "api-spec"
        case from
        case to
        case changes
    }
    
    let summary: String
    let serviceType: ServiceType
    let specificationType: SpecificationType
    let from: Version
    let to: Version
    let changes: ChangeContainer
    
    init(
        summary: String,
        serviceType: ServiceType,
        specificationType: SpecificationType,
        from: Version,
        to: Version,
        changes: ChangeContainer
    ) {
        self.summary = summary
        self.serviceType = serviceType
        self.specificationType = specificationType
        self.from = from
        self.to = to
        self.changes = changes
    }
    
    init(for lhs: Document, rhs: Document) {
        let changeContainer = ChangeContainer()
        let documentsComparator = DocumentComparator(lhs: lhs, rhs: rhs, changes: changeContainer)
        documentsComparator.compare()
        self.init(
            summary: Self.defaultSummary,
            serviceType: .rest,
            specificationType: .apodini,
            from: lhs.metaData.version,
            to: rhs.metaData.version,
            changes: changeContainer
        )
    }
}
