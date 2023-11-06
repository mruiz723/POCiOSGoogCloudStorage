//
//  GoogleDriveService.swift
//  POCGoogleCloudStorage
//
//  Created by Marlon Ruiz on 24/09/23.
//

import Foundation
import GoogleSignIn
import UniformTypeIdentifiers

public struct FileRequest: Codable {
	public let name: String
	public let contentType: String?
	public let content: String
}


enum NetworkError: Error {
	case invalidURL
	case requestFailed(Error)
	case invalidResponse
	case invalidData
}

final class GoogleDriveService: ObservableObject {
	static let driveScope = "https://www.googleapis.com/auth/drive.file"
	private let baseUrlString = "https://www.googleapis.com/drive/v3/files"
	let query: [String: String]? = nil
	
	private lazy var components: URLComponents? = {
		var comps = URLComponents(string: baseUrlString)
		if let query = query {
			components?.queryItems = query.map { key, value in URLQueryItem(name: key, value: value) }
		}
		return comps
	}()
	
	private lazy var request: URLRequest? = {
		guard let components = components, let url = components.url else {
			return nil
		}
		return URLRequest(url: url)
	}()
	
	private lazy var session: URLSession? = {
		guard let accessToken = GIDSignIn
			.sharedInstance
			.currentUser?
			.accessToken
			.tokenString else { return nil }
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = [
			"Authorization": "Bearer \(accessToken)"
		]
		return URLSession(configuration: configuration)
	}()
	
	private func sessionWithFreshToken() async throws -> URLSession {
		return try await withCheckedThrowingContinuation { continuation in
			GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
				guard let token = user?.accessToken.tokenString else {
					
					continuation.resume(throwing: GoogleDriveService.Error.couldNotCreateURLSession(error))
					return
				}
				let configuration = URLSessionConfiguration.default
				configuration.httpAdditionalHeaders = [
					"Authorization": "Bearer \(token)"
				]
				let session = URLSession(configuration: configuration)
				continuation.resume(with: .success(session))
			}
		}
	}
	
	func fetchFiles() async throws -> [DriveFile] {
		// Create a URLRequest
		guard
			let request = request
		else {
			throw GoogleDriveService.Error.couldNotCreateURLRequest
		}
		do {
			// Use the `try await` syntax to perform the network request
			let (data, _) = try await sessionWithFreshToken().data(for: request)
			let model = try JSONDecoder().decode(DriveFileResponseData.self, from: data)
			return model.files
		} catch {
			throw NetworkError.requestFailed(error)
		}
	}

	func uploadFileToFolder(fileURL: URL, folderID: String) async throws -> DriveFile {
		var request = URLRequest(url: URL(string: "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")!)
		// Prepare the request body
		let boundary = UUID().uuidString
		request.httpMethod = "POST"
		request.setValue("multipart/related; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		
		let body = createMultipartBody(fileURL: fileURL, folderID: folderID, boundary: boundary)
		request.httpBody = body
		
		do {
			let (data, _) = try await sessionWithFreshToken().data(for: request)
			print(String(data: data, encoding: .utf8)!)
			let model = try JSONDecoder().decode(DriveFile.self, from: data)
			return model
		} catch {
			throw(error)
		}
	}

	func createMultipartBody(fileURL: URL, folderID: String, boundary: String) -> Data {
		var body = Data()

		// Add metadata for the file
		let metadata = [
			"name": fileURL.lastPathComponent,  // Use the file name as it is
			"parents": [folderID]  // Set the parent folder ID
		] as [String : Any]

		body.append("--\(boundary)\r\n")
		body.append("Content-Type: application/json; charset=UTF-8\r\n\r\n")
		body.append(try! JSONSerialization.data(withJSONObject: metadata))

		// Add the file content
		body.append("\r\n--\(boundary)\r\n")
		body.append("Content-Type: application/octet-stream\r\n\r\n")
		body.append(try! Data(contentsOf: fileURL)) // Load the file content

		body.append("\r\n--\(boundary)--\r\n")

		return body
	}


	func checkIfFolderExistsInDrive(folderName: String) async throws -> DriveFile? {
		do {
			// Set up the request URL
			var components = URLComponents(string: "https://www.googleapis.com/drive/v3/files")!
			let escapedFolderName = folderName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
			let query = "mimeType='application/vnd.google-apps.folder' and name='\(escapedFolderName)' and trashed=false"

			components.query = query

			guard let url = components.url else {
				print("Error: Unable to create URL")
				return nil
			}

			// Print statement for debugging
			print("Request URL:", url)

			// Create the request
			var request = URLRequest(url: url)
			request.httpMethod = "GET"

			// Perform the request
			let (data, response) = try await sessionWithFreshToken().data(for: request)
			
			// Check the response status code
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
				print("Error: Unexpected status code \(response)")
				return nil
			}
			
			// Deserialize JSON response
			guard let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
				print("Error: Unexpected JSON format")
				return nil
			}
			
			print(responseJSON)
			
			if let folders = responseJSON["files"] as? [[String: Any]] {
				print(folders)
			}
			
			let model = try JSONDecoder().decode(DriveFileListResponseData.self, from: data)
			return model.files.first { $0.name == folderName }

		} catch {
			print("Error: \(error)")
			throw error
		}
	}

	
	func createFolderInDrive(folderName: String) async throws -> DriveFile {
		// Create a URLRequest
		guard
			var request = request
		else {
			throw GoogleDriveService.Error.couldNotCreateURLRequest
		}

		// Prepare the request body
		let requestBody: [String: Any] = [
			"name": folderName,
			"mimeType": "application/vnd.google-apps.folder"
		]

		// Serialize the request body to JSON
		let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

		// Setup request
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData

		do {
			// Perform the request
			let (data, _) = try await sessionWithFreshToken().data(for: request)
			let model = try JSONDecoder().decode(DriveFile.self, from: data)
			// Print the response (you can handle it as needed)
			print("Folder created successfully:")
			return model
		} catch {
			throw error
		}
	}
	
	func generateCurlCommand(from request: URLRequest) -> String? {
		guard let url = request.url else {
			return nil
		}
		
		var command = "curl '\(url.absoluteString)'"
		
		if let httpMethod = request.httpMethod, httpMethod != "GET" {
			command += " -X \(httpMethod)"
		}
		
		if let headers = request.allHTTPHeaderFields {
			for (key, value) in headers {
				command += " -H '\(key): \(value)'"
			}
		}
		
		if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
			command += " -d '\(bodyString)'"
		}
		
		return command
	}

	
}

extension GoogleDriveService {
	/// An error representing what went wrong in fetching user's files
	enum Error: Swift.Error {
		case couldNotCreateURLSession(Swift.Error?)
		case couldNotCreateURLRequest
		case userHasNoBirthday
		case couldNotFetchBirthday(underlying: Swift.Error)
	}
	
	 private func encodeBody<Model: Codable>(_ model: Model) throws -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
		return try encoder.encode(model)
	}
}

extension URL {
	
	var mimeType: String {
		return UTType(filenameExtension: self.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
	}
	
	func contains(_ uttype: UTType) -> Bool {
		return UTType(mimeType: self.mimeType)?.conforms(to: uttype) ?? false
	}
}

