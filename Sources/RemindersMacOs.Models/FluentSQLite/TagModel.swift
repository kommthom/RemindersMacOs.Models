//
//  TagModel.swift
//  
//
//  Created by Thomas Benninghaus on 22.01.24.
//

import Vapor
import Fluent

public final class TagModel: Model {
    public static let schema = "tags"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "description")
    public var description: String
    
    @OptionalField(key: "color")
    public var color: CodableColor?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Parent(key: "user_id")
    public var user: UserModel
    
    @Children(for: \.$defaultTag)
    public var projects: [ProjectModel]
    
    @Siblings(through: TaskTag.self, from: \.$tag, to: \.$task)
    public var tasks: [TaskModel]

    public init() {}
    
    public init(id: UUID? = nil, description: String, color: CodableColor?, for userId: UserModel.IDValue) {
        self.id = id
        self.description = description
        self.color = color
        self.$user.id = userId
    }
    
    public convenience init(from tag: TagDTO, for userId: UserModel.IDValue) {
        self.init(id: tag.id, description: tag.description, color: tag.color, for: userId)
    }
}

extension TagDTO {
    public init(model tag: TagModel) {
        /*self.id = tag.id
        self.description = tag.description
        self.color = tag.color*/
        self.init(id: tag.id!, description: tag.description, color: tag.color)
    }
}

extension TagsDTO {
    public init(one: TagModel) {
        //self.tags = [TagDTO(model: one)]
        self.init(tags: [TagDTO(model: one)])
    }

    public init(many: [TagModel]) {
        //self.tags = many.compactMap { TagDTO(model: $0) }
        self.init(tags: many.compactMap { TagDTO(model: $0) })
    }
}

extension TagSelectionDTO {
    public init(tag: TagModel, isSelected: Bool) {
        self.init(tag: TagDTO(model: tag), isSelected: isSelected)
    }
}

extension TagSelectionsDTO {
    public init(for taskId: TaskModel.IDValue, one: TagModel, isSelected: Bool) {
        /*self.taskId = taskId
        self.tagSelections = [TagSelectionDTO(tag: TagDTO(model: one), isSelected: isSelected)]*/
        self.init(taskId: taskId, tagSelections: [TagSelectionDTO(tag: TagDTO(model: one), isSelected: isSelected)])
    }

    public init(for taskId: TaskModel.IDValue, many: [(TagModel, Bool)]) {
        /*self.taskId = taskId
        self.tagSelections = many.compactMap { TagSelectionDTO(tag: $0, isSelected: $1) }*/
        self.init(taskId: taskId, tagSelections: many.compactMap { TagSelectionDTO(tag: $0, isSelected: $1) })
    }
}
