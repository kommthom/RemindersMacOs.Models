//
//  UploadModel.swift
//  
//
//  Created by Thomas Benninghaus on 01.05.24.
//

import Foundation

import Vapor
import Fluent

public final class UploadModel: Model {
    public static let schema = "uploads"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Enum(key: "attachmenttype")
    public var attachmentType: AttachmentType
    
    @Field(key: "filename")
    public var fileName: String
    
    @Field(key: "originalfilename")
    public var originalFileName: String
    
    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?
    
    @Parent(key: "attachment_id")
    public var attachment: AttachmentModel
    
    public init() {}
    
    public init(id: UUID? = nil, attachmentType: AttachmentType, fileName: String, originalFileName: String, attachmentId: AttachmentModel.IDValue) {
        self.id = id
        self.attachmentType = attachmentType
        self.fileName = fileName
        self.originalFileName = originalFileName
        self.$attachment.id = attachmentId
    }
    
    public convenience init(from uploadDTO: UploadDTO) {
        self.init(id: uploadDTO.id, attachmentType: uploadDTO.attachmentType, fileName: uploadDTO.fileName, originalFileName: uploadDTO.originalFileName, attachmentId: uploadDTO.attachment_id)
    }
}

extension UploadDTO {
    public init?(model upload: UploadModel, byteBuffer: ByteBuffer) {
        self.init(id: upload.id, attachmentType: upload.attachmentType, fileName: upload.fileName, originalFileName: upload.originalFileName, attachment_Id: upload.$attachment.id, byteBuffer: byteBuffer)
    }
}
extension UploadsDTO {
    /// Create UploadsContext with only one upload from a model: not used
    public init(one: UploadModel, byteBuffer: ByteBuffer) {
        self.init(uploads: [UploadDTO(model: one, byteBuffer: byteBuffer)].compactMap { $0 } )
    }

    /// Create UploadsContext with many uploads from a model
    public init(many: [(UploadModel, ByteBuffer)]) {
        self.init(uploads: many.compactMap { UploadDTO(model: $0.0, byteBuffer: $0.1) })
    }
}
