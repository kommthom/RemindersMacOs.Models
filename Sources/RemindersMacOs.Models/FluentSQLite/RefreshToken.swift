//
//  RefreshToken.swift
//
//
//  Created by Thomas Benninghaus on 11.12.23.
//

import Vapor
import Fluent

public final class RefreshToken: Model {
    public static let schema = "user_refresh_tokens"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "token")
    public var token: String
    
    @Parent(key: "user_id")
    public var user: UserModel
    
    @Field(key: "expires_at")
    public var expiresAt: Date
    
    @Field(key: "issued_at")
    public var issuedAt: Date
    
    public init() {}
    
    public init(id: UUID? = nil, token: String, userID: UUID, expiresAt: Date = Date().addingTimeInterval(Constants.REFRESH_TOKEN_LIFETIME), issuedAt: Date = Date()) {
        self.id = id
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
        self.issuedAt = issuedAt
    }
}
