//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ObjectComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContextNode
    let configuration: EncoderConfiguration
    let lhsProperties: [TypeProperty]
    let rhsProperties: [TypeProperty] // TODO split out into additional TypePropertyComparator!
    
    init(lhs: TypeInformation, rhs: TypeInformation, changes: ChangeContextNode, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
        self.lhsProperties = lhs.objectProperties
        self.rhsProperties = rhs.objectProperties
    }
    
    func compare() {
        let matchedIds = lhsProperties.matchedIds(with: rhsProperties)
        let removalCandidates = lhsProperties.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhsProperties.filter { !matchedIds.contains($0.deltaIdentifier) }
        handle(removalCandidates: removalCandidates, additionCandidates: additionCandidates)
        
        for matched in matchedIds {
            if let lhs = lhsProperties.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhsProperties.firstMatch(on: \.deltaIdentifier, with: matched) {
                compare(lhs: lhs, rhs: rhs)
            }
        }
        
        changes.store(rhs: rhs, encoderConfiguration: configuration)
    }
    
    private func compare(lhs: TypeProperty, rhs: TypeProperty) {
        let lhsType = lhs.type
        let rhsType = rhs.type
        
        let targetID = lhs.deltaIdentifier
        
        if sameNestedTypes(lhs: lhsType, rhs: rhsType), lhs.necessity != rhs.necessity {
            let currentLhsType = changes.currentVersion(of: lhsType)

            // TODO wrap into object change
            let change: PropertyChange = .update(
                id: lhs.deltaIdentifier,
                updated: .necessity(
                    from: lhs.necessity,
                    to: rhs.necessity,
                    necessityMigration: 0 // TODO use value from .value!
                )
            )

            changes.add(
                UpdateChange(
                    element: element(.necessity),
                    from: .element(lhs.necessity),
                    to: .element(rhs.necessity),
                    necessityValue: .value(from: currentLhsType.unwrapped, with: configuration, changes: changes),
                    targetID: targetID,
                    breaking: true,
                    solvable: true
                )
            )
        } else if typesNeedConvert(lhs: lhsType, rhs: rhsType) {
            let jsScriptBuilder = JSScriptBuilder(from: lhsType, to: rhsType, changes: changes, encoderConfiguration: configuration)

            let forwardScript = changes.store(script: jsScriptBuilder.convertFromTo)
            let backwardScript = changes.store(script: jsScriptBuilder.convertToFrom)

            // TODO wrap into object change
            let change: PropertyChange = .update(
                id: lhs.deltaIdentifier,
                updated: .type(
                    from: lhsType.referenced(),
                    to: rhsType.referenced(),
                    forwardMigration: forwardScript,
                    backwardMigration: backwardScript,
                    conversionWarning: jsScriptBuilder.hint
                )
            )

            changes.add(
                UpdateChange(
                    element: element(.property),
                    from: .element(lhsType.referenced()),
                    to: .element(rhsType.referenced()),
                    targetID: targetID,
                    convertFromTo: forwardScript,
                    convertToFrom: backwardScript,
                    convertionWarning: jsScriptBuilder.hint,
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
    
    private func handle(removalCandidates: [TypeProperty], additionCandidates: [TypeProperty]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates.filter { !relaxedMatchings.contains($0.deltaIdentifier) }) {
                relaxedMatchings += relaxedMatching.element.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier

                // TODO wrap into object change
                let change: PropertyChange = .idChange(
                    from: candidate.deltaIdentifier,
                    to: relaxedMatching.element.deltaIdentifier,
                    similarity: relaxedMatching.similarity,
                    breaking: true
                )

                changes.add(
                    UpdateChange(
                        element: element(.property),
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
            let wasRequired = removal.necessity == .required

            // TODO wrap into object change
            let change: PropertyChange = .removal(
                id: removal.deltaIdentifier,
                fallbackValue: wasRequired ? 0 : nil, // TODO script id
                breaking: wasRequired,
                solvable: true
            )

            changes.add(
                DeleteChange(
                    element: element(.property),
                    deleted: .id(from: removal),
                    fallbackValue: wasRequired ? .value(from: removal.type, with: configuration, changes: changes) : .none,
                    breaking: wasRequired,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            let isRequired = addition.necessity == .required

            // TODO wrap into object change
            let change: PropertyChange = .addition(
                id: addition.deltaIdentifier,
                added: addition.referencedType(),
                defaultValue: isRequired ? 0 : nil, // TODO script id
                breaking: isRequired,
                solvable: true
            )

            changes.add(
                AddChange(
                    element: element(.property),
                    added: .element(addition.referencedType()),
                    defaultValue: isRequired ? .value(from: addition.type, with: configuration, changes: changes) : .none,
                    breaking: isRequired,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
    }
    
    private func element(_ target: ObjectTarget) -> ChangeElement {
        .for(object: lhs, target: target)
    }
}
