import Foundation

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

// Changing Hierarchies

let json = """
    {
        "id": 123,
        "name": "Endeavor",
        "brewery": {
            "id": "sa001",
            "name": "Saint Arnold"
        }
    }
""".data(using: .utf8)!

struct Beer: Codable {
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

let decoder = JSONDecoder()
let beer = try! decoder.decode(Beer.self, from: json)
print(beer)
print(String(data: try encoder.encode(beer), encoding: .utf8)!)

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
print(beer2)
print(String(data: try encoder.encode(beer2), encoding: .utf8)!)

