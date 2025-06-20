//
//  Prompts.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/20.
//

import Foundation

func welcomeMessagePrompt() -> String {
    String(localized: "Welcome message generation prompt")
}

func generateChatTitlePrompt(userMessage: String) -> String {
//    String(localized: "Title generation prompt for message \(userMessage)")
        """
        Given the following user message, generate a concise and informative conversation title in the **same language** as the user message. Only return the title itself — do not include any labels, prefixes, or punctuation.
                                                                
        User message: \(userMessage)
        """
}
