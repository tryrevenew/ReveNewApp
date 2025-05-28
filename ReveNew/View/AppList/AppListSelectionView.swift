//
//  AppListSelectionView.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/4/25.
//

import SwiftUI

struct AppListSelectionView: View {
    @EnvironmentObject var userManager: UserManager
    
    @AppStorage("selectedApp") var appName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("From which app you want to see Analytics purchases?")
                .font(.system(size: 21, weight: .semibold))
            
            Text("Select an app from the list below:")
                .opacity(0.5)
            
            List(userManager.appList, id: \.self) { app in
                Button {
                    self.appName = app
                } label: {
                    HStack {
                        Text(app)
                        
                        Spacer()
                        
                        Image(systemName: (app == self.appName ?? "") ? "checkmark.circle.fill" : "circle")
                    }
                    .foregroundStyle(Color.primary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.init(uiColor: .systemGroupedBackground))
        .task {
            do {
                try await userManager.getAppList()
            } catch {
                print("Error fetching app list \(error.localizedDescription)")
            }
        }
    }
}
