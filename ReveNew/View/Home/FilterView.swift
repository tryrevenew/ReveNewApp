//
//  FilterView.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/4/25.
//

import SwiftUI

struct FilterView: View {
    @Binding var startDateFilter: Date?
    @Binding var endDateFilter: Date?
    @Binding var groupBy: FilterGroup?
    @Binding var downloadGroupBy: DownloadGrouping
    @Binding var showTestPurchase: Bool
    @Binding var selectedTab: Int
    
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Filter per Date:")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Button {
                    startDateFilter = nil
                    endDateFilter = nil
                    groupBy = nil
                } label: {
                    Text("Reset")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .foregroundStyle(.white)
                }
            }
            
            HStack {
                Text("Start Date:")
                DatePicker(selection: $startDate, displayedComponents: .date) {
                    
                }
                .onChange(of: startDate) { oldValue, newValue in
                    startDateFilter = newValue
                }
            }
            
            HStack {
                Text("End Date:")
                DatePicker(selection: $endDate, displayedComponents: .date) {
                    
                }
                .onChange(of: endDate) { oldValue, newValue in
                    endDateFilter = newValue
                }
            }
            
            Divider()
            
            Text("Grouping Options:")
                .font(.system(size: 20, weight: .semibold))
            
            if selectedTab == 0 {
                // Purchases grouping
                HStack {
                    Text("Group Purchases by:")
                    
                    Spacer()
                    
                    Menu {
                        ForEach(FilterGroup.allCases, id: \.rawValue) { filter in
                            Button {
                                groupBy = filter
                            } label: {
                                Text(filter.rawValue)
                            }
                        }
                    } label: {
                        Text(groupBy != nil ? (groupBy?.rawValue ?? "") : "Select")
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(Color.init(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            } else {
                // Downloads grouping
                HStack {
                    Text("Group Downloads by:")
                    
                    Spacer()
                    
                    Menu {
                        ForEach(DownloadGrouping.allCases, id: \.rawValue) { filter in
                            Button {
                                downloadGroupBy = filter
                            } label: {
                                Text(filter.rawValue)
                            }
                        }
                    } label: {
                        Text(downloadGroupBy.rawValue)
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(Color.init(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            
            if selectedTab == 0 {
                Divider()
                
                Text("Extras:")
                    .font(.system(size: 20, weight: .semibold))
                
                HStack {
                    Text("Show Test Purchases:")
                    
                    Spacer()
                    
                    Toggle(isOn: $showTestPurchase) {}
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(selectedTab == 0 ? 450 : 350)])
    }
}
