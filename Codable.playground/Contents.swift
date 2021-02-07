import Foundation

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

// Changing Hierarchies

let json1 = """
    {
        "id": 123,
        "name": "Endeavor",
        "brewery": {
            "id": "sa001",
            "name": "Saint Arnold"
        }
    }
""".data(using: .utf8)!

struct Beer1: Codable {
    let id: Int
    let name: String
    let breweryId: String
    let breweryName: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brewery
    }

    enum BreweryCodingKeys: String, CodingKey {
        case id
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        let breweryContainer = try container.nestedContainer(keyedBy: BreweryCodingKeys.self, forKey: .brewery)
        breweryId = try breweryContainer.decode(String.self, forKey: .id)
        breweryName = try breweryContainer.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)

        var breweryContainer = container.nestedContainer(keyedBy: BreweryCodingKeys.self, forKey: .brewery)
        try breweryContainer.encode(breweryId, forKey: .id)
        try breweryContainer.encode(breweryName, forKey: .name)
    }
}

let decoder1 = JSONDecoder()
let beer1 = try! decoder1.decode(Beer1.self, from: json1)
//dump(beer1)
//print(String(data: try encoder.encode(beer1), encoding: .utf8)!)

let json2 = """
    {
        "id": 123,
        "name": "Endeavor",
        "brewery_id": "sa001",
        "brewery_name": "Saint Arnold"
    }
""".data(using: .utf8)!

struct Brewery2: Codable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "brewery_id"
        case name = "brewery_name"
    }
}

struct Beer2: Codable {
    let id: Int
    let name: String
    let brewery: Brewery2

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brewery
    }

    enum BreweryCodingKeys: String, CodingKey {
        case id
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brewery = try Brewery2(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)

        var breweryContainer = container.nestedContainer(keyedBy: BreweryCodingKeys.self, forKey: .brewery)
        try breweryContainer.encode(brewery.id, forKey: .id)
        try breweryContainer.encode(brewery.name, forKey: .name)
    }
}

let decoder2 = JSONDecoder()
let beer2 = try! decoder2.decode(Beer2.self, from: json2)
//dump(beer2)
//print(String(data: try encoder.encode(beer2), encoding: .utf8)!)

// Heterogeneous Arrays

let json3 = """
{
    "items": [
        {
            "type": "text",
            "id": 55,
            "date": "2021-01-08T14:38:24Z",
            "text": "This is a text feed item"
        },
        {
            "type": "image",
            "id": 56,
            "date": "2021-01-08T14:39:24Z",
            "image_url": "http://placekitten.com/200/300"
        }
    ]
}
""".data(using: .utf8)!

protocol DecodableClassFamily: Decodable {
    associatedtype Basetype: Decodable
    static var discriminator: AnyCodingKey { get }
    func getType() -> Basetype.Type
}

enum FeedItemClassFamily: String, DecodableClassFamily {
    case text
    case image

    typealias BaseType = FeedItem
    static var discriminator: AnyCodingKey = "type"

    func getType() -> FeedItem.Type {
        switch self {
        case .text: return TextFeedItem.self
        case .image: return ImageFeedItem.self
        }
    }
}

extension KeyedDecodingContainer {
    func decodeHeterogeneousArray<Family: DecodableClassFamily>(family: Family.Type, forKey key: K) throws -> [Family.Basetype] {
        var itemsContainer = try self.nestedUnkeyedContainer(forKey: key)
        var itemsContainerCopy = itemsContainer

        var items: [Family.Basetype] = []

        while !itemsContainer.isAtEnd {
            let typeContainer = try itemsContainer.nestedContainer(keyedBy: AnyCodingKey.self)
            let family = try typeContainer.decode(Family.self, forKey: Family.discriminator)
            let type = family.getType()
            let item = try itemsContainerCopy.decode(type)
            items.append(item)
        }

        return items
    }
}

class FeedItem: Codable {
    let type: String
    let id: Int
    let date: Date
}

class TextFeedItem: FeedItem {
    let text: String

    enum CodingKeys: String, CodingKey {
        case text
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try super.encode(to: encoder)
    }
}

class ImageFeedItem: FeedItem {
    let imageUrl: URL

    enum CodingKeys: String, CodingKey {
        case imageUrl
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageUrl, forKey: .imageUrl)
        try super.encode(to: encoder)
    }
}

struct AnyCodingKey: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        stringValue = String(intValue)
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(stringValue: value)!
    }
}

struct Feed: Codable {
    let items: [FeedItem]

    enum CodingKeys: String, CodingKey {
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeHeterogeneousArray(family: FeedItemClassFamily.self, forKey: .items)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
    }
}

let decoder3 = JSONDecoder()
decoder3.keyDecodingStrategy = .convertFromSnakeCase
decoder3.dateDecodingStrategy = .iso8601

let feed = try decoder3.decode(Feed.self, from: json3)
dump(feed)
print(String(data: try encoder.encode(feed), encoding: .utf8)!)

// Property Wrappers
