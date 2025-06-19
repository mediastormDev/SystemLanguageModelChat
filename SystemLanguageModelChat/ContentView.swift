//
//  ContentView.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/18.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var chatManager: ChatViewModel = .shared
    
    @State private var path: NavigationPath = .init()
    var chats: [Chat] {
        chatManager.chats
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(chats, id: \.id) { chat in
                    Button {
                        path.append(chat)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(chat.title)
                                    .font(.headline)
                                Spacer()
                                Text(chat.lastUpdatedAt, style: .time)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            if let lastMessage = chat.lastMessage {
                                Text(lastMessage.text)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteChats)
            }
            .overlay{
                if chats.isEmpty {
                    VStack {
                        Text("No chats yet")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                        Button {
                           createChat()
                        } label: {
                            Text("Create a chat")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                }
            }
            .navigationTitle("Chats")
            .navigationBarItems(trailing: createChatButton)
            .navigationDestination(for: Chat.self) { chat in
                ChatView(chat: chat)
            }
        }
    }
    
    var createChatButton: some View {
        Button(action: {
            createChat()
        }) {
            Image(systemName: "plus")
        }
    }
    
    func createChat() {
        let chat = Chat()
        chatManager.saveChat(chat)
        path.append(chat)
    }
    
    func deleteChats(at offsets: IndexSet) {
        for offset in offsets {
            chatManager.deleteChat(id: chats[offset].id)
        }
    }
}

#Preview {
    ContentView()
}
