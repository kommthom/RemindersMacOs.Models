//
//  RepetitionModel.swift
//  
//
//  Created by Thomas Benninghaus on 22.01.24.
//

import Vapor
import Fluent

public final class RepetitionModel: Model {
    public static let schema = "repetitions"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "iteration")
    public var iteration: Int
    
    @Field(key: "duedate")
    public var dueDate: Date
    
    @Field(key: "fromdone")
    public var fromDone: Bool
    
    @Field(key: "repetitionnumber")
    public var repetitionNumber: Int
    
    @OptionalField(key: "repetitionjson")
    public var repetitionJSON: String?
    
    @OptionalField(key: "repetitionbegin")
    public var repetitionBegin: Date?
    
    @OptionalField(key: "repetitionend")
    public var repetitionEnd: Date?
    
    @OptionalField(key: "maxiterations")
    public var maxIterations: Int?
    
    @Field(key: "repetitiontext")
    public var repetitionText: String
    
    @OptionalField(key: "notification")
    public var notification: NotificationType?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Siblings(through: RepetitionTimePeriod.self, from: \.$repetition, to: \.$timePeriod)
    public var timePeriods: [TimePeriodModel]
    
    @Parent(key: "task_id")
    public var task: TaskModel
    
    public init() {}
    
    public init(id: UUID? = nil, iteration: Int, dueDate: Date, fromDone: Bool = false, repetitionNumber: Int, repetitionJSON: String?, repetitionBegin: Date?, repetitionEnd: Date?, maxIterations: Int?, repetitionText: String, notification: NotificationType?, taskId: TaskModel.IDValue) {
        self.id = id
        self.iteration = iteration
        self.dueDate = dueDate
        self.fromDone = fromDone
        self.repetitionNumber = repetitionNumber
        self.repetitionJSON = repetitionJSON
        self.repetitionBegin = repetitionBegin
        self.repetitionEnd = repetitionEnd
        self.maxIterations = maxIterations
        self.repetitionText = repetitionText
        self.notification = notification
        self.$task.id = taskId
    }
    
    public convenience init(from repetitionDTO: RepetitionDTO) {
        self.init(id: repetitionDTO.id, iteration: repetitionDTO.iteration, dueDate: repetitionDTO.dueDate, fromDone: repetitionDTO.fromDone, repetitionNumber: repetitionDTO.repetitionNumber, repetitionJSON: repetitionDTO.repetitionJSON, repetitionBegin: repetitionDTO.repetitionBegin, repetitionEnd: repetitionDTO.repetitionEnd, maxIterations: repetitionDTO.maxIterations, repetitionText: repetitionDTO.repetitionText, notification: repetitionDTO.notification, taskId: repetitionDTO.task_id)
    }
}

extension RepetitionDTO {
    public struct CreateArguments {
        public var createTimePeriods: (([TimePeriodModel]) -> TimePeriodsDTO?)?
        
        public init(
            createTimePeriods: (([TimePeriodModel]) -> TimePeriodsDTO?)? = nil) {
                self.createTimePeriods = createTimePeriods
        }
    }
    
    public init(
        model repetition: RepetitionModel,
        args: CreateArguments?
    ) {
        var timePeriods: TimePeriodsDTO? = if repetition.timePeriods.count == 0 {
            nil
        } else if let _ = args?.createTimePeriods {
            args!.createTimePeriods!(repetition.timePeriods)
        } else {
            TimePeriodsDTO(many: repetition.timePeriods)
        }
        self.init(
            id: repetition.id,
            iteration: repetition.iteration,
            dueDate: repetition.dueDate,
            fromDone: repetition.fromDone,
            repetitionNumber: repetition.repetitionNumber,
            repetitionJSON: repetition.repetitionJSON,
            repetitionBegin: repetition.repetitionBegin,
            repetitionEnd: repetition.repetitionEnd,
            maxIterations: repetition.maxIterations,
            repetitionText: repetition.repetitionText,
            timePeriods: timePeriods,
            notification: repetition.notification,
            taskId: repetition.$task.id)
    }
}

extension RepetitionsDTO {
   /// Create AttachmentsContext with only one attachment from a model: not used
    public init(one: RepetitionModel, args: RepetitionDTO.CreateArguments?) {
        self.init(repetitions: [RepetitionDTO(model: one, args: args)])
    }

    /// Create AttachmentsContext with many attachments from a model
    public init(many: [RepetitionModel], args: RepetitionDTO.CreateArguments?) {
        self.init(repetitions: many.compactMap { RepetitionDTO(model: $0, args: args) })
    }
}
