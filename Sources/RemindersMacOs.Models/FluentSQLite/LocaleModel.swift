//
//  LocaleModel.swift
//  
//
//  Created by Thomas Benninghaus on 15.05.24.
//

import Vapor
import Fluent

public final class LocaleModel: Model {
    public static let schema = "locales"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String
    
    @Field(key: "identifier")
    public var identifier: LocaleIdentifier
    
    @Field(key: "longname")
    public var longName: String
    
    @Field(key: "timefirst")
    public var timeFirst: Bool
    
    @Field(key: "timeseparator")
    public var timeSeparator: DateRelative.FormatStyle.TimeSeparator
    
    @Field(key: "timezoneseparator")
    public var timeZoneSeparator: DateRelative.FormatStyle.TimeZoneSeparator
    
    @Field(key: "dateseparator")
    public var dateSeparator: DateRelative.FormatStyle.DateSeparator
    
    @Field(key: "datetimeseparator")
    public var dateTimeSeparator: DateRelative.FormatStyle.DateTimeSeparator

    @Field(key: "timeformatstring")
    public var timeFormatString: String
    
    @Field(key: "standarddateformatstring")
    public var standardDateFormatString: String
    
    @Field(key: "dateformatstring")
    public var dateFormatString: String
    
    @Siblings(through: CountryLocale.self, from: \.$locale, to: \.$country)
    public var countries: [CountryModel]
    
    @Children(for: \.$locale)
    public var users: [UserModel]
    
    @Parent(key: "language_id")
    public var language: LanguageModel
    
    public init() {}
    
    public init(id: UUID? = nil, name: String, identifier: LocaleIdentifier, longName: String, timeFirst: Bool, timeSeparator: DateRelative.FormatStyle.TimeSeparator, timeZoneSeparator: DateRelative.FormatStyle.TimeZoneSeparator, dateSeparator: DateRelative.FormatStyle.DateSeparator, dateTimeSeparator: DateRelative.FormatStyle.DateTimeSeparator, timeFormatString: String, standardDateFormatString: String, dateFormatString: String, languageId: LanguageModel.IDValue) {
        self.id = id
        self.name = name
        self.identifier = identifier
        self.longName = longName
        self.timeFirst = timeFirst
        self.timeSeparator = timeSeparator
        self.timeZoneSeparator = timeZoneSeparator
        self.dateSeparator = dateSeparator
        self.dateTimeSeparator = dateTimeSeparator
        self.timeFormatString = timeFormatString
        self.standardDateFormatString = standardDateFormatString
        self.dateFormatString = dateFormatString
        self.$language.id = languageId
    }
    
    public convenience init(from locale: LocaleDTO) {
        self.init(id: locale.id, name: locale.name, identifier: locale.identifier, longName: locale.longName, timeFirst: locale.timeFirst, timeSeparator: locale.timeSeparator, timeZoneSeparator: locale.timeZoneSeparator, dateSeparator: locale.dateSeparator, dateTimeSeparator: locale.dateTimeSeparator, timeFormatString: timeFormatString, standardDateFormatString: locale.standardDateFormatString, dateFormatString: locale.dateFormatString, languageId: locale.language.id!)
    }
}

extension LocaleDTO {
    public init(model locale: LocaleModel, localization: (String) -> String) {
        self.init(id: locale.id, name: locale.name, identifier: locale.identifier, longName: locale.longName, timeFirst: locale.timeFirst, timeSeparator: locale.timeSeparator, timeZoneSeparator: locale.timeZoneSeparator, dateSeparator: locale.dateSeparator, dateTimeSeparator: locale.dateTimeSeparator, timeFormatString: timeFormatString, standardDateFormatString: locale.standardDateFormatString, dateFormatString: locale.dateFormatString, language: LanguageDTO(model: locale.language, localization: localization), localization: localization)
    }
}

extension LocalesDTO {
    public init(one: LocaleModel, localization: (String) -> String) {
        self.init(locales: [LocaleDTO(model: one, localization: localization)])
    }

    public init(many: [LocaleModel], localization: (String) -> String) {
        self.init(locales: many.compactMap { LocaleDTO(model: $0, localization: localization) })
    }
}
