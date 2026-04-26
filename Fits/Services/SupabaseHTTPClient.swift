//
//  SupabaseHTTPClient.swift
//  Fits
//
//  Lightweight Supabase client via URLSession — no SDK package required.
//  Implements the Supabase REST API + Auth + Storage directly over HTTP.
//

import Foundation

// MARK: - Session

struct AuthSession {
    let accessToken: String
    let userId: UUID
    let expiresAt: Date
    var isExpired: Bool { Date() >= expiresAt }
}

// MARK: - Client

@MainActor
final class SupabaseHTTPClient {
    static let shared = SupabaseHTTPClient()

    private let baseURL: URL
    private let anonKey: String
    private(set) var session: AuthSession?

    var currentUserId: UUID? { session?.accessToken != nil ? session?.userId : nil }

    var authHeaders: [String: String] {
        var headers = [
            "apikey": anonKey,
            "Content-Type": "application/json"
        ]
        if let token = session?.accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

    init() {
        self.baseURL = URL(string: Secrets.supabaseURL)!
        self.anonKey = Secrets.supabaseAnonKey
    }

    // MARK: - REST Queries

    func select<T: Decodable>(
        table: String,
        filters: [String: String] = [:],
        order: String? = nil,
        limit: Int? = nil,
        single: Bool = false
    ) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent("rest/v1/\(table)"), resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "select", value: "*")]
        for (col, val) in filters {
            queryItems.append(URLQueryItem(name: col, value: "eq.\(val)"))
        }
        if let order { queryItems.append(URLQueryItem(name: "order", value: order)) }
        if let limit { queryItems.append(URLQueryItem(name: "limit", value: "\(limit)")) }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }
        if single { request.setValue("application/vnd.pgrst.object+json", forHTTPHeaderField: "Accept") }
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    func selectIn<T: Decodable>(
        table: String,
        column: String,
        values: [String]
    ) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent("rest/v1/\(table)"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: column, value: "in.(\(values.joined(separator: ",")))")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    func selectLike<T: Decodable>(
        table: String,
        column: String,
        pattern: String,
        limit: Int? = nil
    ) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent("rest/v1/\(table)"), resolvingAgainstBaseURL: false)!
        var queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: column, value: "ilike.*\(pattern)*")
        ]
        if let limit { queryItems.append(URLQueryItem(name: "limit", value: "\(limit)")) }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    func insert(table: String, body: [String: Any]) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("rest/v1/\(table)"))
        request.httpMethod = "POST"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        _ = try await URLSession.shared.data(for: request)
    }

    func batchInsert(table: String, body: [[String: Any]]) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("rest/v1/\(table)"))
        request.httpMethod = "POST"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        _ = try await URLSession.shared.data(for: request)
    }

    func upsert(table: String, body: [String: Any]) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("rest/v1/\(table)"))
        request.httpMethod = "POST"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }
        request.setValue("return=minimal,resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        _ = try await URLSession.shared.data(for: request)
    }

    func update(table: String, filters: [String: String], body: [String: Any]) async throws {
        var components = URLComponents(url: baseURL.appendingPathComponent("rest/v1/\(table)"), resolvingAgainstBaseURL: false)!
        components.queryItems = filters.map { URLQueryItem(name: $0.key, value: "eq.\($0.value)") }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "PATCH"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - Auth

    func signInWithMagicLink(email: String) async throws {
        let url = baseURL.appendingPathComponent("auth/v1/otp")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw SupabaseHTTPError.authFailed("Magic link failed")
        }
    }

    func signInWithPassword(email: String, password: String) async throws {
        let url = baseURL.appendingPathComponent("auth/v1/token")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "grant_type", value: "password")]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])

        let (data, _) = try await URLSession.shared.data(for: request)
        let resp = try JSONDecoder().decode(AuthTokenResponse.self, from: data)
        setSession(resp)
    }

    func signInWithIdToken(provider: String, idToken: String, nonce: String) async throws {
        let url = baseURL.appendingPathComponent("auth/v1/token")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "grant_type", value: "id_token")]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "provider": provider,
            "id_token": idToken,
            "nonce": nonce
        ])

        let (data, _) = try await URLSession.shared.data(for: request)
        let resp = try JSONDecoder().decode(AuthTokenResponse.self, from: data)
        setSession(resp)
    }

    func signOut() async throws {
        let url = baseURL.appendingPathComponent("auth/v1/logout")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        for (k, v) in authHeaders { request.setValue(v, forHTTPHeaderField: k) }
        _ = try await URLSession.shared.data(for: request)
        session = nil
    }

    // MARK: - Storage

    func uploadFile(bucket: String, path: String, data: Data, contentType: String = "image/png") async throws -> String {
        let url = baseURL.appendingPathComponent("storage/v1/object/\(bucket)/\(path)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        if let token = session?.accessToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (responseData, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw SupabaseHTTPError.uploadFailed("Upload failed for \(path)")
        }

        _ = responseData
        return "\(Secrets.supabaseURL)/storage/v1/object/public/\(bucket)/\(path)"
    }

    // MARK: - Helpers

    private func setSession(_ resp: AuthTokenResponse) {
        guard let userId = UUID(uuidString: resp.user.id) else { return }
        session = AuthSession(
            accessToken: resp.accessToken,
            userId: userId,
            expiresAt: Date().addingTimeInterval(TimeInterval(resp.expiresIn))
        )
    }

    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { dec in
            let c = try dec.singleValueContainer()
            let s = try c.decode(String.self)
            if let date = fmt.date(from: s) { return date }
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Bad date: \(s)")
        }
        return d
    }()
}

// MARK: - Auth response types

private struct AuthTokenResponse: Decodable {
    let accessToken: String
    let expiresIn: Int
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn   = "expires_in"
        case user
    }
}

private struct AuthUser: Decodable {
    let id: String
}

// MARK: - Errors

enum SupabaseHTTPError: LocalizedError {
    case authFailed(String)
    case uploadFailed(String)
    case notAuthenticated
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .authFailed(let msg):    return "Auth failed: \(msg)"
        case .uploadFailed(let msg):  return "Upload failed: \(msg)"
        case .notAuthenticated:       return "Not authenticated"
        case .decodingFailed(let msg):return "Decoding failed: \(msg)"
        }
    }
}
