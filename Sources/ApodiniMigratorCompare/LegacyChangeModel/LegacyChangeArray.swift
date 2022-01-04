//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length line_length

// swiftlint:disable:next type_body_length
struct LegacyChangeArray: Decodable {
    enum MigrationError: Error {
        case unknownChangeType(message: String, path: [CodingKey])
        case malformedLegacyMigrationGuide(message: String)
        case unexpectedState(message: String)
        case unsupported(message: String)
    }

    // swiftlint:disable:next identifier_name
    private static let rootTypeUnsupportedChangeDescriptionSuffix = "Change from enum to object or vice versa is currently not supported"
    // swiftlint:disable:next identifier_name
    private static let rawValueTypeUnsupportedChangeDescriptionPrefix = "The raw value type of this enum has changed to"

    private var addChanges: [LegacyAddChange] = []
    private var deleteChanges: [LegacyDeleteChange] = []
    private var updateChanges: [LegacyUpdateChange] = []
    private var unsupportedChanges: [LegacyUnsupportedChange] = []

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var iterations = 0

        while !container.isAtEnd {
            if let value = try? container.decode(LegacyAddChange.self) {
                addChanges.append(value)
            } else if let value = try? container.decode(LegacyDeleteChange.self) {
                deleteChanges.append(value)
            } else if let value = try? container.decode(LegacyUpdateChange.self) {
                updateChanges.append(value)
            } else if let value = try? container.decode(LegacyUnsupportedChange.self) {
                unsupportedChanges.append(value)
            } else {
                throw MigrationError.unknownChangeType(message: "Encountered unknown change type after \(iterations) iterations", path: decoder.codingPath)
            }
            iterations += 1
        }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func migrate(
        serviceChanges: inout [ServiceInformationChange],
        modelChanges: inout [ModelChange],
        endpointChanges: inout [EndpointChange]
    ) throws {
        var changedEncoderConfiguration: (from: EncoderConfiguration, to: EncoderConfiguration)?
        var changedDecoderConfiguration: (from: DecoderConfiguration, to: DecoderConfiguration)?

        for change in addChanges {
            precondition(change.type == .addition)
            switch change.element {
            case let .endpoint(id, target):
                switch target {
                case .`self`:
                    guard case .none = change.defaultValue else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .none defaultValue for endpoint!")
                    }

                    guard case let .element(anyCodable) = change.added,
                          let endpoint = anyCodable.tryTyped(Endpoint.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .element with Endpoint for added endpoint.")
                    }

                    endpointChanges.append(.addition(
                        id: id,
                        added: endpoint,
                        defaultValue: nil,
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .queryParameter, .pathParameter, .contentParameter:
                    let defaultValue: Int?
                    if case let .json(migrationId) = change.defaultValue {
                        defaultValue = migrationId
                    } else {
                        defaultValue = nil
                    }

                    guard case let .element(anyCodable) = change.added,
                          let parameter = anyCodable.tryTyped(Parameter.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .element with Parameter for added parameter.")
                    }

                    endpointChanges.append(.update(
                        id: id,
                        updated: .parameter(parameter: .addition(
                            id: parameter.deltaIdentifier,
                            added: parameter,
                            defaultValue: defaultValue,
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for endpoint addition change.")
                }
            case let .enum(id, target):
                switch target {
                case .`self`:
                    modelChanges.append(try migrateModelAdditionChange(change: change))
                case .case:
                    guard case .none = change.defaultValue else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .none defaultValue for enum case.")
                    }

                    guard case let .element(anyCodable) = change.added,
                          let enumCase = anyCodable.tryTyped(EnumCase.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .element with EnumCase for added case!")
                    }

                    modelChanges.append(.update(
                        id: id,
                        updated: .case(case: .addition(
                            id: enumCase.deltaIdentifier,
                            added: enumCase,
                            defaultValue: nil,
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for enum addition change.")
                }
            case let .object(id, target):
                switch target {
                case.`self`:
                    modelChanges.append(try migrateModelAdditionChange(change: change))
                case .property:
                    let defaultValue: Int?
                    if case let .json(migrationId) = change.defaultValue {
                        defaultValue = migrationId
                    } else {
                        defaultValue = nil
                    }

                    guard case let .element(anyCodable) = change.added,
                          let property = anyCodable.tryTyped(TypeProperty.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .element with TypeProperty for added property!")
                    }

                    modelChanges.append(.update(
                        id: id,
                        updated: .property(property: .addition(
                            id: property.deltaIdentifier,
                            added: property,
                            defaultValue: defaultValue,
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for object addition change.")
                }
            case .networking:
                throw MigrationError.unexpectedState(message: "Legacy Networking changes cannot be addition change")
            }
        }

        for change in deleteChanges {
            precondition(change.type == .deletion)
            switch change.element {
            case let .endpoint(id, target):
                switch target {
                case .`self`:
                    guard case .none = change.fallbackValue else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .none fallbackValue for endpoint!")
                    }

                    guard case let .elementID(endpointId) = change.deleted else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .elementID for removed endpoint!")
                    }
                    guard endpointId == id else {
                        throw MigrationError.unexpectedState(message: "Reached illegal state for removed endpoint. Non-matching ids!")
                    }

                    endpointChanges.append(.removal(
                        id: id,
                        removed: nil,
                        fallbackValue: nil,
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .queryParameter, .pathParameter, .contentParameter:
                    guard case .none = change.fallbackValue else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .none fallbackValue for parameter.")
                    }

                    guard case let .elementID(parameterId) = change.deleted else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .elementID for removed parameter.")
                    }

                    endpointChanges.append(.update(
                        id: id,
                        updated: .parameter(parameter: .removal(
                            id: parameterId,
                            removed: nil,
                            fallbackValue: nil,
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for endpoint removal change.")
                }
            case let .enum(id, target):
                switch target {
                case .`self`:
                    modelChanges.append(try migrateModelRemovalChange(change: change))
                case .case:
                    guard case .none = change.fallbackValue else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .none fallbackValue for enum case.")
                    }

                    guard case let .elementID(enumCaseId) = change.deleted else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .elementID for removed case!")
                    }

                    modelChanges.append(.update(
                        id: id,
                        updated: .case(case: .removal(
                            id: enumCaseId,
                            removed: nil,
                            fallbackValue: nil,
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for enum removal change.")
                }
            case let .object(id, target):
                switch target {
                case .`self`:
                    modelChanges.append(try migrateModelRemovalChange(change: change))
                case .property:
                    let fallbackValue: Int?
                    if case let .json(migrationId) = change.fallbackValue {
                        fallbackValue = migrationId
                    } else {
                        fallbackValue = nil
                    }

                    guard case let .elementID(parameterId) = change.deleted else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .elementID for removed property!")
                    }

                    modelChanges.append(.update(
                        id: id,
                        updated: .property(property: .removal(
                            id: parameterId,
                            removed: nil,
                            fallbackValue: fallbackValue,
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for object removal change.")
                }
            case .networking:
                throw MigrationError.unexpectedState(message: "Legacy Networking changes cannot be removal change")
            }
        }

        for change in updateChanges {
            switch change.element {
            case let .endpoint(id, target):
                switch target {
                case .deltaIdentifier:
                    guard case .rename = change.type else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for endpoint change.")
                    }

                    guard case let .stringValue(fromName) = change.from,
                          case let .stringValue(toName) = change.to else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Endpoint change value must be .stringValue!")
                    }

                    guard fromName == id.rawValue else {
                        throw MigrationError.unexpectedState(message: "Reached illegal state for updated endpoint. Non-matching ids!")
                    }

                    endpointChanges.append(.idChange(
                        from: id,
                        to: DeltaIdentifier(toName),
                        similarity: change.similarity,
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .resourcePath:
                    guard case .update = change.type else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for resource path change.")
                    }

                    guard case let .element(fromCodable) = change.from,
                          case let .element(toCodable) = change.to,
                          let fromPath = fromCodable.tryTyped(EndpointPath.self),
                          let toPath = toCodable.tryTyped(EndpointPath.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expected .element EndpointPath for resource path change.")
                    }

                    endpointChanges.append(.update(
                        id: id,
                        updated: .identifier(identifier: .update(
                            id: DeltaIdentifier(EndpointPath.identifierType),
                            updated: .init(
                                from: AnyEndpointIdentifier(from: fromPath),
                                to: AnyEndpointIdentifier(from: toPath)
                            ),
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .operation:
                    guard case .update = change.type else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for operation change.")
                    }

                    guard case let .element(fromCodable) = change.from,
                          case let .element(toCodable) = change.to,
                          let fromOperation = fromCodable.tryTyped(Operation.self),
                          let toOperation = toCodable.tryTyped(Operation.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expected .element Operation for operation change.")
                    }

                    endpointChanges.append(.update(
                        id: id,
                        updated: .identifier(identifier: .update(
                            id: DeltaIdentifier(Operation.identifierType),
                            updated: .init(
                                from: AnyEndpointIdentifier(from: fromOperation),
                                to: AnyEndpointIdentifier(from: toOperation)
                            ),
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .response:
                    guard case .responseChange = change.type else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for response change.")
                    }

                    guard case let .element(fromCodable) = change.from,
                          case let .element(toCodable) = change.to,
                          let fromResponse = fromCodable.tryTyped(TypeInformation.self),
                          let toResponse = toCodable.tryTyped(TypeInformation.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expected .element TypeInformation for response change.")
                    }

                    guard let convertToFrom = change.convertToFrom else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Response change expects type migrations scripts in backward directions!")
                    }

                    endpointChanges.append(.update(
                        id: id,
                        updated: .response(
                            from: fromResponse,
                            to: toResponse,
                            backwardsMigration: convertToFrom,
                            migrationWarning: change.convertionWarning
                        ),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .queryParameter, .pathParameter, .contentParameter:
                    switch change.type {
                    case .rename:
                        guard case let .stringValue(fromName) = change.from,
                              case let .stringValue(toName) = change.to else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Endpoint parameter change value must be .stringValue!")
                        }

                        endpointChanges.append(.update(
                            id: id,
                            updated: .parameter(parameter: .idChange(
                                from: DeltaIdentifier(fromName),
                                to: DeltaIdentifier(toName),
                                similarity: change.similarity,
                                breaking: change.breaking,
                                solvable: change.solvable
                            )),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    case .parameterChange:
                        guard let parameterTarget = change.parameterTarget else {
                            throw MigrationError.unexpectedState(message: "ParameterTarget is required for a parameter change.")
                        }

                        guard case let .element(fromCodable) = change.from,
                              case let .element(toCodable) = change.to else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Expected .element for parameter change.")
                        }

                        guard let parameterId = change.targetID else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Expected targetID field with parameter id.")
                        }

                        let parameterUpdateChange: ParameterUpdateChange

                        switch parameterTarget {
                        case .kind:
                            guard let fromType = fromCodable.tryTyped(ParameterType.self),
                                  let toType = toCodable.tryTyped(ParameterType.self) else {
                                throw MigrationError.malformedLegacyMigrationGuide(message: "Expected ParameterType change value for kind change.")
                            }

                            parameterUpdateChange = .parameterType(from: fromType, to: toType)
                        case .necessity:
                            guard let fromNecessity = fromCodable.tryTyped(Necessity.self),
                                  let toNecessity = toCodable.tryTyped(Necessity.self) else {
                                throw MigrationError.malformedLegacyMigrationGuide(message: "Expected Necessity change value for necessity change.")
                            }

                            guard case let .json(migrationId) = change.necessityValue else {
                                throw MigrationError.malformedLegacyMigrationGuide(message: "Expected .json for necessityValue for necessity change.")
                            }

                            parameterUpdateChange = .necessity(from: fromNecessity, to: toNecessity, necessityMigration: migrationId)
                        case .typeInformation:
                            guard let fromType = fromCodable.tryTyped(TypeInformation.self),
                                  let toType = toCodable.tryTyped(TypeInformation.self) else {
                                throw MigrationError.malformedLegacyMigrationGuide(message: "Expected TypeInformation change value for parameter type change.")
                            }

                            guard let convertFromTo = change.convertFromTo else {
                                throw MigrationError.malformedLegacyMigrationGuide(message: "Expected convertFromTo for parameter type change.")
                            }

                            parameterUpdateChange = .type(
                                from: fromType,
                                to: toType,
                                forwardMigration: convertFromTo,
                                conversionWarning: change.convertionWarning
                            )
                        }

                        endpointChanges.append(.update(
                            id: id,
                            updated: .parameter(parameter: .update(
                                id: parameterId,
                                updated: parameterUpdateChange,
                                breaking: change.breaking,
                                solvable: change.solvable
                            )),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    default:
                        throw MigrationError.unexpectedState(message: "Didn't expect \(change.type) type for parameter change!")
                    }
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for enum update change.")
                }
            case let .enum(id, target):
                switch target {
                case .typeName:
                    modelChanges.append(try migrateModelUpdateTypeNameChange(change: change))
                case .case:
                    guard case .rename = change.type else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for enum case change.")
                    }

                    guard case let .stringValue(fromCaseName) = change.from,
                          case let .stringValue(toCaseName) = change.to else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Enum case change value must be .stringValue!")
                    }

                    modelChanges.append(.update(
                        id: id,
                        updated: .case(case: .idChange(
                            from: DeltaIdentifier(fromCaseName),
                            to: DeltaIdentifier(toCaseName),
                            similarity: change.similarity,
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .caseRawValue:
                    guard case .update = change.type else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for enum case rawValue change.")
                    }

                    guard case let .element(fromCodable) = change.from,
                          case let .element(toCodable) = change.to,
                          let fromCase = fromCodable.tryTyped(EnumCase.self),
                          let toCase = toCodable.tryTyped(EnumCase.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Expected .element EnumCase for .caseRawValue change.")
                    }

                    modelChanges.append(.update(
                        id: id,
                        updated: .case(case: .update(
                            id: fromCase.deltaIdentifier,
                            updated: .rawValue(from: fromCase.rawValue, to: toCase.rawValue),
                            breaking: change.breaking,
                            solvable: change.solvable
                        )),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for enum update change.")
                }
            case let .object(id, target):
                switch target {
                case .typeName:
                    modelChanges.append(try migrateModelUpdateTypeNameChange(change: change))
                case .property:
                    switch change.type {
                    case .rename:
                        guard case let .stringValue(fromPropertyName) = change.from,
                              case let .stringValue(toPropertyName) = change.to else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Property change value must be .stringValue!")
                        }

                        modelChanges.append(.update(
                            id: id,
                            updated: .property(property: .idChange(
                                from: DeltaIdentifier(fromPropertyName),
                                to: DeltaIdentifier(toPropertyName),
                                similarity: change.similarity,
                                breaking: change.breaking,
                                solvable: change.solvable
                            )),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    case .propertyChange:
                        guard case let .element(fromCodable) = change.from,
                              case let .element(toCodable) = change.to,
                              let fromType = fromCodable.tryTyped(TypeInformation.self),
                              let toType = toCodable.tryTyped(TypeInformation.self) else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Property necessity value must be .element of TypeInformation!")
                        }

                        guard let parameterId = change.targetID else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Property change expects targetID!")
                        }

                        guard let convertFromTo = change.convertFromTo,
                              let convertToFrom = change.convertToFrom else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Property change expects type migrations scripts in both directions!")
                        }

                        modelChanges.append(.update(
                            id: id,
                            updated: .property(property: .update(
                                id: parameterId,
                                updated: .type(
                                    from: fromType,
                                    to: toType,
                                    forwardMigration: convertFromTo,
                                    backwardMigration: convertToFrom,
                                    conversionWarning: change.convertionWarning
                                ),
                                breaking: change.breaking,
                                solvable: change.solvable
                            )),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    default:
                        throw MigrationError.unexpectedState(message: "Didn't expect \(change.type) type for property change!")
                    }
                case .necessity:
                    switch change.type {
                    case .update:
                        guard case let .element(fromCodable) = change.from,
                              case let .element(toCodable) = change.to,
                              let fromNecessity = fromCodable.tryTyped(Necessity.self),
                              let toNecessity = toCodable.tryTyped(Necessity.self) else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Property necessity value must be .element of Necessity!")
                        }

                        guard case let .json(necessityMigration) = change.necessityValue else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Property necessity change expects .json necessity migration id!")
                        }

                        guard let parameterId = change.targetID else {
                            throw MigrationError.malformedLegacyMigrationGuide(message: "Property necessity change expects targetID!")
                        }

                        modelChanges.append(.update(
                            id: id,
                            updated: .property(property: .update(
                                id: parameterId,
                                updated: .necessity(from: fromNecessity, to: toNecessity, necessityMigration: necessityMigration),
                                breaking: change.breaking,
                                solvable: change.solvable
                            )),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    default:
                        throw MigrationError.unexpectedState(message: "Didn't expect \(change.type) for property necessity.")
                    }
                default:
                    throw MigrationError.unexpectedState(message: "Didn't expect change target \(target) for object update change.")
                }
            case let .networking(target):
                guard case .update = change.type else {
                    throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for networking change.")
                }

                switch target {
                case .serverPath:
                    guard case let .stringValue(fromServerPath) = change.from,
                          case let .stringValue(toServerPath) = change.to else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Network change path value must be .stringValue!")
                    }

                    serviceChanges.append(.update(
                        id: ServiceInformation.deltaIdentifier,
                        updated: .http(
                            from: try HTTPInformation(fromLegacyServerPath: fromServerPath),
                            to: try HTTPInformation(fromLegacyServerPath: toServerPath)
                        ),
                        breaking: change.breaking,
                        solvable: change.solvable
                    ))
                case .encoderConfiguration:
                    guard case let .element(fromCodable) = change.from,
                          case let .element(toCodable) = change.to,
                          let fromEncoder = fromCodable.tryTyped(EncoderConfiguration.self),
                          let toEncoder = toCodable.tryTyped(EncoderConfiguration.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Network change encoder value must be .element!")
                    }

                    changedEncoderConfiguration = (fromEncoder, toEncoder)
                case .decoderConfiguration:
                    guard case let .element(fromCodable) = change.from,
                          case let .element(toCodable) = change.to,
                          let fromDecoder = fromCodable.tryTyped(DecoderConfiguration.self),
                          let toDecoder = toCodable.tryTyped(DecoderConfiguration.self) else {
                        throw MigrationError.malformedLegacyMigrationGuide(message: "Network change decoder value must be .element!")
                    }

                    changedDecoderConfiguration = (fromDecoder, toDecoder)
                }
            }
        }

        for change in unsupportedChanges {
            precondition(change.type == .unsupported)

            switch change.element {
            case let .enum(id, target):
                switch target {
                case .`self`:
                    if change.description.hasSuffix(Self.rootTypeUnsupportedChangeDescriptionSuffix) {
                        modelChanges.append(.update(
                            id: id,
                            updated: .rootType(from: .enum, to: .object, newModel: TypeInformation.reference("UNSUPPORTED")),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    } else if change.description.hasPrefix(Self.rawValueTypeUnsupportedChangeDescriptionPrefix) {
                        modelChanges.append(.update(
                            id: id,
                            updated: .rawValueType(from: .reference("UNSUPPORTED0"), to: .reference("UNSUPPORTED1")),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    } else {
                        throw MigrationError.unexpectedState(message: "Encountered unknown enum unsupported change: \(change.description)")
                    }
                default:
                    throw MigrationError.unexpectedState(message: "Encountered unknown unsupported change for enum target \(target): \(change.description)")
                }
            case let .object(id, target):
                switch target {
                case .`self`:
                    if change.description.hasSuffix(Self.rootTypeUnsupportedChangeDescriptionSuffix) {
                        modelChanges.append(.update(
                            id: id,
                            updated: .rootType(from: .object, to: .enum, newModel: TypeInformation.reference("UNSUPPORTED")),
                            breaking: change.breaking,
                            solvable: change.solvable
                        ))
                    } else {
                        throw MigrationError.unexpectedState(message: "Encountered unknown object unsupported change: \(change.description)")
                    }
                default:
                    throw MigrationError.unexpectedState(message: "Encountered unknown unsupported change for object target \(target): \(change.description)")
                }
            default:
                throw MigrationError.unexpectedState(message: "Encountered unknown unsupported change for element \(change.element): \(change.description)")
            }
        }

        if changedEncoderConfiguration != nil || changedDecoderConfiguration != nil {
            // we can't properly reconstruct everything if it wasn't changed ://
            // we do best effort here
            let from = AnyExporterConfiguration(RESTExporterConfiguration(
                encoderConfiguration: changedEncoderConfiguration?.from ?? .default,
                decoderConfiguration: changedDecoderConfiguration?.from ?? .default
            ))
            let to = AnyExporterConfiguration(RESTExporterConfiguration(
                encoderConfiguration: changedEncoderConfiguration?.to ?? .default,
                decoderConfiguration: changedDecoderConfiguration?.to ?? .default
            ))

            serviceChanges.append(.update(
                id: ServiceInformation.deltaIdentifier,
                updated: .exporter(exporter: .update(
                    id: from.deltaIdentifier,
                    updated: .init(from: from, to: to),
                    breaking: true,
                    solvable: true
                )),
                breaking: true,
                solvable: true
            ))
        }
    }

    private func migrateModelAdditionChange(change: LegacyAddChange) throws -> ModelChange {
        guard case .none = change.defaultValue else {
            throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .none defaultValue for model!")
        }

        guard case let .element(anyCodable) = change.added,
              let modelWithReferencedProperties = anyCodable.tryTyped(TypeInformation.self) else {
            throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .element with TypeInformation for added model!")
        }

        return .addition(
            id: change.element.deltaIdentifier,
            added: modelWithReferencedProperties,
            defaultValue: nil,
            breaking: change.breaking,
            solvable: change.solvable
        )
    }

    private func migrateModelRemovalChange(change: LegacyDeleteChange) throws -> ModelChange {
        guard case .none = change.fallbackValue else {
            throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .none fallbackValue for model!")
        }

        guard case let .elementID(id) = change.deleted else {
            throw MigrationError.malformedLegacyMigrationGuide(message: "Expecting .elementID for removed model!")
        }
        guard id == change.element.deltaIdentifier else {
            throw MigrationError.unexpectedState(message: "Reached illegal state for removed model. Non-matching ids!")
        }

        return .removal(
            id: id,
            removed: nil,
            fallbackValue: nil,
            breaking: change.breaking,
            solvable: change.solvable
        )
    }

    private func migrateModelUpdateTypeNameChange(change: LegacyUpdateChange) throws -> ModelChange {
        guard case .rename = change.type else {
            throw MigrationError.malformedLegacyMigrationGuide(message: "Didn't expect \(change.type) for type rename change")
        }

        guard case let .stringValue(fromTypeName) = change.from,
              case let .stringValue(toTypeName) = change.to else {
            throw MigrationError.malformedLegacyMigrationGuide(message: "UpdateChange model .typeName values must be .stringValue!")
        }
        guard fromTypeName == change.element.deltaIdentifier.rawValue else {
            throw MigrationError.unexpectedState(message: "Reached illegal state for update type name of model. Non-matching identifiers!")
        }

        return .idChange(
            from: change.element.deltaIdentifier,
            to: DeltaIdentifier(toTypeName),
            similarity: change.similarity,
            breaking: change.breaking,
            solvable: change.solvable
        )
    }
}
