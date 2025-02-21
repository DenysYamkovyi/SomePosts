//
//  KeychainService.swift
//  LeagueiOSChallenge
//
//  Created by macbook pro on 2025-02-20.
//

import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    private init() {}
    
    // Generic save function for any Codable type.
    @discardableResult
    func save<T: Codable>(value: T, forKey key: String) -> Bool {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(value) else {
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        // Try updating an existing item.
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecSuccess { return true }
        
        // If update fails (or item doesn't exist), add a new item.
        var newItem = query
        newItem[kSecValueData as String] = data
        let addStatus = SecItemAdd(newItem as CFDictionary, nil)
        return addStatus == errSecSuccess
    }
    
    // Generic load function for any Codable type.
    func load<T: Codable>(forKey key: String) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
    
    @discardableResult
    func deleteValue(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Convenience Methods
    
    @discardableResult
    func saveToken(_ token: String) -> Bool {
        return save(value: token, forKey: "apiToken")
    }
    
    func loadToken() -> String? {
        return load(forKey: "apiToken")
    }
    
    @discardableResult
    func saveGuestLogin(_ isGuest: Bool) -> Bool {
        return save(value: isGuest, forKey: "isGuestLogin")
    }
    
    func loadGuestLogin() -> Bool? {
        return load(forKey: "isGuestLogin")
    }
    
    @discardableResult
    func saveUser(_ user: UserResponse) -> Bool {
        return save(value: user, forKey: "user")
    }
    
    func loadUser() -> UserResponse? {
        return load(forKey: "user")
    }
    
    @discardableResult
    func deleteToken() -> Bool {
        return deleteValue(forKey: "apiToken")
    }
    
    @discardableResult
    func deleteUser() -> Bool {
        return deleteValue(forKey: "user")
    }
    
    @discardableResult
    func deleteGuestLogin() -> Bool {
        return deleteValue(forKey: "isGuestLogin")
    }
}
