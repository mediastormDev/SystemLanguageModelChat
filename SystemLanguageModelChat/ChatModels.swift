//
//  ChatModels.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/19.
//

import Foundation
import FoundationModels

struct Chat: Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String = "New Chat"
    var messages: [Message] = []
    var createdAt: Date = Date()
    var lastUpdatedAt: Date = Date()
    
    var modelTrasncript: Transcript?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    
    var lastMessage: Message? {
        return messages.last
    }
}

struct Message: Codable, Hashable {
    
    enum Role: Codable {
        case ai
        case user
        
        var title: String {
            switch self {
            case .ai:
                return "System Language Model"
            case .user:
                return "You"
            }
        }
    }
    
    var id: UUID = UUID()
    var text: String
    var error: String?
    let role: Role
    var responding: Bool = false
    
}
