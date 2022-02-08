//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A util object to correct wrong classification of changes in the migration guide.
/// `ProviderSupport` is included as a field in changes of type addition, deletion or rename
struct LegacyProviderSupport: Decodable {
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
    var renameIsValid: Bool? // swiftlint:disable:this discouraged_optional_boolean
    /// Warning from `ApodiniCompare`
    var warning: String
    
    /// Creates a new instance by decoding from the given decoder.
    /// Since the property will be adjusted from the provider, and the adjustment might result in
    /// a non-valid json, the initializer first initializes the fields with empty values, and then
    /// try decode each of them. If some field has been malformed, the default empty values will be used
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        hint = (try? container.decode(String.self, forKey: .hint)) ?? ""
        renamedFrom = try? container.decodeIfPresent(LegacyChangeValue.self, forKey: .renamedFrom)
        renamedTo = try? container.decodeIfPresent(LegacyChangeValue.self, forKey: .renamedTo)
        renameIsValid = try? container.decodeIfPresent(Bool.self, forKey: .renameIsValid)
        warning = (try? container.decode(String.self, forKey: .warning)) ?? ""
    }
}
