//
//  SignInView.swift
//
//  Created by Pietro Messineo on 5/2/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Image("ReveNew")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 80)
            
            Text("Monitor your App Purchases at glance.")
                .font(.system(size: 22, weight: .semibold))
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if authManager.isLoading {
                ProgressView()
                Text("Authenticating...")
            } else {
                Button {
                    authManager.startSignInWithAppleFlow()
                } label: {
                    HStack(spacing: 5) {
                        if authManager.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("")
                            
                            Text("Sign in with Apple")
                        }
                    }
                    .font(.system(size: 22, weight: .bold))
                    .padding(.vertical, 14)
                    .foregroundColor(Color.init(uiColor: .systemBackground))
                    .frame(maxWidth: .infinity, minHeight: 45)
                    .background(Color.primary)
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthManager())
}
