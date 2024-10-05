//
//  AttachmentModel.swift
//
//
//  Created by Thomas Benninghaus on 22.01.24.
//

import Vapor
import Fluent
import RemindersMacOs.DTOs 

public final class AttachmentModel: Model {
    public static let schema = "attachments"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "comment")
    public var comment: String
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Children(for: \.$attachment)
    public var files: [UploadModel]
    
    @Parent(key: "task_id")
    public var task: TaskModel
    
    public init() {}
    
    public init(id: UUID? = nil, comment: String, taskId: TaskModel.IDValue) {
        self.id = id
        self.comment = comment
        self.$task.id = taskId
    }
    
    public convenience init(from attachmentDTO: AttachmentDTO) {
        self.init(id: attachmentDTO.id, comment: attachmentDTO.comment, taskId: attachmentDTO.task_id)
    }
}

extension AttachmentDTO {
    public struct CreateArguments {
        public var createUploads: ((Request, [UploadModel]) -> Future<UploadsDTO?>)?
        
        public init(
            createUploads: ((Request, [UploadModel]) -> Future<UploadsDTO?>)? = nil) {
                self.createUploads = createUploads
        }
    }

    public static func futureInit(
        _ req: Request,
        model attachment: AttachmentModel,
        args: CreateArguments? = nil
    ) -> Future<AttachmentDTO?> {
        var uploads: Future<UploadsDTO?> = if attachment.files.count == 0 {
            req.eventLoop.makeSucceededFuture(nil)
        } else if let _ = args?.createUploads {
            args!.createUploads!(req, attachment.files)
        } else {
            req.eventLoop.makeSucceededFuture(UploadsDTO(many: attachment.files.map { ($0, ByteBuffer(string: ""))}))
        }
        return uploads
            .map { uploads in
                AttachmentDTO(
                    id: attachment.id,
                    comment: attachment.comment,
                    files: uploads,
                    taskId: attachment.$task.id)
            }
    }
} 

extension AttachmentsDTO {
    /// Create AttachmentsContext with only one attachment from a model: not used
    public static func futureInit(
        _ req: Request,
        one: AttachmentModel,
        args: AttachmentDTO.CreateArguments? = nil) -> Future<AttachmentsDTO?> {
            return AttachmentDTO.futureInit(req, model: one, args: args)
                .map { attachment in
                    return AttachmentsDTO(attachments: [attachment!])
                }
    }

    /// Create AttachmentsContext with many attachments from a model
    public static func futureInit(
        _ req: Request, many: [AttachmentModel],
        args: AttachmentDTO.CreateArguments? = nil
        ) -> Future<AttachmentsDTO?> {
            return many
                .map { attachment in
                    return AttachmentDTO.futureInit(req, model: attachment, args: args)
                        .map { $0! }
                }
                .flatten(on: req.eventLoop)
                .map { attachments in
                    return AttachmentsDTO(attachments: attachments)
                }
    }
}
