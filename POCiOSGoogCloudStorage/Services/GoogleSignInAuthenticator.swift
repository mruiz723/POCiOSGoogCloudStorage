/*
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import GoogleSignIn

/// An observable class for authenticating via Google.
final class GoogleSignInAuthenticator: ObservableObject {
	private var authViewModel: AuthenticationViewModel
	
	/// Creates an instance of this authenticator.
	/// - parameter authViewModel: The view model this authenticator will set logged in status on.
	init(authViewModel: AuthenticationViewModel) {
		self.authViewModel = authViewModel
	}
	
	/// Signs in the user based upon the selected account.'
	/// - note: Successful calls to this will set the `authViewModel`'s `state` property.
	func signIn() {
#if os(iOS)
		guard
			let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			let window = windowScene.keyWindow,
			let rootViewController = window.rootViewController
		else {
			print("There is no root view controller!")
			return
		}
		
		GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
			guard let signInResult = signInResult else {
				print("Error! \(String(describing: error))")
				return
			}
			self.authViewModel.state = .signedIn(signInResult.user)
		}
		
#elseif os(macOS)
		guard let presentingWindow = NSApplication.shared.windows.first else {
			print("There is no presenting window!")
			return
		}
		
		GIDSignIn.sharedInstance.signIn(withPresenting: presentingWindow) { signInResult, error in
			guard let signInResult = signInResult else {
				print("Error! \(String(describing: error))")
				return
			}
			self.authViewModel.state = .signedIn(signInResult.user)
		}
#endif
	}
	
	/// Signs out the current user.
	func signOut() {
		GIDSignIn.sharedInstance.signOut()
		authViewModel.state = .signedOut
	}
	
	/// Disconnects the previously granted scope and signs the user out.
	func disconnect() {
		GIDSignIn.sharedInstance.disconnect { error in
			if let error = error {
				print("Encountered error disconnecting scope: \(error).")
			}
			self.signOut()
		}
	}
	
	
	func addGoogleDriveScope(completion: @escaping () -> Void) {
		guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
			fatalError("No user signed in!")
		}
		
		guard
			let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			let window = windowScene.keyWindow,
			let presentingVC = window.rootViewController
		else { fatalError("No presentingVC!") }
		
		let grantedScopes = currentUser.grantedScopes
		if grantedScopes == nil || !grantedScopes!.contains(GoogleDriveService.driveScope) {
			currentUser.addScopes([GoogleDriveService.driveScope], presenting: presentingVC) { signInResult, error in
				guard error == nil else { return }
				guard let signInResult = signInResult else { return }
				
				// Check if the user granted access to the scopes you requested.
				self.authViewModel.state = .signedIn(signInResult.user)
				completion()
			}
		}
		
	}
	
}
