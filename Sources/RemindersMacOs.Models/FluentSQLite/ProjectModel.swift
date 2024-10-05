//
//  ProjectModel.swift
//  
//
//  Created by Thomas Benninghaus on 23.12.23.
//

import Vapor
import Fluent

public final class ProjectModel: Model {
    public static let schema = "projects"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: UserModel
    
    @Field(key: "left")
    public var leftKey: Int
    
    @Field(key: "right")
    public var rightKey: Int
    
    @Field(key: "name")
    public var name: String
    
    @OptionalField(key: "color")
    public var color: CodableColor?
    
    @Field(key: "iscompleted")
    public var isCompleted: Bool
    
    @Field(key: "level")
    public var level: Int
    
    @Field(key: "path")
    public var path: String
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @OptionalParent(key: "tagmodel_id")
    public var defaultTag: TagModel?
    
    @Children(for: \.$project)
    public var items: [TaskModel]
    
    @Field(key: "issystem")
    public var isSystem: Bool
    
    public init() {}
    
    public init(id: UUID? = nil, userId: UserModel.IDValue, leftKey: Int, rightKey: Int, name: String, color: CodableColor?, isCompleted: Bool = false, level: Int = 0, path: String? = nil, defaultTagId: TagModel.IDValue? = nil, isSystem: Bool = false) {
        self.id = id
        self.$user.id = userId
        self.leftKey = leftKey
        self.rightKey = rightKey
        self.name = name
        self.color = color
        self.isCompleted = isCompleted
        self.level = level
        self.path = path ?? ""
        self.$defaultTag.id = defaultTagId
        self.isSystem = isSystem
    }
    
    convenience init(model project: ProjectDTO, userId: UUID) {
        self.init(id: project.id!, userId: userId, leftKey: project.leftKey, rightKey: project.rightKey, name: project.name, color: project.color, isCompleted: project.isCompleted, level: project.level, path: project.path, defaultTagId: project.defaultTag?.id)
    }
}

extension ProjectDTO {
    public init(model project: ProjectModel) {
        self.init(id: project.id!, leftKey: project.leftKey, rightKey: project.rightKey, name: project.name, color: project.color, isCompleted: project.isCompleted, level: project.level, path: project.path, defaultTagId: project.$defaultTag.id, items: project.items.compactMap { TaskDTO(model: $0) })
    }
}

extension ProjectsDTO {
    public init(one: ProjectModel) {
        self.init(projects: [ProjectDTO(model: one)])
    }

    public init(many: [ProjectModel]) {
        self.init(projects: many.compactMap { ProjectDTO(model: $0) })
    }
}
