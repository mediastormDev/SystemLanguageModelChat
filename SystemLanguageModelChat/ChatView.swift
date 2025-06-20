//
//  ChatView.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/19.
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var viewModel: ChatViewModel
    
    var chat: Chat {
        viewModel.chat
    }
    
    var bindingTitle: Binding<String> {
        .init {
            viewModel.chat.title ?? .init(localized: "New Chat")
        } set: { title in
            viewModel.chat.title = title
            viewModel.save()
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
                                    HStack(spacing: 3) {
                                        if message.role == .ai {
                                            Image(systemName: "apple.intelligence")
                                        }
                                        Text(message.role.title)
                                    }
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
                    .background{
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.frame(in: .global)) { _, _ in
                                    guard !viewModel.generating else { return }
                                    hideKeyboard()
                                }
                        }
                    }
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
                                Text(viewModel.todayDate)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Text(LocalizedStringKey(viewModel.welcomeMessage))
                                    .font(.title2)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
//                            .animation(.default, value: welcomeMessage)
                        }
                    }
                Group{
                    if viewModel.available {
                        TextField("Input your message...", text: $viewModel.message)
                            .font(.subheadline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .clipShape(.capsule)
                            .glassEffect()
                            .onSubmit {
                                Task {
                                    await viewModel.send()
                                }
                            }
                    } else {
                        HStack(spacing: 3){
                            Spacer()
                            Image(systemName: "apple.intelligence")
                            Text(viewModel.modelStatus)
                            Spacer()
                        }
                        .foregroundStyle(.red)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(content: {
                    LinearGradient(colors: [.clear, .init(uiColor: .systemBackground)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                })
            }
        }
        .navigationTitle(bindingTitle)
        .navigationSubtitle(viewModel.available ? viewModel.modelStatus : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.generateWelcomeMessage()
        }
    }
}
