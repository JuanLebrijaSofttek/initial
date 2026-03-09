import Foundation

/// Represents a decrypted note detail for display in the Vault list.
public struct DecryptedNoteDetail: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let content: String
    public let createdDate: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdDate = createdDate
    }
}
