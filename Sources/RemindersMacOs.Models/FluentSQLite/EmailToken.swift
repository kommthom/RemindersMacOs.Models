//
//  EmailToken.swift
//
//
//  Created by Thomas Benninghaus on 11.12.23.
//

import Vapor
import Fluent

public final class EmailToken: Model {
    public static let schema = "user_email_tokens"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: UserModel
    
    @Field(key: "token")
    public var token: String
    
    @Field(key: "expires_at")
    public var expiresAt: Date
    
    public init() {}
    
    public init(id: UUID? = nil, userID: UUID, token: String, expiresAt: Date = Date().addingTimeInterval(Constants.EMAIL_TOKEN_LIFETIME)) {
        self.id = id
        self.$user.id = userID
        self.token = token
        self.expiresAt = expiresAt
    }
}
