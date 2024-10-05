//
//  LanguageModel.swift
//
//
//  Created by Thomas Benninghaus on 15.05.24.
//

import Vapor
import Fluent

public final class LanguageModel: Model {
    public static let schema = "languages"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "identifier")
    public var identifier: LanguageIdentifier
    
    @Field(key: "longname")
    public var longName: String

    @Children(for: \.$language)
    public var locales: [LocaleModel]
    
    public init() {}
    
    public init(id: UUID? = nil, name: String, identifier: LanguageIdentifier, longName: String) {
        self.id = id
        self.name = name
        self.identifier = identifier
        self.longName = longName
    }
    
    public convenience init(from language: LanguageDTO) {
        self.init(id: language.id, name: language.name, identifier: language.identifier, longName: language.longName)
    }
}

extension LanguageDTO {
    public init(model language: LanguageModel, localization: (String) -> String) {
        self.init(id: language.id, name: language.name, identifier: language.identifier, longName: language.longName, locales: LocalesDTO(many: language.locales, localization: localization), localization: localization)
    }
}

extension LanguagesDTO {
    public init(one: LanguageModel, localization: (String) -> String) {
        self.init(languages: [LanguageDTO(model: one, localization: localization)])
    }

    public init(many: [LanguageModel], localization: (String) -> String) {
        self.init(languages: many.compactMap { LanguageDTO(model: $0, localization: localization) })
    }
}
