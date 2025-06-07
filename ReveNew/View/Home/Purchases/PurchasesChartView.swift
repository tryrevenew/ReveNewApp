import SwiftUI
import Charts

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(AuthManager())
    .environmentObject(UserManager())
}

struct PurchasesChartView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var groupBy: FilterGroup?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total incomes:")
                    .font(.system(size: 21, weight: .semibold))
                
                Spacer()
                
                Text("$\(userManager.purchaseResponse?.totalInUSD ?? "-")")
                    .font(.system(size: 21, weight: .semibold))
            }
            
            // Stats summary
            if let stats = userManager.purchaseResponse?.stats {
                HStack(spacing: 20) {
                    VStack {
                        Text("\(stats.total)")
                            .font(.system(size: 18, weight: .bold))
                        Text("Total")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(stats.trials)")
                            .font(.system(size: 18, weight: .bold))
                        Text("Trials")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(stats.paid)")
                            .font(.system(size: 18, weight: .bold))
                        Text("Paid")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 5)
            }
            
            if let groupedData = userManager.purchaseSummaryResponse?.grouped {
                Chart(groupedData, id: \.self) { item in
                    BarMark(
                        x: .value("Date", (groupBy == .hour) ? item.group.shortTime() : item.group.shortLabel()),
                        y: .value("Earnings", item.totalInUSD)
                    )
                    
                    if item.trialCount > 0 {
                        RuleMark(
                            x: .value("Date", (groupBy == .hour) ? item.group.shortTime() : item.group.shortLabel()),
                            yStart: 0,
                            yEnd: Double(item.trialCount) * 0.5
                        )
                        .foregroundStyle(.purple.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top) {
                            Text("\(item.trialCount)")
                                .font(.system(size: 10))
                                .foregroundColor(.purple)
                        }
                    }
                }
                .frame(height: 300)
                .padding()
                .chartYScale(domain: .automatic)
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("$\(Int(doubleValue))")
                            }
                        }
                    }
                }
                .background(Color.init(uiColor: UIColor.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            Spacer()
        }
        .padding(20)
    }
} 
