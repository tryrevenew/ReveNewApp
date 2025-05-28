import SwiftUI
import Charts

struct DownloadsChartView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var groupBy: DownloadGrouping
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total Downloads:")
                    .font(.system(size: 21, weight: .semibold))
                
                Spacer()
                
                if let data = userManager.downloadResponse?.data {
                    Text("\(data.totalUniqueUsers)")
                        .font(.system(size: 21, weight: .semibold))
                }
            }
            
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
            
            if let downloads = userManager.downloadResponse?.data.downloads {
                Text("Download Details:")
                    .font(.system(size: 21, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView {
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