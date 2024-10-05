//
//  TaskRule.swift
//  
//
//  Created by Thomas Benninghaus on 23.01.24.
//

import Vapor
import Fluent

public final class TaskRule: Model {
    public static let schema = "taskrules"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key: "task_id")
    public var task: TaskModel
    
    @Parent(key: "rulemodel_id")
    public var rule: RuleModel
    
    @OptionalField(key: "args")
    public var args: [String]?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    public init() {}
    
    public init(id: UUID? = nil, taskId: TaskModel.IDValue, ruleId: RuleModel.IDValue, args: [String]? = nil) {
        self.id = id
        self.$task.id = taskId
        self.$rule.id = ruleId
        self.args = args
    }
}
