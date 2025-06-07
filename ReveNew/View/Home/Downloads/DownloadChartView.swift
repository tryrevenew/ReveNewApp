//
//  DownloadChartView.swift
//  ReveNew
//
//  Created by Pietro Messineo on 6/7/25.
//

import SwiftUI
import Charts

struct DownloadChartView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
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
    }
}
