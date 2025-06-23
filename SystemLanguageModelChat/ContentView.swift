//
//  ContentView.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/18.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var chatManager: ChatManager = .shared
    
    @State private var path: NavigationPath = .init()
    var chats: [Chat] {
        chatManager.chats
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    ForEach(chats, id: \.id) { chat in
                        Button {
                            path.append(chat)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(chat.title ?? String(localized: "New Chat"))
                                        .font(.headline)
                                    Spacer()
                                    Text(getLocalizedTimestamp(from: chat.lastUpdatedAt))
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteChats)
                } footer: {
                    if !chatManager.chats.isEmpty {
                        HStack{
                            Spacer()
                            HStack(spacing: 3){
                                Image(systemName: "apple.intelligence")
                                Text("Apple Intelligence")
                            }
                            .font(.footnote)
                            Spacer()
                        }
                    }
                }
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
            .navigationSubtitle("Chat with Apple Intelligence")
            .navigationBarItems(trailing: createChatButton)
            .navigationDestination(for: Chat.self) { chat in
                ChatView(viewModel: .init(chat: chat))
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
