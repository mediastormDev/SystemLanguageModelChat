//
//  ChatView.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/19.
//

import SwiftUI
import FoundationModels

struct ChatView: View {
    
    @ObservedObject var chatManager: ChatViewModel = .shared
    
    let session: LanguageModelSession
    
    @State var chat: Chat
    
    @State var generating: Bool = false
    @State var message: String = ""
    
    @State var welcomeMessage: String = ""
    
    let todayDate = getLocalizedMonthDayWeekday()
    
    init(chat: Chat) {
        self.chat = chat
        self.session = if let trasncript = chat.modelTrasncript {
            LanguageModelSession(transcript: trasncript)
        } else {
            LanguageModelSession()
        }
    }
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(chat.messages, id: \.id) { message in
                            HStack{
                                if message.role == .user {
                                    Spacer(minLength: 0)
                                }
                                VStack(alignment: message.role == .ai ? .leading : .trailing) {
                                    Text(message.role.title)
                                        .textSelection(.enabled)
                                        .font(.caption.weight(.bold))
                                    VStack(alignment: .leading){
                                        Text(LocalizedStringKey(message.text))
                                            .textSelection(.enabled)
                                            .font(.subheadline)
                                        if let error = message.error {
                                            Text("\n\nError:\n" + error)
                                                .textSelection(.enabled)
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background {
                                        GeometryReader { geometry in
                                            ZStack{
                                                if message.responding{
                                                    FlowingRainbowBackground()
                                                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10), isEnabled: true)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .animation(nil, value: message.text)
                                                        .opacity(0.3)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                                }
                                            }
                                            .animation(.default, value: message.responding)
                                            .onChange(of: geometry.size) { _, _ in
                                                withAnimation {
                                                    proxy.scrollTo("bottom", anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                if message.role == .ai {
                                    Spacer(minLength: 0)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 3)
                        }
                        Spacer()
                            .frame(height: 70)
                            .id("bottom")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .onAppear{
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            VStack{
                Color.clear
                    .overlay {
                        if chat.messages.isEmpty {
                            VStack(spacing: 0){
                                Text(todayDate)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Text(LocalizedStringKey(welcomeMessage))
                                    .font(.title2)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
//                            .animation(.default, value: welcomeMessage)
                        }
                    }
                TextField("Input your message...", text: $message)
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .clipShape(.capsule)
                    .glassEffect()
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(content: {
                        LinearGradient(colors: [.clear, .init(uiColor: .systemBackground)], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                    })
                    .onSubmit {
                        Task {
                            await send()
                        }
                    }
            }
        }
        .navigationTitle($chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await welconeMessage()
        }
        .onChange(of: chat) { _, newValue in
            self.chatManager.updateChat(newValue)
        }
    }
    
    func welconeMessage() async {
        let session = LanguageModelSession() // Use different session from chat to eliminate contextual effects
        let stream = session.streamResponse(to: "Generate a greeting suitable for starting a casual chat with someone. It should not exceed 15 words, the tone should be natural and friendly, and the content should be random." )
        do {
            for try await partialResponse in stream {
                welcomeMessage = partialResponse
            }
        } catch {
            print(error)
            welcomeMessage = "Hello! How can I assist you?"
        }
    }
    
    func generateTitle() {
        Task {
            guard let message = chat.messages.first else {return}
            if message.role == .user {
                let session = LanguageModelSession() // Use different session from chat to eliminate contextual effects
                let stream = session.streamResponse(to:
                                                        "User's question：\n\(message.text)\n\nGenerate a suitable conversation title for this question, no more than 10 words, no punctuation, and the preferred language is the user input language"
                )
                do {
                    for try await partialResponse in stream {
                        chat.title = partialResponse
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func send() async {
        guard message != "", !generating else { return }
        let userMessage: Message = .init(text: .init(message), role: .user)
        chat.messages.append(userMessage)
        if chat.messages.count == 1 {
            generateTitle()
        }
        var aiMessage: Message = .init(text: "Thinking...", role: .ai)
        do {
            let stream = session.streamResponse(to: message)
            aiMessage.responding = true
            chat.messages.append(aiMessage)
            message = ""
            generating = true
            for try await partialResponse in stream {
                if let index = chat.messages.firstIndex(where: {$0.id == aiMessage.id}){
                    chat.messages[index].text = .init(partialResponse)
                }
            }
            generating = false
            if let index = chat.messages.firstIndex(where: {$0.id == aiMessage.id}){
                chat.messages[index].responding = false
            }
        } catch {
            print(error)
            generating = false
            if let index = chat.messages.firstIndex(where: {$0.id == aiMessage.id && $0.role == .ai}){
                chat.messages[index].error = "\(error)"
                chat.messages[index].responding = false
            }
        }
    }
}
