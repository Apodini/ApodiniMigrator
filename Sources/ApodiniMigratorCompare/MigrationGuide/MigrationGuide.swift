//
//  File.swift
//  
//
//  Created by Eldi Cano on 24.05.21.
//

import Foundation

struct MigrationGuide: Value {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(summary, forKey: .summary)
        try container.encode(serviceType, forKey: .serviceType)
        try container.encode(specificationType, forKey: .specificationType)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(changes, forKey: .changes)
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        summary = try container.decode(String.self, forKey: .summary)
        serviceType = try container.decode(ServiceType.self, forKey: .serviceType)
        specificationType = try container.decode(SpecificationType.self, forKey: .specificationType)
        from = try container.decode(Version.self, forKey: .from)
        to = try container.decode(Version.self, forKey: .to)
        changes = try container.decode(ChangeContainer.self, forKey: .changes)
    }
}
