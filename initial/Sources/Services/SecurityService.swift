import Foundation
import CryptoKit
import LocalAuthentication

public protocol SecurityServiceProtocol {
    func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data
    func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data
    func hash(_ data: Data) -> Data
    func biometricAuthenticate() async throws
}

public final class SecurityService: SecurityServiceProtocol {
    public enum SecurityError: Error {
        case invalidCiphertext
        case authenticationFailed
        case secureEnclaveUnavailable
        case encryptionFailed
        case decryptionFailed
    }
    
    public init() {}
    
    public func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined ?? Data()
        } catch {
            throw SecurityError.encryptionFailed
        }
    }
    
    public func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw SecurityError.decryptionFailed
        }
    }
    
    public func hash(_ data: Data) -> Data {
        let digest = SHA256.hash(data: data)
        return Data(digest)
    }
    
    public func biometricAuthenticate() async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw SecurityError.secureEnclaveUnavailable
        }
        
        try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate") { success, authError in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: SecurityError.authenticationFailed)
                }
            }
        }
    }
}
