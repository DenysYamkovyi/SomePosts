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
    
    private let tokenKey = "apiToken"
    
    @discardableResult
    func saveToken(_ token: String) -> Bool {
        guard let tokenData = token.data(using: .utf8) else { return false }
        
        // Query to update an existing token.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: tokenData
        ]
        
        // Try to update first.
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecSuccess { return true }
        
        // If update fails (or item doesn't exist), add a new item.
        var newItem = query
        newItem[kSecValueData as String] = tokenData
        let addStatus = SecItemAdd(newItem as CFDictionary, nil)
        return addStatus == errSecSuccess
    }
    
    func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let tokenData = item as? Data,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            return nil
        }
        return token
    }
    
    @discardableResult
    func deleteToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
