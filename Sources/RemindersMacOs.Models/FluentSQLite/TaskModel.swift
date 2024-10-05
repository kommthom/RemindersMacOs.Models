//
//  TaskModel.swift
//
//
//  Created by Thomas Benninghaus on 23.12.23.
//

import Vapor
import Fluent

public final class TaskModel: Model {
    public static let schema = "tasks"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "description")
    public var itemDescription: String
    
    @Field(key: "title")
    public var title: String
    
    @OptionalEnum(key: "priority")
    public var priority: Priority?
    
    @Field(key: "iscompleted")
    public var isCompleted: Bool
    
    @OptionalField(key: "homepage")
    public var homepage: String?
    
    @OptionalField(key: "dutypoints")
    public var dutyPoints: Int?
    
    @OptionalField(key: "funpoints")
    public var funPoints: Int?
    
    @OptionalField(key: "duration")
    var duration: Float?
    
    @Field(key: "iscalendar")
    var isCalendarEvent: Bool
    
    @OptionalField(key: "breakafter")
    public var breakAfter: Float?
    
    @OptionalField(key: "notification")
    public var notification: NotificationType?
    
    @OptionalField(key: "archivedPath")
    public var archivedPath: String?
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @OptionalParent(key: "parenttask_id")
    public var parentItem: TaskModel?
    
    @Children(for: \.$parentItem)
    public var children: [TaskModel]

    @OptionalChild(for: \.$task)
    public var repetition: RepetitionModel?
    
    @Children(for: \.$task)
    public var attachments: [AttachmentModel]
    
    @Children(for: \.$task)
    public var statusHistory: [HistoryModel]
    
    @Siblings(through: TaskRule.self, from: \.$task, to: \.$rule)
    public var rules: [RuleModel]
    
    @Siblings(through: TaskTag.self, from: \.$task, to: \.$tag)
    public var tags: [TagModel]
    
    @Parent(key: "project_id")
    public var project: ProjectModel
    
    public init() {}
    
    public init(id: UUID? = nil, itemDescription: String = "", title: String, priority: Priority? = nil, isCompleted: Bool = false, homepage: String? = nil, dutyPoints: Int? = nil, funPoints: Int? = nil, duration: Float? = nil, isCalendarEvent: Bool = false, breakAfter: Float? = nil, notification: NotificationType? = nil, archivedPath: String? = nil, parentItemId: UUID? = nil, projectId: ProjectModel.IDValue) {
        self.id = id
        self.itemDescription = itemDescription
        self.title = title
        self.priority = priority
        self.isCompleted = isCompleted
        self.homepage = homepage
        self.dutyPoints = dutyPoints
        self.funPoints = funPoints
        self.duration = duration
        self.isCalendarEvent = isCalendarEvent
        self.breakAfter = breakAfter
        self.notification = notification
        self.archivedPath = archivedPath
        self.$parentItem.id = parentItemId
        self.$project.id = projectId
    }
    
    public convenience init(from createTaskRequest: TaskDTO, for userId: UUID) {
        self.init(id: createTaskRequest.id, itemDescription: createTaskRequest.itemDescription, title: createTaskRequest.title, priority: createTaskRequest.priority, isCompleted: createTaskRequest.isCompleted, homepage: createTaskRequest.homepage, dutyPoints: createTaskRequest.dutyPoints, funPoints: createTaskRequest.funPoints, duration: createTaskRequest.duration, isCalendarEvent: createTaskRequest.isCalendarEvent, breakAfter: createTaskRequest.breakAfter, archivedPath: createTaskRequest.archivedPath, parentItemId: createTaskRequest.parentItemId, projectId: createTaskRequest.project_id)
    }
}

extension TaskDTO {
    public struct CreateArguments {
        public var createAttachments: ((Request, [AttachmentModel], AttachmentDTO.CreateArguments?) -> Future<AttachmentsDTO?>)?
        public var createRepetition: ((RepetitionModel, RepetitionDTO.CreateArguments?) -> RepetitionDTO?)?
        public var createChildren: ((Request, [TaskModel], CreateArguments?) -> Future<TasksDTO?>)?
        public var createHistories: (([HistoryModel]) -> HistoriesDTO?)?
        public var createRules: (([RuleModel]) -> RulesDTO?)?
        public var createTags: (([TagModel]) -> TagsDTO?)?
        public var createAttachmentsArgs: AttachmentDTO.CreateArguments?
        public var createRepetitionArgs: RepetitionDTO.CreateArguments?
        
        public init(
            createAttachments: ((Request, [AttachmentModel], AttachmentDTO.CreateArguments?) -> Future<AttachmentsDTO?>)? = nil,
            createRepetition: ((RepetitionModel, RepetitionDTO.CreateArguments?) -> RepetitionDTO?)? = nil,
            createChildren: ((Request, [TaskModel], CreateArguments?) -> Future<TasksDTO?>)? = nil,
            createHistories: (([HistoryModel]) -> HistoriesDTO?)? = nil,
            createRules: (([RuleModel]) -> RulesDTO?)? = nil,
            createTags: (([TagModel]) -> TagsDTO?)? = nil,
            createAttachmentsArgs: AttachmentDTO.CreateArguments? = nil,
            createRepetitionArgs: RepetitionDTO.CreateArguments? = nil) {
                self.createAttachments = createAttachments
                self.createRepetition = createRepetition
                self.createChildren = createChildren
                self.createHistories = createHistories
                self.createRules = createRules
                self.createTags = createTags
                self.createAttachmentsArgs = createAttachmentsArgs
                self.createRepetitionArgs = createRepetitionArgs
        }
    }
    
    public static func futureInit(
        _ req: Request,
        model task: TaskModel,
        args: CreateArguments?,
        localization: (String) -> String
    ) -> Future<TaskDTO> {
        var attachments: Future<AttachmentsDTO?> = if task.attachments.count == 0 {
            req.eventLoop.makeSucceededFuture(nil)
        } else if let _ = args?.createAttachments {
            args!
                .createAttachments!(req, task.attachments, args?.createAttachmentsArgs)
        } else {
                AttachmentUseCase()
                    .getManyDTOs(req, from: task.attachments, args: args?.createAttachmentsArgs)
        }
        return attachments
            .flatMap { attachmentsDto in
                var repetition: RepetitionDTO? = if task.repetition == nil {
                    nil
                } else if let _ = args?.createRepetition {
                    args!
                        .createRepetition!(task.repetition!, args?.createRepetitionArgs)
                } else {
                    RepetitionDTO(model: task.repetition!, args: args?.createRepetitionArgs)
                }
                var children: Future<TasksDTO?> = if let _ = args?.createChildren {
                    args!
                        .createChildren!(req, task.children, args)
                } else {
                    TasksDTO
                        .futureInit(req, many: task.children, args: args, localization: localization)
                }
                return children
                    .map { childrenDto in
                        var histories: HistoriesDTO? = if task.statusHistory.count == 0 {
                            nil
                        } else if let _ = args?.createHistories {
                            args!.createHistories!(task.statusHistory)
                        } else {
                            HistoriesDTO(many: task.statusHistory)
                        }
                        var rules: RulesDTO? = if task.rules.count == 0 {
                            nil
                        } else if let _ = args?.createRules {
                            args!.createRules!(task.rules)
                        } else {
                           RulesDTO(many: task.rules)
                        }
                        var tags: TagsDTO? = if task.tags.count == 0 {
                            nil
                        } else if let _ = args?.createTags {
                            args!.createTags!(task.tags)
                        } else {
                            TagsDTO(many: task.tags)
                        }
                        return TaskDTO(
                            id: task.id,
                            itemDescription: task.itemDescription,
                            title: task.title,
                            isCompleted: task.isCompleted,
                            homepage: task.homepage,
                            dutyPoints: task.dutyPoints,
                            funPoints: task.funPoints,
                            duration: task.duration,
                            isCalendarEvent: task.isCalendarEvent,
                            breakAfter: task.breakAfter,
                            notification: task.notification,
                            archivedPath: task.archivedPath,
                            parentItemId: task.parentItem != nil ? task.$parentItem.id : nil,
                            children: childrenDto,
                            repetition: repetition,
                            priority: task.priority,
                            attachments: attachmentsDto,
                            status: histories?.status,
                            statusHistory: histories,
                            rules: rules,
                            tags: tags,
                            project_id: task.project.id ?? UUID(),
                            localization: localization)
                    }
            }
    }
}

extension TasksDTO {
    public static func futureInit(
        _ req: Request,
        one: TaskModel,
        args: TaskDTO.CreateArguments?,
        localization: (String) -> String
    ) -> Future<[TaskDTO]> {
        return TaskDTO
            .futureInit(req, model: one, args: args, localization: localization)
            .map { [ $0 ] }
    }
    
    public static func futureInit(
        _ req: Request,
        many: [TaskModel],
        args: TaskDTO.CreateArguments?,
        localization: (String) -> String
    ) -> Future<TasksDTO?> {
        return many
            .map { task in
                TaskDTO
                    .futureInit(req, model: task, args: args, localization: localization)
            }
            .flatten(on: req.eventLoop)
            .map { TasksDTO(tasks: $0) }
    }
}

extension TaskGroupDTO {
    public static func futureInit(
        _ req: Request,
        groupName: String,
        groupDate: Date?,
        one: TaskModel,
        args: TaskDTO.CreateArguments?,
        localization: (String) -> String
    ) -> Future<TaskGroupDTO> {
        return TaskDTO
            .futureInit(req, model: one, args: args, localization: localization)
            .map { taskDTO in
                return self.init(groupName: groupName, groupDate: groupDate, tasks: [taskDTO])
            }
    }
    
    public static func futureInit(
        _ req: Request,
        groupName: String,
        groupDate: Date?,
        many: [TaskModel],
        args: TaskDTO.CreateArguments?,
        localization: (String) -> String
    ) -> Future<TaskGroupDTO> {
        return many
            .map { task in
                return TaskDTO
                    .futureInit(req, model: task, args: args, localization: localization)
            }
            .flatten(on: req.eventLoop)
            .map { taskDTOs in
                return self.init(groupName: groupName, groupDate: groupDate, tasks: taskDTOs)
            }
    }
}

extension TaskGroupsDTO {
    public static func futureInit(
        _ req: Request,
        groupName: String,
        groupDate: Date?,
        one: TaskModel,
        args: TaskDTO.CreateArguments?,
        localization: (String) -> String
    ) -> Future<TaskGroupsDTO> {
        return TaskGroupDTO
            .futureInit(req, groupName: groupName, groupDate: groupDate, one: one, args: args, localization: localization)
            .map { taskGroup in
                return TaskGroupsDTO(many: [taskGroup] )
            }
    }
    
    private static func append(futureDtoOriginal: Future<TaskGroupsDTO?>, futureDtoAppend: Future<TaskGroupsDTO>? = nil, dtoAppend: TaskGroupsDTO? = nil) -> Future<TaskGroupsDTO> {
        if let _ = futureDtoAppend {
            return futureDtoOriginal
                .flatMap { dtoOriginal in
                    if let _ = dtoOriginal {
                        var dtos = dtoOriginal!.taskGroups
                        return futureDtoAppend!
                            .map { taskGroups in
                                dtos.append(contentsOf: taskGroups.taskGroups)
                                return TaskGroupsDTO(many: dtos)
                            }
                    } else {
                        return futureDtoAppend!
                    }
                }
        } else if let taskGroups = dtoAppend {
            return futureDtoOriginal
                .map { dtoOriginal in
                    if let _ = dtoOriginal {
                        var dtos = dtoOriginal!.taskGroups
                        dtos.append(contentsOf: taskGroups.taskGroups)
                        return TaskGroupsDTO(many: dtos)
                    } else {
                        return taskGroups
                    }
                }
        } else {
            return futureDtoOriginal
                .map { $0! }
        }
    }
    
    public static func futureInit(
        _ req: Request,
        appendTo: Future<TaskGroupsDTO?>? = nil,
        many: [TaskModel],
        args: TaskDTO.CreateArguments?,
        localization: (String) -> String,
        makeGroupName: @escaping (Date?) -> String
    ) -> Future<TaskGroupsDTO> {
        var dtos: Future<TaskGroupsDTO?> = appendTo ?? req.eventLoop.makeSucceededFuture(TaskGroupsDTO(many: []))
        if many.count > 0 {
            return TasksDTO.futureInit(req, many: many, args: args, localization: localization)
                .flatMap { tasks in
                    return TaskGroupsDTO.append(
                        futureDtoOriginal: dtos,
                        dtoAppend: TaskGroupsDTO(from: tasks!, dateComponents: [.year, .month, .day], makeGroupName: makeGroupName)
                        )
                }
        } else { return dtos.map { $0! } }
    }
}

