//
//  DownloadsListView.swift
//  ReveNew
//
//  Created by Pietro Messineo on 6/7/25.
//

import SwiftUI

struct DownloadsListView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
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
