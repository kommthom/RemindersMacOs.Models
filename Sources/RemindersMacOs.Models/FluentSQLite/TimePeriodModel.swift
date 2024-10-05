//
//  TimePeriodModel.swift
//  
//
//  Created by Thomas Benninghaus on 22.01.24.
//

import Vapor
import Fluent

public final class TimePeriodModel: Model {
    public static let schema = "timeperiods"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "typeoftime")
    public var typeOfTime: TypeOfTime
    
    @Field(key: "from")
    public var from: String
    
    @Field(key: "to")
    public var to: String
    
    @OptionalField(key: "day")
    public var day: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    @OptionalParent(key: "parent_id")
    public var parent: TimePeriodModel?
    
    @Siblings(through: RepetitionTimePeriod.self, from: \.$timePeriod, to: \.$repetition)
    public var repetitions: [RepetitionModel]
    
    @Parent(key: "user_id")
    public var user: UserModel
    
    public init() {}
    
    public init(id: UUID? = nil, typeOfTime: TypeOfTime, from: String, to: String, day: Date?, parentId: TimePeriodModel.IDValue?, for userId: UserModel.IDValue) {
        self.id = id
        self.typeOfTime = typeOfTime
        self.from = from
        self.to = to
        self.day = day
        self.$parent.id = parentId
        self.$user.id = userId
    }
    
    public convenience init(from timePeriod: TimePeriodDTO, for userId: UserModel.IDValue) {
        self.init(id: timePeriod.id, typeOfTime: timePeriod.typeOfTime, from: timePeriod.from, to: timePeriod.to, day: timePeriod.day, parentId: timePeriod.parentId, for: userId)
    }
}

extension TimePeriodDTO {
    public init(model timePeriod: TimePeriodModel) {
        self.init(id: timePeriod.id, typeOfTime: timePeriod.typeOfTime, from: timePeriod.from, to: timePeriod.to, day: timePeriod.day, parentId: timePeriod.$parent.id)
    }
}

extension TimePeriodsDTO {
    public init(one: TimePeriodModel) {
        self.init(timePeriods: [TimePeriodDTO(model: one)])
    }

    public init(many: [TimePeriodModel]) {
        self.init(timePeriods: many.compactMap { TimePeriodDTO(model: $0) })
    }
}

extension TimePeriodSelectionDTO {
    public init(timePeriod: TimePeriodModel, isSelected: Bool) {
        self.init(timePeriod: TimePeriodDTO(model: timePeriod), isSelected: isSelected)
    }
}

extension TimePeriodSelectionsDTO {
    public init(for taskId: TaskModel.IDValue, one: TimePeriodModel, isSelected: Bool) {
        self.init(taskId: taskId, timePeriodSelections: [TimePeriodSelectionDTO(timePeriod: TimePeriodDTO(model: one), isSelected: isSelected)])
    }

    public init(for taskId: TaskModel.IDValue, many: [(TimePeriodModel, Bool)]) {
        self.init(taskId: taskId, timePeriodSelections: many.compactMap { TimePeriodSelectionDTO(timePeriod: $0, isSelected: $1) })
    }
}
