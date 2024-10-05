//
//  HistoryModel.swift
//
//
//  Created by Thomas Benninghaus on 23.01.24.
//

import Vapor
import Fluent

public final class HistoryModel: Model {
    public static let schema = "history"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Timestamp(key: "timestamp", on: .create)
    public var timestamp: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Enum(key: "historytype")
    public var historyType: HistoryType
    
    @Parent(key: "task_id")
    public var task: TaskModel
    
    public init() {}
    
    public init(id: UUID? = nil, historyType: HistoryType, taskId: TaskModel.IDValue) {
        self.id = id
        self.historyType = historyType
        self.$task.id = taskId
    }
    
    public convenience init(from historyDTO: HistoryDTO) {
        self.init(id: historyDTO.id, historyType: historyDTO.historyType, taskId: historyDTO.task_id)
    }
}

extension HistoryDTO {
    public init(model history: HistoryModel) {
        /*self.id = history.id
        self.historyType = history.historyType
        self.task_id = history.$task.id*/
        self.init(id: history.id, historyType: history.historyType, taskId: history.$task.id)
    }
}

extension HistoriesDTO {
    public init(one: HistoryModel) {
        //self.histories = [HistoryDTO(model: one)]
        self.init(histories: [HistoryDTO(model: one)])
    }

    public init(many: [HistoryModel]) {
        //self.histories = many.compactMap { HistoryDTO(model: $0) }
        self.init(histories: many.compactMap { HistoryDTO(model: $0) })
    }
}
