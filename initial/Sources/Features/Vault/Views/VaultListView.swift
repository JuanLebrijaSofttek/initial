import SwiftUI
import LocalAuthentication

/// Shows a list of decrypted vault items.
public struct VaultListView: View {
    @State private var isUnlocked = false
    @State private var decryptedNotes: [DecryptedNoteDetail] = []
    @State private var authError: String?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Group {
                if isUnlocked {
                    List(decryptedNotes) { note in
                        NavigationLink(value: note) {
                            VStack(alignment: .leading) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.createdDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .navigationDestination(for: DecryptedNoteDetail.self) { note in
                        // Placeholder for detail view
                        ScrollView {
                            Text(note.content)
                                .padding()
                        }
                        .navigationTitle(note.title)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("Vault Locked")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Button("Unlock to View") {
                            authenticate()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if let error = authError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Vault")
            .onAppear {
                if !isUnlocked {
                    authenticate()
                }
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // Check if device supports biometrics or passcode
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your vault") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        self.loadNotes()
                    } else {
                        self.authError = authenticationError?.localizedDescription ?? "Authentication failed"
                    }
                }
            }
        } else {
            // Fallback for Simulator or devices without auth configured
            #if targetEnvironment(simulator)
            self.isUnlocked = true
            self.loadNotes()
            #else
            self.authError = "Biometrics not available. Please configure device security."
            #endif
        }
    }
    
    private func loadNotes() {
        // Mock data
        decryptedNotes = [
            DecryptedNoteDetail(title: "Secret Key", content: "1234-5678-9012"),
            DecryptedNoteDetail(title: "Backup Codes", content: "XJ9-22K-L0P")
        ]
    }
}
