//
//  PurchasesListView.swift
//  ReveNew
//
//  Created by Pietro Messineo on 6/7/25.
//

import SwiftUI

struct PurchasesListView: View {
    @EnvironmentObject var userManager: UserManager
    
    @AppStorage("selectedApp") var appName: String?
    @AppStorage("showSandbox") var showTestPurchase: Bool = true
    @AppStorage("includeTrials") var includeTrials: Bool = true
    @AppStorage("trialStatus") private var trialStatus: TrialStatus = TrialStatus.all
    
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var currentPage: Int
    
    var body: some View {
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
                            
                            // Trial badge
                            if purchase.isTrial == true {
                                Text("TRIAL")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.purple)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.purple.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(.trailing, 4)
                            }
                            
                            // Sandbox badge
                            Text(purchase.isSandbox ? "TEST" : "REAL")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(purchase.isSandbox ? .red : .green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(purchase.isSandbox ? .red.opacity(0.3) : .green.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Show trial period if available
                        if let trialPeriod = purchase.trialPeriod, !trialPeriod.isEmpty {
                            HStack {
                                Text("Trial Period: \(trialPeriod)")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
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
    
    private func loadNextPage() {
        currentPage += 1
        Task {
            try? await userManager.getPurchases(appName: self.appName ?? "", page: currentPage, startDate: startDate, endDate: endDate, includeSandbox: showTestPurchase, includeTrials: includeTrials, trialStatus: trialStatus)
        }
    }
}
