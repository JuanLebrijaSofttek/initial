import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingAddTransaction = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary Card
                summaryCard
                
                // Spending Breakdown
                spendingBreakdown
                
                // Recent Activity
                recentActivity
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Overview")
        .overlay(alignment: .bottomTrailing) {
            addButton
                .padding()
        }
        .sheet(isPresented: $showingAddTransaction) {
            Text("Add Transaction")
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            viewModel.refresh()
        }
    }
    
    // MARK: - Components
    
    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Menu {
                    ForEach(TimePeriod.allCases) { period in
                        Button {
                            viewModel.selectedPeriod = period
                        } label: {
                            if viewModel.selectedPeriod == period {
                                Label(period.rawValue, systemImage: "checkmark")
                            } else {
                                Text(period.rawValue)
                            }
                        }
                    }
                } label: {
                    Label(viewModel.selectedPeriod.rawValue, systemImage: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                .accessibilityLabel("Select Time Period")
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formattedNetBalance)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
                    .contentTransition(.numericText())
                
                HStack(spacing: 4) {
                    Image(systemName: viewModel.spendingTrend.iconName)
                    Text(viewModel.formattedSpendingChange)
                    Text("vs previous period")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .foregroundStyle(viewModel.spendingTrend.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Label("Income", systemImage: "arrow.down.left")
                        .font(.caption)
                        .foregroundStyle(Color("AppSuccess"))
                    Text(viewModel.formattedTotalIncome)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Label("Expenses", systemImage: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(Color("AppDanger"))
                    Text(viewModel.formattedTotalExpenses)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Financial Summary. Balance: \(viewModel.formattedNetBalance). Income: \(viewModel.formattedTotalIncome). Expenses: \(viewModel.formattedTotalExpenses)")
    }
    
    private var spendingBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Breakdown")
                .font(.headline)
            
            if viewModel.categoryBreakdown.isEmpty {
                ContentUnavailableView("No Expenses", systemImage: "chart.pie", description: Text("Start spending to see your breakdown"))
                    .frame(height: 200)
            } else {
                ViewThatFits(in: .horizontal) {
                    // Regular layout (iPad/Large phones)
                    HStack(alignment: .top, spacing: 20) {
                        chartView
                            .frame(width: 200, height: 200)
                        
                        categoryListView
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Compact layout (iPhone SE/Small screens)
                    VStack(spacing: 20) {
                        chartView
                            .frame(height: 200)
                        
                        categoryListView
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var chartView: some View {
        // Placeholder for Chart
        // In a real app, use Swift Charts
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            if let topCategory = viewModel.categoryBreakdown.first {
                Circle()
                    .trim(from: 0, to: 0.7) // Mock data
                    .stroke(Color("AppPrimary"), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("Top Spending")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(topCategory.category.name)
                        .font(.headline)
                }
            }
        }
        .accessibilityLabel("Spending Chart")
    }
    
    private var categoryListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.categoryBreakdown.prefix(4), id: \.category.id) { item in
                HStack {
                    Circle()
                        .fill(Color("AppPrimary")) // Use actual category color
                        .frame(width: 8, height: 8)
                    Text(item.category.name)
                        .font(.subheadline)
                    Spacer()
                    Text(viewModel.formatCurrency(item.amount))
                        .font(.subheadline.bold())
                }
                .accessibilityLabel("\(item.category.name): \(viewModel.formatCurrency(item.amount))")
            }
        }
    }
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    // Navigate to Ledger
                }
                .font(.subheadline)
            }
            
            if viewModel.recentTransactions.isEmpty {
                ContentUnavailableView("No Transactions", systemImage: "list.bullet.rectangle.portrait", description: Text("Recent transactions will appear here"))
                    .frame(height: 150)
            } else {
                ForEach(viewModel.recentTransactions) { transaction in
                    HStack {
                        Image(systemName: transaction.category.icon)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color("AppPrimary"))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(transaction.payee)
                                .font(.body.weight(.medium))
                            Text(transaction.timestamp.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.formatCurrency(transaction.amount))
                            .font(.body.weight(.bold))
                            .foregroundStyle(transaction.type == .expense ? Color("AppDanger") : Color("AppSuccess"))
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Transaction: \(transaction.payee), \(viewModel.formatCurrency(transaction.amount)), \(transaction.timestamp.formatted(date: .abbreviated, time: .omitted))")
                    
                    if transaction.id != viewModel.recentTransactions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var addButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            showingAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color("AppPrimary"))
                .clipShape(Circle())
                .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .accessibilityLabel("Add Transaction")
        .accessibilityHint("Opens a form to create a new transaction")
    }
}
