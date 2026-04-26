import Foundation

final class ImageUploadService {
    static let shared = ImageUploadService()

    private let http = SupabaseHTTPClient.shared

    func uploadItemImage(_ imageData: Data, fileName: String = UUID().uuidString) async throws -> String {
        let path = "items/\(fileName).png"
        return try await http.uploadFile(bucket: "clothing", path: path, data: imageData)
    }

    func uploadAvatarImage(_ imageData: Data, userId: UUID) async throws -> String {
        let path = "avatars/\(userId.uuidString).png"
        return try await http.uploadFile(bucket: "avatars", path: path, data: imageData)
    }
}
