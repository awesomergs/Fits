import Foundation

final class ImageUploadService {
    static let shared = ImageUploadService()

    func uploadItemImage(_ imageData: Data, fileName: String = UUID().uuidString) -> String {
        "mock://items/\(fileName).png"
    }

    func uploadAvatarImage(_ imageData: Data, userId: UUID) -> String {
        "mock://avatars/\(userId.uuidString).png"
    }
}
