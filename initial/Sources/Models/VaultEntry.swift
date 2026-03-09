import Foundation

/// Represents an encrypted record stored inside the secure vault.
public struct VaultEntry: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let ciphertext: Data
    public let initializationVector: Data
    public let tag: Data
    public let createdDate: Date
    
    public init(
        id: UUID = UUID(),
        ciphertext: Data,
        initializationVector: Data,
        tag: Data,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.ciphertext = ciphertext
        self.initializationVector = initializationVector
        self.tag = tag
        self.createdDate = createdDate
    }
}

/// Constants used for security operations.
public enum SecurityConstants {
    /// The algorithm used for hashing.
    public static let hashingAlgorithm = "SHA256"
    /// The algorithm used for encryption.
    public static let encryptionAlgorithm = "AES"
    /// The block mode used for encryption.
    public static let encryptionMode = "GCM"
    /// The padding scheme used for encryption (GCM handles padding internally, so often 'none' or implicit).
    /// Adding specific configuration strings if needed for specific libraries (e.g. CryptoKit uses them implicitly).
}
