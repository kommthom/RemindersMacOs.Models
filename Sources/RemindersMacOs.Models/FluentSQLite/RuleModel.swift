//
//  RuleModel.swift
//  
//
//  Created by Thomas Benninghaus on 23.01.24.
//

import Vapor
import Fluent

public final class RuleModel: Model {
    public static let schema = "rules"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "description")
    public var description: String
    
    @Enum(key: "ruletype")
    public var ruleType: RuleType
    
    @Enum(key: "actiontype")
    public var actionType: ActionType
    
    @OptionalField(key: "args")
    public var args: [String]?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Parent(key: "user_id")
    public var user: UserModel
    
    @Siblings(through: TaskRule.self, from: \.$rule, to: \.$task)
    public var tasks: [TaskModel]
    
    public init() {}
    
    public convenience init(from rule: RuleDTO, for userId: UserModel.IDValue) {
        self.init(id: rule.id, description: rule.description, ruleType: rule.ruleType, actionType: rule.actionType, args: rule.args, for: userId)
    }
    
    public init(id: UUID? = nil, description: String, ruleType: RuleType, actionType: ActionType, args: [String]? = nil, for userId: UserModel.IDValue) {
        self.id = id
        self.description = description
        self.ruleType = ruleType
        self.args = args
        self.actionType = actionType
        self.$user.id = userId
        self.tasks = .init()
    }
}

extension RuleDTO {
    public init(model rule: RuleModel) {
        self.init(id: rule.id!, description: rule.description, ruleType: rule.ruleType, actionType: rule.actionType, args: rule.args)
    }
}

extension RulesDTO {
    public init(one: RuleModel) {
        self.init(rules: [RuleDTO(model: one)])
    }

    public init(many: [RuleModel]) {
        self.init(rules: many.compactMap { RuleDTO(model: $0) })
    }
}

extension RuleSelectionDTO {
    public init(rule: RuleModel, isSelected: Bool) {
        self.init(rule: RuleDTO(model: rule), isSelected: isSelected)
    }
}

extension RuleSelectionsDTO {
    public init(for taskId: TaskModel.IDValue, one: RuleModel, isSelected: Bool) {
        self.init(taskId: taskId, ruleSelections: [RuleSelectionDTO(rule: RuleDTO(model: one), isSelected: isSelected)])
    }

    public init(for taskId: TaskModel.IDValue, many: [(RuleModel, Bool)]) {
        self.init(taskId: taskId, ruleSelections: many.compactMap { RuleSelectionDTO(rule: $0, isSelected: $1) })
    }
}
