//
//  RepetitionTimePeriod.swift
//
//
//  Created by Thomas Benninghaus on 17.02.24.
//

import Vapor
import Fluent

public final class RepetitionTimePeriod: Model {
    public static let schema = "repetitiontimeperiods"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key: "repetition_id")
    public var repetition: RepetitionModel
    
    @Parent(key: "timeperiodmodel_id")
    public var timePeriod: TimePeriodModel
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
   
    public init() {}
    
    public init(id: UUID? = nil, repetitionId: RepetitionModel.IDValue, timePeriodId: TimePeriodModel.IDValue) {
        self.id = id
        self.$repetition.id = repetitionId
        self.$timePeriod.id = timePeriodId
    }
}
