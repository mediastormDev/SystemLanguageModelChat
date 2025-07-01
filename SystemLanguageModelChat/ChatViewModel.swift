//
//  ChatViewModel.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/20.
//

import SwiftUI
import FoundationModels
import Combine

class ChatViewModel: ObservableObject {
    @Published var chat: Chat
    
    @Published var generating: Bool = false
    
    @Published var message: String = ""
    
    @Published var welcomeMessage: String = ""
    
    @Published var available: Bool
    
    let todayDate = getLocalizedMonthDayWeekday()
    
    let chatManager: ChatManager = .shared
    
    let session: LanguageModelSession
    
    var modelStatus: String {
        .init(localized: SystemLanguageModel.modelAvailableStatus)
    }
    
    init(chat: Chat) {
        self.chat = chat
        self.session = if let trasncript = chat.modelTrasncript {
            LanguageModelSession(transcript: trasncript)
        } else {
            LanguageModelSession()
        }
        available = SystemLanguageModel.default.isAvailable
    }
    
    func generateWelcomeMessage() {
        Task {
            let session = LanguageModelSession() // Use different session from chat to eliminate contextual effects
            let stream = session.streamResponse(to: welcomeMessagePrompt)
            do {
                for try await partialResponse in stream {
                    welcomeMessage = partialResponse
                }
            } catch {
                print(error)
                let message = String(localized: "Hello! How can I assist you?")
                welcomeMessage = message
            }
        }
    }
    
    func generateTitle() async {
        guard let message = chat.messages.first(where: {$0.role == .user}) else {return}
        let session = LanguageModelSession(instructions: titleInstructionsPrompt) // Use different session from chat to eliminate contextual effects
        let stream = session.streamResponse(to: message.text)
        do {
            for try await partialResponse in stream {
                chat.title = partialResponse
            }
        } catch {
            print(error)
        }
    }
    
    func send() async {
        guard message != "", !generating else { return }
        let userMessage: Message = .init(text: message, role: .user)
        chat.messages.append(userMessage)
        if chat.title == nil {
            await generateTitle()
        }
        var aiMessage: Message = .init(text: String(localized: "Thinking..."), role: .ai)
        do {
            let stream = session.streamResponse(to: message)
            aiMessage.responding = true
            chat.messages.append(aiMessage)
            message = ""
            generating = true
            for try await partialResponse in stream {
                if let index = chat.messages.firstIndex(where: {$0.id == aiMessage.id}){
                    chat.messages[index].text = partialResponse
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
        chat.modelTrasncript = session.transcript
        save()
    }
    
    func save() {
        self.chatManager.updateChat(chat)
    }
    
}
