//
//  CountryLocale.swift
//  
//
//  Created by Thomas Benninghaus on 16.05.24.
//

import Vapor
import Fluent

public final class CountryLocale: Model {
    public static let schema = "countrylocales"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key: "country_id")
    public var country: CountryModel
    
    @Parent(key: "locale_id")
    public var locale: LocaleModel
    
    public init() {}
    
    public init(id: UUID? = nil, countryId: CountryModel.IDValue, localeId: LocaleModel.IDValue) {
        self.id = id
        self.$country.id = countryId
        self.$locale.id = localeId
    }
}
