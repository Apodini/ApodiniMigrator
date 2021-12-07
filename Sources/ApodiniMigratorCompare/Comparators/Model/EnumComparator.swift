//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation

struct EnumComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContextNode
    let configuration: EncoderConfiguration
    
    func element(_ target: EnumTarget) -> ChangeElement {
        .for(enum: lhs, target: target)
    }
    
    func compare() {
        // TODO also rais unsuppoprted change for differing kind! struct vs enum, like in the ObjectComparator!
        guard let lhsRawValue = lhs.rawValueType, let rhsRawValue = rhs.rawValueType else {
            return
        }
        
        if lhsRawValue != rhsRawValue {
            // TODO we could support this one time?
            let change: EnumChange = .update(
                id: lhs.deltaIdentifier,
                updated: .unsupported(
                    change: .enumRawValue(from: lhsRawValue, to: rhsRawValue)
                )
            )

            return changes.add(
                UnsupportedChange(
                    element: element(.`self`),
                    description: "The raw value type of this enum has changed to \(rhsRawValue.nestedTypeString). ApodiniMigrator is not able to migrate this change"
                )
            )
        }

        // TODO wrap changes into Enum Update Change!
        let enumCasesComparator = EnumCasesComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
        enumCasesComparator.compare()
    }
}


private struct EnumCasesComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContextNode
    let configuration: EncoderConfiguration
    let lhsCases: [EnumCase]
    let rhsCases: [EnumCase]
    
    init(lhs: TypeInformation, rhs: TypeInformation, changes: ChangeContextNode, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
        self.lhsCases = lhs.enumCases
        self.rhsCases = rhs.enumCases
    }
    
    func compare() {
        let matchedIds = lhsCases.matchedIds(with: rhsCases)
        let removalCandidates = lhsCases.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCanditates = rhsCases.filter { !matchedIds.contains($0.deltaIdentifier) }
        handle(removalCandidates: removalCandidates, additionCandidates: additionCanditates)
        
        for matched in matchedIds {
            if let lhs = lhsCases.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhsCases.firstMatch(on: \.deltaIdentifier, with: matched) {
                compare(lhs: lhs, rhs: rhs)
            }
        }
    }
    
    private func compare(lhs: EnumCase, rhs: EnumCase) {
        if lhs.rawValue != rhs.rawValue {
            let change: EnumCaseChange = .update(
                id: lhs.deltaIdentifier,
                updated: .rawValueType(
                    from: lhs.rawValue,
                    to: rhs.rawValue
                )
            )

            changes.add(
                UpdateChange(
                    element: element(.caseRawValue),
                    from: .element(lhs),
                    to: .element(rhs),
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
    
    private func element(_ target: EnumTarget) -> ChangeElement {
        .for(enum: lhs, target: target)
    }
    
    
    private func handle(removalCandidates: [EnumCase], additionCandidates: [EnumCase]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates.filter { !relaxedMatchings.contains($0.deltaIdentifier) }) {
                relaxedMatchings += relaxedMatching.element.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier

                let change: EnumCaseChange = .idChange(
                    from: candidate.deltaIdentifier,
                    to: relaxedMatching.element.deltaIdentifier,
                    similarity: relaxedMatching.similarity
                )
                
                changes.add(
                    UpdateChange(
                        element: element(.case),
                        from: candidate.name,
                        to: relaxedMatching.element.name,
                        similarity: relaxedMatching.similarity,
                        breaking: true,
                        solvable: true,
                        includeProviderSupport: includeProviderSupport
                    )
                )
                
                compare(lhs: candidate, rhs: relaxedMatching.element)
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            let change: EnumCaseChange = .removal(
                id: removal.deltaIdentifier,
                solvable: true
            )

            changes.add(
                DeleteChange(
                    element: element(.case),
                    deleted: .id(from: removal),
                    fallbackValue: .none,
                    breaking: true,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            let change: EnumCaseChange = .addition(
                id: addition.deltaIdentifier,
                added: addition
            )

            changes.add(
                AddChange(
                    element: element(.case),
                    added: .element(addition),
                    defaultValue: .none,
                    breaking: false,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
    }
}
