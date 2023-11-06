//
//  POCiOSGoogCloudStorageApp.swift
//  POCiOSGoogCloudStorage
//
//  Created by Marlon Ruiz on 5/10/23.
//

import SwiftUI
import GoogleSignIn

@main
struct POCGoogleCloudStorageApp: App {
	
	@StateObject var authViewModel = AuthenticationViewModel()
	
	var body: some Scene {
		WindowGroup {
			HomeView()
				.environmentObject(AuthenticationViewModel())
				.onAppear {
					GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
					  if let user = user {
						self.authViewModel.state = .signedIn(user)
					  } else if let error = error {
						self.authViewModel.state = .signedOut
						print("There was an error restoring the previous sign-in: \(error)")
					  } else {
						self.authViewModel.state = .signedOut
					  }
					}
				}
				.onOpenURL { url in
					GIDSignIn.sharedInstance.handle(url)
				}
//            ContentView()
//				.onOpenURL { url in
//					GIDSignIn.sharedInstance.handle(url)
//				}
//				.onAppear {
//					GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//						// Check if `user` exists; otherwise, do something with `error`
//					}
//				}
		}
	}
}

