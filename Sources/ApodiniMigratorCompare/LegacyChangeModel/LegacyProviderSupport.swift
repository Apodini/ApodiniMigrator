//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A util object to correct wrong classification of changes in the migration guide.
/// `ProviderSupport` is included as a field in changes of type addition, deletion or rename
public struct LegacyProviderSupport: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case hint, renamedFrom = "renamed-from", renamedTo = "renamed-to", renameIsValid = "rename-is-valid", warning
    }
    
    /// Textual explanation how to adjust the change object
    var hint: String
    /// Element id if an addi<tion change should instead be treated as a rename.
    /// Property can be adjusted from the provider
    var renamedFrom: LegacyChangeValue?
    /// Element id if a deletion change should instead be treated as a rename
    /// Property can be adjusted from the provider
    var renamedTo: LegacyChangeValue?
    /// Flag to indicate whether a rename change was identified correctly
    /// Property can be adjusted from the provider
    var renameIsValid: Bool?
    /// Warning from `ApodiniCompare`
    var warning: String
    
    /// Private initializer for a new `ProviderSupport` instance
    private init(
        hint: String = "",
        renamedFrom: LegacyChangeValue? = nil,
        renamedTo: LegacyChangeValue? = nil,
        renameIsValid: Bool? = nil,
        warning: String = ""
    ) {
        self.hint = hint
        self.renamedFrom = renamedFrom
        self.renamedTo = renamedTo
        self.renameIsValid = renameIsValid
        self.warning = warning
    }
    
    /// Creates a new instance by decoding from the given decoder.
    /// Since the property will be adjusted from the provider, and the adjustment might result in
    /// a non-valid json, the initializer first initializes the fields with empty values, and then
    /// try decode each of them. If some field has been malformed, the default empty values will be used
    public init(from decoder: Decoder) throws {
        self.init()
        
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            hint = try container.decode(String.self, forKey: .hint)
            renamedFrom = try container.decodeIfPresent(LegacyChangeValue.self, forKey: .renamedFrom)
            renamedTo = try container.decodeIfPresent(LegacyChangeValue.self, forKey: .renamedTo)
            renameIsValid = try container.decodeIfPresent(Bool.self, forKey: .renameIsValid)
            warning = try container.decode(String.self, forKey: .warning)
        } catch {
            return
        }
    }
}

// MARK: - ProviderSupport
extension LegacyProviderSupport {
    // swiftlint:disable line_length
    /// Rename hint for either a Delete or AddChange.
    static func renameHint<C: LegacyChange>(_ type: C.Type) -> LegacyProviderSupport {
        assert(C.self == LegacyAddChange.self || C.self == LegacyDeleteChange.self, "Attempted to use rename hint for change types that are not addition or deletions")
        let isAddition = C.self == LegacyAddChange.self
        return .init(
            hint: "If 'ApodiniCompare' categorized this change incorrectly, replace the value \(LegacyChangeValue.idPlaceholder.value ?? "") of the field \(LegacyChangeValue.CodingKeys.elementID.stringValue) with the corresponding name or id of the element in the '\(isAddition ? "old" : "new")' version, so that 'ApodiniMigrator' traits this change element as a \(LegacyChangeType.rename.rawValue). Note that an adjustment to this change object, requires a corresponding adjustment to the \(isAddition ? "deletion" : "addition") change targeting the same element",
            renamedFrom: isAddition ? .idPlaceholder : nil,
            renamedTo: isAddition ? nil : .idPlaceholder,
            warning: "The field \(LegacyChangeValue.CodingKeys.elementID.stringValue) expects a value of JSON type 'string'. Wrong input might invalidate the provider support or even the entire Migration Guide!"
        )
    }

    /// Hint to validate a rename change
    static var renameValidationHint: LegacyProviderSupport {
        .init(
            hint: "If 'ApodiniCompare' categorized this change incorrectly, replace the value \(true) of the field \(CodingKeys.renameIsValid.rawValue) with \(false), so that 'ApodiniMigrator' does not trait this change element as a \(LegacyChangeType.rename.rawValue). If set to \(false), the element in '\(LegacyUpdateChange.CodingKeys.from.rawValue)' will be trated as a deletion, and the element in '\(LegacyUpdateChange.CodingKeys.to.rawValue)' will be trated as an addition",
            renameIsValid: true,
            warning: "The field \(CodingKeys.renameIsValid.rawValue) expects a value of JSON type 'boolean'. Wrong input might invalidate the provider support or even the entire Migration Guide!"
        )
    }
    // swiftlint:enable line_length
}

extension LegacyChangeValue {
    static var idPlaceholder: LegacyChangeValue {
        .elementID("_")
    }
}
