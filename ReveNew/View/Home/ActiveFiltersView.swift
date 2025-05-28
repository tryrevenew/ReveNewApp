//
//  ActiveFiltersView.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/4/25.
//

import SwiftUI

struct ActiveFiltersView: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var groupBy: FilterGroup?
    
    var body: some View {
        if startDate != nil || endDate != nil || groupBy != nil {
            VStack(alignment: .leading) {
                HStack {
                    Text("Active Filters:")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        self.startDate = nil
                        self.endDate = nil
                        self.groupBy = nil
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
                
                ScrollView(.horizontal) {
                    HStack {
                        if let startDate {
                            Text(startDate.toMonthDayYear())
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                                .background(Color.init(uiColor: .systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        if let endDate {
                            Text(endDate.toMonthDayYear())
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                                .background(Color.init(uiColor: .systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        if let groupBy {
                            Text(groupBy.rawValue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                                .background(Color.init(uiColor: .systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}
