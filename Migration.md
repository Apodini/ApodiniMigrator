
 # Model migration

 Disclaimer: The approach assumes the developer has not implemented custom codable implementation,
 and Enums use string as rawValue. The approach assumes JSON codable APIs, however would work similarly
 for other encoder and decoders.
 
 Let's assume a DeveloperHandler with the response type `Developer`,
 which additionally contains a property of an enum type
 
 ```swift
 struct Developer: Content {
     let id: Int
     let name: String
     let birthday: Date
     let githubRepository: URL
     let programmingLanguages: [ProgrammingLanguage]
 }

 enum ProgrammingLanguage: String, Content {
     case swift
     case java
     case python
     case other
 }
 ```
 
 Out of the `Developer` type I generate the following swift files for the client library (I am trying to keep the library as lightweight as possible, not including
 swift syntax formatter, have implementated a custom formatter for indenting the file)
 
```swift
// MARK: - File 1

//
//  Developer.swift
//
//  Created by ApodiniMigrator on 09.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Developer
struct Developer: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case birthday
        case githubRepository
        case programmingLanguages
    }
    
    // MARK: - Properties
    let id: Int
    let name: String
    let birthday: Date
    let githubRepository: URL?
    let programmingLanguages: [ProgrammingLanguage]
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(birthday, forKey: .birthday)
        try container.encode(githubRepository, forKey: .githubRepository)
        try container.encode(programmingLanguages, forKey: .programmingLanguages)
    }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        birthday = try container.decode(Date.self, forKey: .birthday)
        githubRepository = try container.decode(URL?.self, forKey: .githubRepository)
        programmingLanguages = try container.decode([ProgrammingLanguage].self, forKey: .programmingLanguages)
    }
}

// MARK: - File 2
//
//  ProgrammingLanguage.swift
//
//  Created by ApodiniMigrator on 09.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - ProgrammingLanguage
enum ProgrammingLanguage: String, Codable, CaseIterable {
    case swift
    case java
    case python
    case other
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(rawValue)
    }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        self = Self(rawValue: try decoder.singleValueContainer().decode(RawValue.self)) ?? .swift
    }
}
```

 To migrate the clients means: Never **touch** the properties of objects and the enum cases after the first library generation, handle migration
 in the encoding and decoding methods.
 
 First, there is a distinguishment to be made, whether both encode method and decode initializer are needed or not. Decisive for that is:
 - If `Developer` type only occurs in response types of the web service -> Clients need only the `init(from decoder: Decoder)`,
 meaning, they will never have transmitt a developer instance to the server
 - If `Developer` type additionally occurs in `content` parameters (request bodies): Provide `encode(to:)` for `Developer`
 and all the types encoded in its `encode(to:)` method
 - Accordingly, if `Developer` would only appear in request bodies, only generate the `encode(to:)` method
 
 
 Now let's consider the type of changes that can appear to these models in the server side, from the client perspective and how both `encode(to:)` and
 `init(from decoder: Decoder)` are affected from the changes:
 
 ## `ProgrammingLanguage` enum:
 ### Add new case change, e.g. `javaScript`:
- `init(from decoder: Decoder)` -> the single value container can contain a string "javaScript". Since the case is unknown, `init?(rawValue:)`
would return `nil`, our enum will be initialized with the default type of the first case -> non - breaking change, no migration step needed.
- `encode(to:)` we would never transmit the newly added case, the server already recognizes our cases -> non - breaking change, no migration step needed.
 ### Rename case, e.g. `other` to `undefined`
- the migrating step that would satisfy both `encode(to:)` and `init(from decoder: Decoder)` is simply adjusting the rawValue of the affected case:
```swift
case other = "undefined"
```
 ### Delete case, e.g. `other`:
- `init(from decoder: Decoder)` -> non - breaking change, we will always receive a case that we contain
- `encode(to:)` - we must ensure to never send the deleted case anymore. Migrating steps:
    1. Add new function to enum scope:
    ```swift
    private func encodableValue() -> Self {
        // the only configurable line of this template function, the function might also be provided by default with empty array
        let deletedCases: [Self] = [.other]
        guard deletedCases.contains(self) else {
            return self
        }
        
        if let alternativeCase = Self.allCases.first { !deltedCases.contains($0) } {
            return alternativeCase
        }
        fatalError("The web service does not support the cases of this enum anymore")
    }
    ```
    2. Replace `try container.encode(rawValue)` in `encode(to:)` method with `try container.encode(encodableValue().rawValue)`
 
 ## `Developer` object:
### Add new property, e.g `let experience: Experience` of type:
```swift
struct Experience {
    let years: Int
    let projects: [String]
}
```
- `init(from decoder: Decoder)` the client does not posses the property, it will never decode it -> Non breaking change - no migrating step needed
- `encode(to:)`: If the property is not marked as required (optional), no migrating step needed, otherwise:
    1. If the type is not present in the library yet, generate a new Swift File for `Experience` struct, similar to `Developer` struct
    2. Add new case to the `CodingKeys` of `Developer` `case experience`
    3. Now the `TypeInformation`, `JSONStringBuilder` and the `DefaultInititializable` protocol come into action, which can either be added as
    files in the library, or as a dependency in the client package. I have extended `Decodable` protocol with:
    ```swift
    extension Decodable {
        static func defaultValue() throws -> Self {
            try JSONStringBuilder.instance(Self.self)
        }
    }
    ```
    4. The static function generates a valid instance based on the json string, for any arbitrary decodable type
    with empty string properties, zero numeric values, date of today for dates, a random UUID, and the github link of ApodiniMigrator for URLs.
    5. If we stick with including the package as a dependency, `import ApodiniMigrator` in `Developer` file.
    6. In `encode(to:)` method add: `try container.encode(try Experience.defaultValue(), forKey: .experience)`
    7. Now every `developer` instance that we will transmit to the server, will contain the required `experience` field
 
### Rename property, e.g. from `id` to `identifier`
- Similar to renaming an enum case in enums, the migrating step that would satisfy both `encode(to:)` and `init(from decoder: Decoder)`
is simply adjusting the rawValue of the affected property:
```swift
case id = "identifier"
```
### Delete property, e.g. `birthday`:
- `encode(to:)`: the client should never send that value anymore -> remove `try container.encode(birthday, forKey: .birthday)` from the method.
(removing required only if the server performs some validation to the body, as far as I know we could keep sending the date,
and the web service would simply not decode it)
- `init(from decoder: Decoder)`, the client will never receive that value anymore
    1. If property would have been optional, replace `birthday = try container.decode(Date.self, forKey: .birthday)` with `birthday = nil`,
    if not optional `birthday = try Date.defaultValue()` (possible from Decodable extension)
### Changed type of property, e.g, `id` from `Int` to `UUID`
- `encode(to:)`: the server will expect a `UUID`, replace `try container.encode(id, forKey: .id)`
with `try container.encode(try UUID.defaultValue(), forKey: .id)`
- `init(from decoder: Decoder)`: the server will send us a `UUID` while we expect an `Int`, replace
`id = try container.decode(Int.self, forKey: .id)` with `id = try Int.defaultValue()`
### Marking a property from required to optional, e.g. `name` from `String` to `String?`
- `encode(to:)` no changing steps required, we can always keep sending the name
- `init(from decoder: Decoder)`, the server might or might not send the value even if we expect it
replace `name = try container.decode(String.self, forKey: .name)` with
`name = try container.decodeIfPresent(String.self, forKey: .name) ?? try String.defaultValue()`
### Marking a property from optional to required, e.g. `githubRepository` from `URL?` to `URL`
- `encode(to:)` the server will always expect a value for `githubRepository`, replace
`try container.encode(githubRepository, forKey: .githubRepository)` with
`try container.encode(githubRepository ?? try URL.defaultValue(), forKey: .githubRepository)`
- `init(from decoder: Decoder)`, the server will always send a value for `githubRepository`,
replace `URL?` to `URL` in the corresponding line: `githubRepository = try container.decode(`**URL**`.self, forKey: .githubRepository)`
(have no tested this case yet, perhaps an adjustment might not be needed at all)

### `Developer` object has been removed and replaced with another complex object e.g. `Student`
- `encode(to:)` Create new Student file if not present yet and replace the method `encode(to:)` of `Developer` with:
```swift
func encode(to encoder: Encoder) throws {
  try Student.defaultValue().encode(to: encoder)
}
```
- `init(from decoder: Decoder)` Simply provide default values for each property or even for `self` directly by adjusting the initializer to:
```swift
init(from decoder: Decoder) throws {
  self = try Self.defaultValue()
}
```
## Next steps
- The approach discourages the need for the facade layer of Pallidor since the adjustments are always made in one single file. 
Perhaps I might generate two files for each object: `TypeName.swift` that will only contain the properties or enum cases, and `TypeName+Migratable.swift` 
as extension with `CodingKeys`, `encode(to:)` method and `init(from decoder: Decoder)`. 
- There is no need to introduce JavaScript code in general, there is also no need to adjust API call methods with converting types, since we are migrating the changes at the source of truth.
- Similar convertion approaches can be followed for changes in `lightweight` / `CustomStringConvertible` parameters, inside of API call methods.
- Adjusting Pallidor with this approach, requires a lot of effort, if you agree, I could handle the library generation with a custom `WebServiceStructure`obtained from the DSL (no need for OpenAPI), and handle the changes accordingly.
- The approach simplifies the structure of the migration guide. It will only contain the type of change and id of the affected element,
and the logic will be handled in the client library, e.g. content of Delete property `birthday` in `Developer` in migration guide would look something similar to:
```json
{
    "change" : "delete",
    "element" : { "object" : "Developer" },
    "target" : { "property" : "birthday" }
}
```
or if we would want to include the steps , it would look like this:
```json
{
    "change" : "delete",
    "element" : { "object" : "Developer" },
    "target" : { "property" : "birthday" },
    "migratingSteps": [
      { "location" : "encode", "replacement" : "string of the new method body" },
      { "location" : "decode", "replacement" : "string of the new init body" }
    ]
}
```

