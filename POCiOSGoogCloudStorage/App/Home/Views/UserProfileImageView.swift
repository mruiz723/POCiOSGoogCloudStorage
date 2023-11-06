//
//  UserProfileImageView.swift
//  POCGoogleCloudStorage
//
//  Created by Marlon Ruiz on 24/09/23.
//

import GoogleSignIn
import SwiftUI

struct UserProfileImageView: View {
  @ObservedObject var userProfileImageLoader: UserProfileImageLoader

  init(userProfile: GIDProfileData) {
	self.userProfileImageLoader = UserProfileImageLoader(userProfile: userProfile)
  }

  var body: some View {
	#if os(iOS)
	Image(uiImage: userProfileImageLoader.image)
	  .resizable()
	  .aspectRatio(contentMode: .fill)
	  .frame(width: 45, height: 45, alignment: .center)
	  .scaledToFit()
	  .clipShape(Circle())
	  .accessibilityLabel(Text("User profile image."))
	#elseif os(macOS)
	Image(nsImage: userProfileImageLoader.image)
	  .resizable()
	  .aspectRatio(contentMode: .fill)
	  .frame(width: 45, height: 45, alignment: .center)
	  .scaledToFit()
	  .clipShape(Circle())
	  .accessibilityLabel(Text("User profile image."))
	#endif
  }
}
