//
//  Utils.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/19.
//

import SwiftUI

struct FlowingRainbowBackground: View {
    @State private var currentGradientIndex = 0
    var displayColorCount: Int = 2
    @State var colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .indigo,
        .purple, .pink, .cyan, .mint, .teal, .brown
    ]
    
    var displayedColors: [Color] {
        (0..<displayColorCount).map { i in
            colors[(currentGradientIndex + i) % colors.count]
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: displayedColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 2), value: currentGradientIndex)
            .ignoresSafeArea()
        }
        .onAppear {
            colors.shuffle()
            withAnimation {
                currentGradientIndex = Int.random(in: 0 ..< colors.count)
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                withAnimation {
                    currentGradientIndex = (currentGradientIndex + 1) % colors.count
                }
            }
        }
    }
}


func getLocalizedMonthDayWeekday(date: Date = Date()) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .init(identifier: "en-US")
    dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
    let monthDayString = dateFormatter.string(from: date)

    dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
    let weekdayString = dateFormatter.string(from: date)
    
    return "\(monthDayString)  \(weekdayString)"
}
