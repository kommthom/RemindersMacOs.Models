//
//  LocalizationModel.swift
//
//
//  Created by Thomas Benninghaus on 13.05.24.
//

import Vapor
import Fluent

public final class LocalizationModel: Model {
    public static let schema = "localizations"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "languagemodel")
    public var languageModel: ModelType
    
    @Field(key: "languagecode")
    public var languageCode: String
    
    @OptionalField(key: "enum") // reference keyword
    public var enumKey: Int?
    
    @Field(key: "key")
    public var key: String
    
    @OptionalField(key: "value")
    public var value: String?
    
    @OptionalField(key: "pluralized")
    public var pluralized: [String: String]?

    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    public init() {}
    
    public init(id: UUID? = nil, languageModel: ModelType, languageCode: String, enumKey: KeyWord?, key: String, value: String?, pluralized: [String: String]? = nil) {
        self.id = id
        self.languageModel = languageModel
        self.languageCode = languageCode
        self.enumKey = enumKey?.rawValue
        self.key = key
        self.value = value
        self.pluralized = pluralized
    }
    
    public convenience init(from localization: LocalizationDTO) {
        self.init(id: UUID(), languageModel: localization.languageModel, languageCode:  localization.languageCode, enumKey: localization.enumKey, key: localization.key, value: localization.value, pluralized: localization.pluralized)
    }
}

extension LocalizationDTO {
public init(model localization: LocalizationModel) {
    self.init(id: localization.id, languageModel: localization.languageModel, languageCode: localization.languageCode, enumKey: localization.enumKey == nil ? nil : KeyWord(rawValue: localization.enumKey!), key: localization.key, value: localization.value, pluralized: localization.pluralized)
}
}

extension LocalizationsDTO {
public init(one: LocalizationModel) {
    self.init(localizations: [LocalizationDTO(model: one)])
}

public init(many: [LocalizationModel]) {
    self.init(localizations: many.compactMap { LocalizationDTO(model: $0) })
}
}
