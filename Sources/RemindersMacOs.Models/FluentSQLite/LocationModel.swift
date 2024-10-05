//
//  LocationModel.swift
//  
//
//  Created by Thomas Benninghaus on 16.05.24.
//

import Vapor
import Fluent

public final class LocationModel: Model {
    public static let schema = "locations"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "description")
    public var description: String
    
    @Field(key: "identifier")
    public var identifier: String
    
    @Field(key: "timezone")
    public var timeZone: String
    
    @Children(for: \.$location)
    public var users: [UserModel]
    
    @Parent(key: "country_id")
    public var country: CountryModel
    
    public init() {}
    
    public init(id: UUID? = nil, countryId: CountryModel.IDValue, description: String, identifier: String, timeZone: String) {
        self.id = id
        self.$country.id = countryId
        self.description = description
        self.identifier = identifier
        self.timeZone = timeZone
    }
    
    public convenience init(from location: LocationDTO) {
        self.init(id: location.id, countryId: location.countryId, description: location.description, identifier: location.identifier, timeZone: location.timeZone)
    }
}

extension LocationDTO {
    public init(model location: LocationModel, localization: @escaping (_ key: String) -> String) {
        self.init(id: location.id, description: location.description, localizedDescription: localization(location.description), identifier: location.identifier, timeZone: location.timeZone, countryId: location.$country.id)
    }
}

extension LocationsDTO {
    public init(one: LocationModel, localization: @escaping (_ key: String) -> String) {
        self.init(locations: [LocationDTO(model: one, localization: localization)])
    }

    public init(many: [LocationModel], localization: @escaping (_ key: String) -> String) {
        self.init(locations: many.compactMap { LocationDTO(model: $0, localization: localization) })
    }
}
