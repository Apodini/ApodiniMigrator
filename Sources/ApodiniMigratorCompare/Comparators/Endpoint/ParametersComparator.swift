//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ParametersComparator: Comparator {
    // TODO our approach decoupled change analysis from endpoints!
    let lhs: Endpoint // TODO will not be needed anymore
    let rhs: Endpoint
    let changes: ChangeContextNode
    var configuration: EncoderConfiguration
    let lhsParameters: [Parameter]
    let rhsParameters: [Parameter]
    
    init(lhs: Endpoint, rhs: Endpoint, changes: ChangeContextNode, configuration: EncoderConfiguration) {
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
        handle(removalCandidates: removalCandidates, additionCandidates: additionCandidates)
        
        for matched in matchedIds {
            if let lhs = lhsParameters.firstMatch(on: \.deltaIdentifier, with: matched),
                let rhs = rhsParameters.firstMatch(on: \.deltaIdentifier, with: matched) {
                let parameterComparator = ParameterComparator(
                    lhs: lhs,
                    rhs: rhs,
                    changes: changes,
                    configuration: configuration,
                    lhsEndpoint: self.lhs
                )
                parameterComparator.compare()
            }
        }
    }

    
    private func handle(removalCandidates: [Parameter], additionCandidates: [Parameter]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates.filter { !relaxedMatchings.contains($0.deltaIdentifier) }) {
                relaxedMatchings += relaxedMatching.element.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier

                let nameChange: ParameterChange = .idChange(
                    from: candidate.deltaIdentifier,
                    to: relaxedMatching.element.deltaIdentifier,
                    similarity: relaxedMatching.similarity
                )

                changes.add(
                    UpdateChange(
                        element: element(.target(for: candidate)),
                        from: candidate.name,
                        to: relaxedMatching.element.name,
                        similarity: relaxedMatching.similarity,
                        breaking: true,
                        solvable: true,
                        includeProviderSupport: includeProviderSupport
                    )
                )
                let parameterComparator = ParameterComparator(
                    lhs: candidate,
                    rhs: relaxedMatching.element,
                    changes: changes,
                    configuration: configuration,
                    lhsEndpoint: self.lhs
                )
                parameterComparator.compare()
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            let delChange: ParameterChange = .removal(
                id: removal.deltaIdentifier,
                breaking: false,
                solvable: true
            )

            changes.add(
                DeleteChange(
                    element: element(.target(for: removal)),
                    deleted: .id(from: removal),
                    fallbackValue: .none,
                    breaking: false,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            var defaultValue: ChangeValue?
            let isRequired = addition.necessity == .required
            if isRequired {
                defaultValue = .value(from: addition.typeInformation, with: configuration, changes: changes)
            }

            let addChange: ParameterChange = .addition(
                id: addition.deltaIdentifier,
                added: addition.referencedType(),
                defaultValue: 0, // TODO extract json script value from above .value call!
                breaking: isRequired
            )
            changes.add(
                AddChange(
                    element: element(.target(for: addition)),
                    added: .element(addition.referencedType()),
                    defaultValue: defaultValue ?? .none,
                    breaking: isRequired,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
    }
    
    private func element(_ target: EndpointTarget) -> ChangeElement {
        .for(endpoint: lhs, target: target)
    }
}
