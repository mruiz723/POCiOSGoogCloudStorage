//
//  DriveView.swift
//  POCGoogleCloudStorage
//
//  Created by Marlon Ruiz on 24/09/23.
//

import SwiftUI
import MobileCoreServices

struct DriveView: View {
	@ObservedObject var driveViewModel: DriveViewModel
	
    var body: some View {
		VStack {
			HStack(alignment: .top) {
				Spacer()
				Button("+") {
					Task {
						await upload()
					}
				}
				.background(Color.blue)
				.padding(20)
				.foregroundColor(Color.white)
				.cornerRadius(5)
			}
			Spacer()
			if let files = driveViewModel.files {
				if files.isEmpty {
					Text("You have not created files yet.")
						.font(.title)
					Spacer()
				} else {
					List() {
						Section() {
							HStack(alignment: .center) {
								Text("Name")
									.font(.title2)
									.frame(width: 150)
								Text("Type")
									.font(.title2)
							}
						}
						Section() {
							ForEach(files, id: \.id) { file in
								HStack {
									Text(file.name)
										.frame(width: 150)
									Text(file.mimeType ?? "")
								}
							}
						}
					}
				}
			} else {
				ProgressView()
				Spacer()
			}
		}
    }
	
	private func upload() async {
		guard let urls = await openFileModal() else { return }
		for url in urls {
			await driveViewModel.updloadFileToDrive(url)
		}
	}
	
	private func openFileModal() async -> [URL]? {
		return nil
	}

}

struct DriveView_Previews: PreviewProvider {
    static var previews: some View {
		DriveView(driveViewModel: DriveViewModel())
    }
}
