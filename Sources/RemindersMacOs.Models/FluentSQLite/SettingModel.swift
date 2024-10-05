//
//  SettingModel.swift
//  
//
//  Created by Thomas Benninghaus on 30.01.24.
//

import Vapor
import Fluent

public final class SettingModel: Model {
    public static let schema = "settings"

    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "sortorder")
    public var sortOrder: Int
    
    @Enum(key: "scope")
    public var scope: ScopeType
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "description")
    public var description: String
    
    @OptionalField(key: "image")
    public var image: String?
    
    @Enum(key: "valuetype")
    public var valueType: SettingValueType
    
    @OptionalField(key: "boolvalue")
    public var boolValue: Bool?
    
    @OptionalField(key: "intvalue")
    public var intValue: Int?
    
    @OptionalField(key: "stringvalue")
    public var stringValue: String?
    
    @OptionalField(key: "idvalue")
    public var idValue: UUID?
    
    @OptionalField(key: "jsonvalue")
    public var jsonValue: String?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Parent(key: "user_id")
    public var user: UserModel
    
    public init() {}
    
    public init(id: UUID? = nil, sortOrder: Int, scope: ScopeType, name: String, description: String, image: String? = nil, valueType: SettingValueType, boolValue: Bool? = nil, intValue: Int? = nil, stringValue: String? = nil, idValue: UUID? = nil, jsonValue: String? = nil, userId: UserModel.IDValue) {
        self.id = id
        self.sortOrder = sortOrder
        self.scope = scope
        self.name = name
        self.description = description
        self.image = image
        self.valueType = valueType
        self.boolValue = boolValue
        self.intValue = intValue
        self.stringValue = stringValue
        self.idValue = idValue
        self.jsonValue = jsonValue
        self.$user.id = userId
    }
    
    public convenience init(from settingDTO: SettingDTO, for userId: UUID) {
        self.init(
            id: settingDTO.id,
            sortOrder: settingDTO.sortOrder,
            scope: settingDTO.scope,
            name: settingDTO.name,
            description: settingDTO.description,
            image: settingDTO.image,
            valueType: settingDTO.valueType,
            boolValue: settingDTO.boolValue,
            intValue: settingDTO.intValue,
            stringValue: settingDTO.stringValue,
            idValue: settingDTO.idValue,
            jsonValue: settingDTO.jsonValue,
            userId: userId
        )
    }
}

extension SettingDTO {
    public init(model setting: SettingModel) {
        /*self.id = setting.id!
        self.sortOrder = setting.sortOrder
        self.scope = setting.scope
        self.name = setting.name
        self.description = setting.description
        self.image = setting.image
        self.valueType = setting.valueType
        self.boolValue = setting.boolValue
        self.intValue = setting.intValue
        self.stringValue = setting.stringValue
        self.idValue = setting.idValue
        self.jsonValue = setting.jsonValue*/
        self.init(id: setting.id!, sortOrder: setting.sortOrder, scope: setting.scope, name: setting.name, description: setting.description, image: setting.image, valueType: setting.valueType, boolValue: setting.boolValue, intValue: setting.intValue, stringValue: setting.stringValue, idValue: setting.idValue, jsonValue: setting.jsonValue)
    }
}

extension SettingsDTO {
    /// Create SettingsContext with only one setting from a model: not used
    public init(one: SettingModel) {
        //self.settings = [SettingDTO(model: one)]
        self.init(settings: [SettingDTO(model: one)])
    }

    /// Create SettingsContext with many settings from a model
    public init(many: [SettingModel]) {
        //self.settings = many.compactMap { SettingDTO(model: $0) }
        self.init(settings: many.compactMap { SettingDTO(model: $0) })
    }
}
