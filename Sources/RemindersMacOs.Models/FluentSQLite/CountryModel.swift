//
//  CountryModel.swift
//  
//
//  Created by Thomas Benninghaus on 16.05.24.
//

import Vapor
import Fluent

public final class CountryModel: Model {
    public static let schema = "countries"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "description")
    public var description: String
    
    @Field(key: "identifier")
    public var identifier: String
    
    @Children(for: \.$country)
    public var locations: [LocationModel]
    
    @Siblings(through: CountryLocale.self, from: \.$country, to: \.$locale)
    public var locales: [LocaleModel]
    
    @Field(key: "locale_id")
    public var defaultLocaleId: LocaleModel.IDValue
    
    public init() {}
    
    public init(id: UUID? = nil, description: String, identifier: String, defaultLocaleId: LocaleModel.IDValue) {
        self.id = id
        self.defaultLocaleId = defaultLocaleId
        self.description = description
        self.identifier = identifier
    }
    
    public convenience init(from country: CountryDTO) {
        self.init(id: country.id, description: country.description, identifier: country.identifier, defaultLocaleId: country.defaultLocale.id!)
    }
}

extension CountryDTO {
    public init(model country: CountryModel, localization: @escaping (String) -> String) {
        self.init(
            id: country.id,
            description: country.description,
            identifier: country.identifier,
            locales: LocalesDTO(many: country.locales, localization: localization),
            defaultLocale: LocaleDTO(model: country.locales.first(where: { $0.id == country.defaultLocaleId } )!, localization: localization ),
            localization: localization
        )
    }
}

extension CountriesDTO {
    public init(one: CountryModel, localization: @escaping (String) -> String) {
        self.init(countries: [CountryDTO(model: one, localization: localization)])
    }

    public init(many: [CountryModel], localization: @escaping (String) -> String) {
        self.init(countries: many.compactMap { CountryDTO(model: $0, localization: localization) })
    }
}

