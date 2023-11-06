//
//  HomeView.swift
//  POCGoogleCloudStorage
//
//  Created by Marlon Ruiz on 24/09/23.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var authViewModel: AuthenticationViewModel
	
	var body: some View {
		Group {
			NavigationView {
				switch authViewModel.state {
				case .signedIn:
					UserProfileView()
						.navigationTitle(
							NSLocalizedString(
								"User Profile",
								comment: "User profile navigation title"
							))
						.frame(width: 200)
				case .signedOut:
					SignInView()
						.navigationTitle(
							NSLocalizedString(
								"Sign-in with Google",
								comment: "Sign-in navigation title"
							))
						.frame(width: 200)
				}
			}
		}
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
			.environmentObject(AuthenticationViewModel())
	}
}
