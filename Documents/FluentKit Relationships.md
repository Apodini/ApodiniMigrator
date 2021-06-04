### Fluentkit Relationships
Example models from `IOS21EXAMPLE-ACD`

`Contact.swift`
```swift
public final class Contact: Model {
    @ID
    public var id: UUID?
    
    @Timestamp(key: "createdAt", on: .create)
    public var createdAt: Date?
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "birthday")
    public var birthday: Date
    
    @Children(for: \.$contact)
    public var residencies: [Residence]
}
```
`Residence.swift`

```swift
public final class Residence: Model {
    @ID
    public var id: UUID?
    
    @Timestamp(key: "createdAt", on: .create)
    public var createdAt: Date?
    
    @Field(key: "address")
    public var address: String
    
    @Field(key: "postalCode")
    public var postalCode: String
    
    @Field(key: "country")
    public var country: String
    
    @Parent(key: "contact_id")
    public var contact: Contact
}
```
Now let's consider a `POST` on `/contacts`. Obviously no residencies, and the only required fields are `name` and `birthday`, so we need to send in the body:

```json
{
    "birthday": 644182893.03527904,
    "name": "Postman"
}
```
Apodini response:
```json
{
    "data": {
        "id": "0E8C7F4D-B8F5-4DF9-832C-1B3C71FF3897",
        "name": "Postman",
        "birthday": 644182893.03527904,
        "createdAt": 644235524.69844198
    },
    "_links": {
        "contactId": "http://127.0.0.1:8080/v1/contacts/{contactId}",
        "self": "http://127.0.0.1:8080/v1/contacts"
    }
}
```
`data` has been encoded from fluent, and it does not encode the `residences` because not specified in the handle function.

Now let's add a new residence to the `Postman` contact, through the `content` parameter `Residence` in the corresponding handler. Parameter retrieval in Apodini
expects to decode all fields in `Residence` object, otherwise the decoding fails. So we need a `POST` on `/residencies` with the following body:

```json
{
  "contact": {
    "id": "0E8C7F4D-B8F5-4DF9-832C-1B3C71FF3897"
  },
  "country": "Country",
  "address": "Address",
  "postalCode": "Postal code"
}
```
While for the contact only the `id` is required for this request. This request is currently not working in the example project
because the `Residence` object in the app looks like this:
```swift
public struct Residence: Codable, Hashable, Identifiable {
    public var id: UUID?
    public var address: String
    public var postalCode: String
    public var country: String
    public var resident: UUID
}
```
The required `contact` field is missing, instead the resident id, and Apodini sends:
```json
{
    "error": true,
    "reason": "ApodiniError(type: Apodini.ErrorType.badInput, reason: Optional(\"Parameter retrieval returned explicit nil, though explicit nil is not valid for the \\'@Parameter var residence: Residence\\'.\"), description: nil, options: Apodini.PropertyOptionSet<Apodini.ErrorOptionNameSpace>(options: [:]))"
}
```
Now depending on how it is specified in the handle function residences are returned on get all contacts:
```json
{
    "data": [
        {
            "birthday": 644182893.03527904,
            "id": "0E8C7F4D-B8F5-4DF9-832C-1B3C71FF3897",
            "name": "Postman",
            "residencies": [
                {
                    "createdAt": 644237411.91207504,
                    "id": "8AAC0A86-B514-42E9-B770-A38F1E687FB1",
                    "country": "Country",
                    "address": "Address",
                    "contact": {
                        "id": "0E8C7F4D-B8F5-4DF9-832C-1B3C71FF3897"
                    },
                    "postalCode": "Postal code"
                }
            ],
            "createdAt": 644235524.69844198
        }
    ],
    "_links": {
        "contactId": "http://127.0.0.1:8080/v1/contacts/{contactId}",
        "self": "http://127.0.0.1:8080/v1/contacts"
    }
}
```
and not returned for a `GET` on `/contacts/0E8C7F4D-B8F5-4DF9-832C-1B3C71FF3897`. I will deal with this by decoding arrays if present (see init from decoder below)
```json
{
    "data": {
        "id": "0E8C7F4D-B8F5-4DF9-832C-1B3C71FF3897",
        "name": "Postman",
        "birthday": 644182893.03527904,
        "createdAt": 644235524.69844198
    },
    "_links": {
        "self": "http://127.0.0.1:8080/v1/contacts/0E8C7F4D-B8F5-4DF9-832C-1B3C71FF3897"
    }
}
```

Now to the issue that I am currently facing. The right way to model these relationships in the client is the following (attention long swift file ahead :)),
(a.k.a when when trying to create the type information for `Contact.self` to produce the following three objects):

```swift
struct ContactID: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
    // MARK: - Properties
    public let id: UUID?
    
    // MARK: - Initializer
    public init(
        id: UUID?
    ) {
        self.id = id
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
    }
}

// MARK: - Model
public struct Contact: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case birthday = "birthday"
        case id = "id"
        case name = "name"
        case residencies = "residencies"
    }
    
    // MARK: - Properties
    public let birthday: Date
    public let id: UUID?
    public let name: String
    public let residencies: [Residence]
    
    // MARK: - Initializer
    public init(
        birthday: Date,
        id: UUID?,
        name: String,
        residencies: [Residence]
    ) {
        self.birthday = birthday
        self.id = id
        self.name = name
        self.residencies = residencies
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(birthday, forKey: .birthday)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(residencies, forKey: .residencies)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        birthday = try container.decode(Date.self, forKey: .birthday)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        // by default, I will always decode arrays with decodeIfPresent and init with empty if not present,
        // solves the inconsistency issue
        residencies = try container.decodeIfPresent([Residence].self, forKey: .residencies) ?? []
    }
}


// MARK: - Model
public struct Residence: Codable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case address = "address"
        case country = "country"
        case id = "id"
        case postalCode = "postalCode"
        case contact = "contact"
    }
    
    // MARK: - Properties
    public let address: String
    public let country: String
    public let id: UUID?
    public let postalCode: String
    public let contact: ContactID
    
    // MARK: - Initializer
    public init(
        address: String,
        country: String,
        id: UUID?,
        postalCode: String,
        contact: ContactID
    ) {
        self.address = address
        self.country = country
        self.id = id
        self.postalCode = postalCode
        self.contact = contact
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(address, forKey: .address)
        try container.encode(country, forKey: .country)
        try container.encode(id, forKey: .id)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(contact, forKey: .contact)
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try container.decode(String.self, forKey: .address)
        country = try container.decode(String.self, forKey: .country)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        postalCode = try container.decode(String.self, forKey: .postalCode)
        contact = try container.decode(ContactID.self, forKey: .contact)
    }
}
```
It is of course doable, because I am currently able to detect Fluent proeperties, and I am skipping relationship ones, even though as presented in this long markdown
they are required. I will test out all possible relationships and will adjust my TypeInformation to produce the right models 🤞
