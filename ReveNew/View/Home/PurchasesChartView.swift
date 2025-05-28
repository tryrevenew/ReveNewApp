import SwiftUI
import Charts

struct PurchasesChartView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var groupBy: FilterGroup?
    @Binding var showTestPurchase: Bool
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total incomes:")
                    .font(.system(size: 21, weight: .semibold))
                
                Spacer()
                
                Text("$\(userManager.purchaseResponse?.totalInUSD ?? "-")")
                    .font(.system(size: 21, weight: .semibold))
            }
            
            if let groupedData = userManager.purchaseSummaryResponse?.grouped {
                Chart(groupedData, id: \.self) { item in
                    BarMark(
                        x: .value("Date", (groupBy == .hour) ? item.group.shortTime() : item.group.shortLabel()),
                        y: .value("Earnings", item.totalInUSD)
                    )
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
            
            Text("Purchases:")
                .font(.system(size: 21, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                LazyVStack {
                    ForEach(userManager.purchases, id: \.self) { purchase in
                        VStack(spacing: 5) {
                            HStack {
                                Text(purchase.kind)
                                Spacer()
                                Text(purchase.priceFormatted)
                                    .font(.system(size: 17, weight: .bold))
                            }
                            
                            HStack {
                                Text("\(purchase.createdAt.timeAgo()) • \(purchase.storeFront ?? "")")
                                    .font(.system(size: 14, weight: .semibold))
                                    .opacity(0.5)
                                
                                if let storeFront = purchase.storeFront {
                                    Text(storeFront.flagEmojiFromAlpha3)
                                }
                                
                                Spacer()
                                
                                Text(purchase.isSandbox ? "Fake".uppercased() : "Real".uppercased())
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(purchase.isSandbox ? .red : .green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(purchase.isSandbox ? .red.opacity(0.3) : .green.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Divider()
                                .padding(.vertical, 10)
                        }
                        .onAppear {
                            if purchase == userManager.purchases.last {
                                loadNextPage()
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.init(uiColor: UIColor.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private func loadNextPage() {
        currentPage += 1
        Task {
            try? await userManager.getPurchases(appName: userManager.appList.first ?? "", page: currentPage, startDate: startDate, endDate: endDate, includeSandbox: showTestPurchase)
        }
    }
} 