//
//  UserProfileView.swift
//  POCGoogleCloudStorage
//
//  Created by Marlon Ruiz on 24/09/23.
//

import SwiftUI
import GoogleSignIn

struct UserProfileView: View {
	@EnvironmentObject var authViewModel: AuthenticationViewModel
	@StateObject var driveViewModel = DriveViewModel()
	private var user: GIDGoogleUser? {
		return GIDSignIn.sharedInstance.currentUser
	}
	
	var body: some View {
		return Group {
			if let userProfile = user?.profile {
				VStack(spacing: 10) {
					HStack(alignment: .top) {
						UserProfileImageView(userProfile: userProfile)
							.padding(.leading)
						VStack(alignment: .leading) {
							Text(userProfile.name)
								.font(.headline)
							Text(userProfile.email)
						}
					}
					Button(NSLocalizedString("Sign Out", comment: "Sign out button"), action: signOut)
						.background(Color.blue)
						.foregroundColor(Color.white)
						.cornerRadius(5)
					
					Button(NSLocalizedString("Disconnect", comment: "Disconnect button"), action: disconnect)
						.background(Color.blue)
						.foregroundColor(Color.white)
						.cornerRadius(5)
					Spacer()
						.background(Color.blue)
						.foregroundColor(Color.white)
						.cornerRadius(5)
					Spacer()
					NavigationLink(NSLocalizedString("My Google drive files", comment: "My Google drive files"), destination: DriveView(driveViewModel: driveViewModel)
						.onAppear {
							if !authViewModel.hasDriveScope {
								authViewModel.addGoogleDriveScope {
									Task {
										await driveViewModel.fetchFiles()
									}
								}
							} else {
								Task {
									await driveViewModel.fetchFiles()
								}
							}
						})
					.background(Color.blue)
					.foregroundColor(Color.white)
					.cornerRadius(5)
					Spacer()
				}
			} else {
				Text(NSLocalizedString("Failed to get user profile!", comment: "Empty user profile text"))
			}
		}
	}
	
	func disconnect() {
		authViewModel.disconnect()
	}
	
	func signOut() {
		authViewModel.signOut()
	}
}


struct UserProfileView_Previews: PreviewProvider {
	static var previews: some View {
		UserProfileView()
	}
}
