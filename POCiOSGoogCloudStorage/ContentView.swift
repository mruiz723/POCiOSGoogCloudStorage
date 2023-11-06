//
//  ContentView.swift
//  POCiOSGoogCloudStorage
//
//  Created by Marlon Ruiz on 5/10/23.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct ContentView: View {
	var body: some View {
		VStack {
			GoogleSignInButton(action: handleSignInButton)
				.frame(width: 200, height: 50)
		}
	}

	func handleSignInButton() {
		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
		   let window = windowScene.keyWindow,
		   let rootVC = window.rootViewController {
			GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
				if let error = error {
					print("Error signing in: \(error.localizedDescription)")
					return
				}
				if let user = result?.user {
					let email = user.profile?.email
					print("User signed in with email: \(email ?? "Unknown Email")")
				}
			}
		}
	}
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

