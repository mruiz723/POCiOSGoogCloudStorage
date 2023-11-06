//
//  DriveViewModel.swift
//  POCGoogleCloudStorage
//
//  Created by Marlon Ruiz on 24/09/23.
//

import Foundation

final class DriveViewModel: ObservableObject {
	@Published private(set) var files: [DriveFile]?
	var rootFolder: DriveFile?
	private let googleDriveService = GoogleDriveService()
	
	@MainActor func fetchFiles() async {
		do {
			files = try await googleDriveService.fetchFiles()
		} catch {
			print(error)
		}
	}
	
	@MainActor func updloadFileToDrive(_ url: URL) async {
		do {
			await setupRootFolderIfNeeded()
			guard
				let rootFolder = rootFolder,
				let folderId = rootFolder.id
			else { fatalError("rootFolder is required") }
			let file = try await googleDriveService.uploadFileToFolder(fileURL: url, folderID: folderId)
			files?.append(file)
		} catch {
			print(error)
		}
	}
	
	private func setupRootFolderIfNeeded() async {
		do {
			guard rootFolder == nil else { return }
			let rootFolderName = "MySafe"
			rootFolder = try await googleDriveService.checkIfFolderExistsInDrive(folderName: rootFolderName)
			if rootFolder == nil {
				rootFolder = try await googleDriveService.createFolderInDrive(folderName: rootFolderName)
			}
		} catch {
			print(error)
		}
	}
}
