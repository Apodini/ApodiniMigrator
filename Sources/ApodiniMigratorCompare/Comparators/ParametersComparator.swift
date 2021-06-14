//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct ParametersComparator: Comparator {
    let lhs: Endpoint
    let rhs: Endpoint
    let changes: ChangeContainer
    var configuration: EncoderConfiguration
    let lhsParameters: [Parameter]
    let rhsParameters: [Parameter]
    
    var element: ChangeElement {
        .for(endpoint: lhs)
    }
    
    init(lhs: Endpoint, rhs: Endpoint, changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
        self.lhsParameters = lhs.parameters
        self.rhsParameters = rhs.parameters
    }
    
    func compare() {
        let matchedIds = lhsParameters.matchedIds(with: rhsParameters)
        
        let removalCandidates = lhsParameters.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhsParameters.filter { !matchedIds.contains($0.deltaIdentifier) }
        
        for matched in matchedIds {
            if let lhs = lhsParameters.firstMatch(on: \.deltaIdentifier, with: matched),
                let rhs = rhsParameters.firstMatch(on: \.deltaIdentifier, with: matched) {
                let parameterComparator = ParameterComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration, lhsEndpoint: self.lhs)
                parameterComparator.compare()
            }
        }
        
        handle(removalCandidates: removalCandidates, additionCandidates: additionCandidates)
    }

    
    func handle(removalCandidates: [Parameter], additionCandidates: [Parameter]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    RenameChange(
                        element: element,
                        target: .target(for: candidate.parameterType),
                        from: candidate.name,
                        to: relaxedMatching.name,
                        breaking: true,
                        solvable: true
                    )
                )
                let parameterComparator = ParameterComparator(lhs: candidate, rhs: relaxedMatching, changes: changes, configuration: configuration, lhsEndpoint: self.lhs)
                parameterComparator.compare()
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            changes.add(
                DeleteChange(
                    element: element,
                    target: .target(for: removal.parameterType),
                    deleted: .id(from: removal),
                    fallbackValue: .none,
                    breaking: false,
                    solvable: true
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            var defaultValue: ChangeValue?
            let isRequired = addition.necessity == .required
            if isRequired {
                defaultValue = .value(from: addition.typeInformation, with: configuration)
            }
            
            changes.add(
                AddChange(
                    element: element,
                    target: .target(for: addition.parameterType),
                    added: .json(of: addition),
                    defaultValue: defaultValue ?? .none,
                    breaking: isRequired,
                    solvable: true
                )
            )
        }
    }
}
