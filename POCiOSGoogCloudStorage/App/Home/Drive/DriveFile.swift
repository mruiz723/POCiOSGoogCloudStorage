//
//  DriveFile.swift
//  POCGoogleCloudStorage
//
//  Created by Marlon Ruiz on 25/09/23.
//

import Foundation

struct DriveFileResponseData: Codable {
	let nextPageToken: String?
	let kind: String
	let incompleteSearch: Bool
	let files: [DriveFile]
}

struct DriveFileListResponseData: Codable {
	let incompleteSearch: Bool
	let kind: String
	let files: [DriveFile]
}

struct DriveFile: Codable {
	let kind: String?
	let id: String?
	let name: String
	let mimeType: String?
}
