//
//  UserModel.swift
//
//
//  Created by Thomas Benninghaus on 11.12.23.
//

import Vapor
import Fluent
import JWT
import UserDTOs

public final class UserModel: Model, Authenticatable {
    public static let schema = "users"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "full_name")
    public var fullName: String
    
    @Field(key: "email")
    public var email: String
    
    @Field(key: "image_url")
    public var imageURL: String?
    
    @Field(key: "password_hash")
    public var passwordHash: String
    
    @Field(key: "is_admin")
    public var isAdmin: Bool
    
    @Field(key: "is_email_verified")
    public var isEmailVerified: Bool
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Children(for: \.$user)
    public var settings: [SettingModel]
    
    @Children(for: \.$user)
    public var projects: [ProjectModel]
    
    @Children(for: \.$user)
    public var tags: [TagModel]
    
    @Parent(key: "locale")
    public var locale: LocaleModel
    
    @Parent(key: "location")
    public var location: LocationModel
    
    public init() {}
    
    public init(id: UUID? = nil, fullName: String, email: String, passwordHash: String, isAdmin: Bool = false, isEmailVerified: Bool = false, imageURL: String? = nil, localeId: UUID, locationId: UUID) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
        self.isEmailVerified = isEmailVerified
        self.imageURL = imageURL
        self.$locale.id = localeId
        self.$location.id = locationId
    }
    
    public convenience init(from payload: Payload) {
		self.init(id: payload.userID.rawValue, fullName: payload.fullName, email: payload.email, passwordHash: "", isAdmin: payload.isAdmin, imageURL: payload.imageURL, localeId: payload.locale.id?.rawValue!, locationId: payload.location.id!)
    }
    
    public convenience init(from register: UserDTO, hash: String) throws {
		self.init(fullName: register.fullName, email: register.email, passwordHash: hash, imageURL: register.imageURL, localeId: register.locale.id!, locationId: register.locale.id?.rawValue!)
    }
}

extension Payload {
    public init(with user: UserModel, localization: @escaping (String) -> String) throws {
        self.init(userID: try user.requireID(), fullName: user.fullName, email: user.email, isAdmin: user.isAdmin, imageURL: user.imageURL, locale: LocaleDTO(model: user.locale, localization: localization), location: LocationDTO(model: user.location, localization: localization), exp: ExpirationClaim(value: Date().addingTimeInterval(Constants.ACCESS_TOKEN_LIFETIME)))
    }
}

extension UserDTO {
    public init(model user: UserModel, localization: @escaping (String) -> String) {
        self.init(id: user.id, fullName: user.fullName, email: user.email, imageURL: user.imageURL, password: "********", confirmPassword: nil, isAdmin: user.isAdmin, locale: LocaleDTO(model: user.locale, localization: localization), location: LocationDTO(model: user.location, localization: localization))
    }
}

extension UsersDTO {
    public init(one: UserModel, localization: @escaping (String) -> String) {
        self.init(users: [UserDTO(model: one, localization: localization)])
    }

    public init(many: [UserModel], localization: @escaping (String) -> String) {
        self.init(users: many.compactMap { UserDTO(model: $0, localization: localization) })
    }
}
