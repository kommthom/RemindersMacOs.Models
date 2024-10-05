//
//  TaskTag.swift
//
//
//  Created by Thomas Benninghaus on 10.02.24.
//

import Vapor
import Fluent

public final class TaskTag: Model {
    public static let schema = "tasktags"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key: "task_id")
    public var task: TaskModel
    
    @Parent(key: "tagmodel_id")
    public var tag: TagModel
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
   
    public init() {}
    
    public init(id: UUID? = nil, taskId: TaskModel.IDValue, tagId: TagModel.IDValue) {
        self.id = id
        self.$task.id = taskId
        self.$tag.id = tagId
    }
}
