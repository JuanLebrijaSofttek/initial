import SwiftUI

/// Modal form for creating a new vault entry with secure password field.
struct AddVaultEntryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var notes: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .textContentType(.name)
                    
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                } header: {
                    Text("Entry Information")
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Additional Information")
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Vault Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveEntry()
                        }
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .disabled(isSaving)
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }
    
    private func saveEntry() async {
        guard isValid else { return }
        
        isSaving = true
        errorMessage = nil
        
        do {
            // Simulate async save operation
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // TODO: Integrate with actual VaultEntry storage/service
            // For now, we just simulate success
            
            dismiss()
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

#Preview {
    AddVaultEntryView()
}
