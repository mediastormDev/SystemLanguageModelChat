//
//  ChatManager.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/19.
//

import SwiftUI
import Combine

class ChatManager: ObservableObject {
    
    static let shared = ChatManager()
    
    @Published var chats: [Chat] = []
    
    @Published var isLoadingChats: Bool = true
    
    private init() {
        Task {
            createChatsDirectoryIfNeeded()
            loadAllChats()
            isLoadingChats = false
        }
    }

    private let fileManager = FileManager.default

    private var chatsDirectory: URL {
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent("chats")
    }

    private func createChatsDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: chatsDirectory.path) {
            try? fileManager.createDirectory(at: chatsDirectory, withIntermediateDirectories: true)
        }
    }

    func saveChat(_ chat: Chat) {
        if let index = chats.firstIndex(where: {$0.id == chat.id}) {
            chats[index] = chat
        } else {
            chats.insert(chat, at: 0)
        }
        Task {
            let url = chatsDirectory.appendingPathComponent("\(chat.id.uuidString).json")
            do {
                let data = try JSONEncoder().encode(chat)
                try data.write(to: url, options: .atomic)
            } catch {
                print("❌ Save chat failed: \(error)")
            }
        }
        
    }

    func loadAllChats() {
            do {
                let files = try fileManager.contentsOfDirectory(at: chatsDirectory, includingPropertiesForKeys: nil)
                var chats: [Chat] = []
                for url in files where url.pathExtension == "json" {
                    if let chat = loadChat(from: url) {
                        chats.append(chat)
                    }
                }
                self.chats = chats.sorted(by: {$0.lastUpdatedAt > $1.lastUpdatedAt})
            } catch {
                print("❌ Load chats failed: \(error)")
            }
    }

    func loadChat(id: UUID) -> Chat? {
        let url = chatsDirectory.appendingPathComponent("\(id.uuidString).json")
        return loadChat(from: url)
    }

    private func loadChat(from url: URL) -> Chat? {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Chat.self, from: data)
        } catch {
            print("❌ Failed to load chat from (\(url.lastPathComponent)): \(error)")
            return nil
        }
    }

    func deleteChat(id: UUID) {
        chats = chats.filter { $0.id != id }
        Task {
            let url = chatsDirectory.appendingPathComponent("\(id.uuidString).json")
            do {
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                }
            } catch {
                print("❌ Delete chat failed: \(error)")
            }
        }
        
    }

    func updateChat(_ chat: Chat)  {
        var chat = chat
        chat.lastUpdatedAt = .now
        saveChat(chat)
        chats.sort(by: { $0.lastUpdatedAt > $1.lastUpdatedAt })
    }
}
