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
    @State var currentPage = 1
    
    @State var startDate: Date?
    @State var endDate: Date?
    @State var groupBy: FilterGroup?
    @State var downloadGroupBy: DownloadGrouping = .day
    @AppStorage("selectedApp") var appName: String?
    @AppStorage("showSandbox") var showTestPurchase: Bool = true
    @AppStorage("includeTrials") var includeTrials: Bool = true
    @AppStorage("trialStatus") private var trialStatus: TrialStatus = TrialStatus.all
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ActiveFiltersView(startDate: $startDate, endDate: $endDate, groupBy: $groupBy)
                
                // Chart Section in TabView
                VStack {
                    TabView(selection: $selectedTab) {
                        // Purchases Chart
                        PurchasesChartView(
                            groupBy: $groupBy,
                        )
                        .tag(0)
                        
                        // Downloads Chart
                        DownloadChartView()
                            .tag(1)
                    }
                    .tabViewStyle(.page)
                    .frame(height: 500)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .background(Color.init(uiColor: UIColor.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    if selectedTab == 0 {
                        PurchasesListView(
                            startDate: $startDate,
                            endDate: $endDate,
                            currentPage: $currentPage
                        )
                    } else {
                        DownloadsListView()
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
                try await userManager.getPurchases(appName: appName ?? "", page: currentPage, startDate: startDate, endDate: endDate, includeSandbox: showTestPurchase, includeTrials: includeTrials, trialStatus: trialStatus)
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
                selectedTab: $selectedTab,
                includeTrials: $includeTrials,
                trialStatus: $trialStatus
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
        .onChange(of: includeTrials) { _, newValue in
            reloadAll()
        }
        .onChange(of: trialStatus) { _, newValue in
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
            try await userManager.getPurchases(appName: self.appName ?? "", page: currentPage, startDate: startDate, endDate: endDate, includeSandbox: showTestPurchase, includeTrials: includeTrials, trialStatus: trialStatus)
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
}
