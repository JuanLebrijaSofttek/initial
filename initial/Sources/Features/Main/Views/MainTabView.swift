import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable {
        case dashboard
        case ledger
        case vault
        case settings
    }

    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
                    .navigationTitle("Overview")
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(Tab.dashboard)

            placeholderView(
                title: "Ledger",
                message: "Track every transaction in your ledger."
            )
            .tabItem {
                Label("Ledger", systemImage: "list.bullet")
            }
            .tag(Tab.ledger)

            placeholderView(
                title: "Vault",
                message: "Securely store sensitive financial data."
            )
            .tabItem {
                Label("Vault", systemImage: "lock.fill")
            }
            .tag(Tab.vault)

            placeholderView(
                title: "Settings",
                message: "Configure preferences and security options."
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .tabViewStyle(.automatic)
    }

    @ViewBuilder
    private func placeholderView(title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title.weight(.semibold))
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
