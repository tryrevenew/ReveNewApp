//
//  HomeView.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/2/25.
//

import SwiftUI
import Charts

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(AuthManager())
    .environmentObject(UserManager())
}

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    
    @State var presentFilter: Bool = false
    @AppStorage("selectedApp") var appName: String?
    @State var currentPage = 1
    
    @State var startDate: Date?
    @State var endDate: Date?
    @State var groupBy: FilterGroup?
    @State var downloadGroupBy: DownloadGrouping = .day
    @AppStorage("showSandbox") var showTestPurchase: Bool = true
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ActiveFiltersView(startDate: $startDate, endDate: $endDate, groupBy: $groupBy)
                
                // Chart Section in TabView
                VStack {
                    TabView(selection: $selectedTab) {
                        // Purchases Chart
                        VStack {
                            HStack {
                                Text("Total incomes:")
                                    .font(.system(size: 21, weight: .semibold))
                                
                                Spacer()
                                
                                Text("$\(userManager.purchaseResponse?.totalInUSD ?? "-")")
                                    .font(.system(size: 21, weight: .semibold))
                            }
                            .padding(.horizontal, 20)
                            
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
                        }
                        .tag(0)
                        
                        // Downloads Chart
                        VStack {
                            HStack {
                                Text("Total Downloads:")
                                    .font(.system(size: 21, weight: .semibold))
                                
                                Spacer()
                                
                                if let data = userManager.downloadResponse?.data {
                                    Text("\(data.totalUniqueUsers)")
                                        .font(.system(size: 21, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if let groupedData = userManager.downloadResponse?.data.downloads {
                                Chart(groupedData, id: \.period) { item in
                                    BarMark(
                                        x: .value("Date", item.period),
                                        y: .value("Downloads", item.totalDownloads)
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
                                            if let intValue = value.as(Int.self) {
                                                Text("\(intValue)")
                                            }
                                        }
                                    }
                                }
                                .background(Color.init(uiColor: UIColor.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page)
                    .frame(height: 400)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
                .background(Color.init(uiColor: UIColor.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Purchase Details List
                if selectedTab == 0 {
                    Text("Purchases:")
                        .font(.system(size: 21, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    
                    VStack {
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
                } else {
                    if let downloads = userManager.downloadResponse?.data.downloads {
                        Text("Download Details:")
                            .font(.system(size: 21, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                        
                        VStack {
                            LazyVStack {
                                ForEach(downloads, id: \.period) { period in
                                    VStack(spacing: 5) {
                                        HStack {
                                            Text(period.period)
                                                .font(.system(size: 17, weight: .semibold))
                                            Spacer()
                                            Text("\(period.totalDownloads) downloads")
                                                .font(.system(size: 17, weight: .bold))
                                        }
                                        
                                        HStack {
                                            Text("\(period.uniqueUsers) unique users")
                                                .font(.system(size: 14, weight: .semibold))
                                                .opacity(0.5)
                                            
                                            Spacer()
                                        }
                                        
                                        Divider()
                                            .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.init(uiColor: UIColor.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            reloadPurchases()
            reloadPurchasesSummary()
            reloadDownloads()
        }
        .navigationTitle(appName ?? "")
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.init(uiColor: .systemGroupedBackground))
        .task {
            do {
                try await userManager.getPurchases(appName: appName ?? "", page: currentPage, startDate: startDate, endDate: endDate, includeSandbox: showTestPurchase)
                try await userManager.getAppList()
                try await userManager.getPurchaseSummary(appName: appName ?? "", startDate: startDate, endDate: endDate, groupBy: groupBy, includeSandbox: showTestPurchase)
                try await userManager.getDownloads(appName: appName, startDate: startDate, endDate: endDate, groupBy: downloadGroupBy)
            } catch {
                print("Error fetching data \(error.localizedDescription)")
            }
        }
        .toolbar {
            Menu {
                ForEach(userManager.appList, id: \.self) { app in
                    Button {
                        self.appName = app
                        self.reloadAll()
                    } label: {
                        HStack {
                            Text(app)
                            Spacer()
                            Image(systemName: (app == self.appName ?? "") ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
            } label: {
                Image(systemName: "iphone.app.switcher")
            }
            
            Button {
                presentFilter.toggle()
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        .sheet(isPresented: $presentFilter) {
            FilterView(
                startDateFilter: $startDate,
                endDateFilter: $endDate,
                groupBy: $groupBy,
                downloadGroupBy: $downloadGroupBy,
                showTestPurchase: $showTestPurchase,
                selectedTab: $selectedTab
            )
        }
        .onChange(of: startDate) { oldValue, newValue in
            reloadAll()
        }
        .onChange(of: endDate) { _, newValue in
            reloadAll()
        }
        .onChange(of: showTestPurchase) { _, newValue in
            reloadAll()
        }
        .onChange(of: groupBy) { _, newValue in
            reloadPurchasesSummary()
        }
        .onChange(of: downloadGroupBy) { _, newValue in
            reloadDownloads()
        }
    }
    
    func reloadAll() {
        reloadPurchases()
        reloadPurchasesSummary()
        reloadDownloads()
    }
    
    func reloadPurchases() {
        Task {
            userManager.purchases.removeAll()
            currentPage = 1
            try await userManager.getPurchases(appName: self.appName ?? "", page: currentPage, startDate: startDate, endDate: endDate, includeSandbox: showTestPurchase)
        }
    }
    
    func reloadPurchasesSummary() {
        Task {
            try await userManager.getPurchaseSummary(appName: self.appName ?? "", startDate: startDate, endDate: endDate, groupBy: groupBy, includeSandbox: showTestPurchase)
        }
    }
    
    func reloadDownloads() {
        Task {
            try await userManager.getDownloads(appName: appName, startDate: startDate, endDate: endDate, groupBy: downloadGroupBy)
        }
    }
    
    private func loadNextPage() {
        currentPage += 1
        Task {
            try? await userManager.getPurchases(appName: self.appName ?? "", page: currentPage, startDate: startDate, endDate: endDate, includeSandbox: showTestPurchase)
        }
    }
}
