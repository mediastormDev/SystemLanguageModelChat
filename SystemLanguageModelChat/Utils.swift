//
//  Utils.swift
//  SystemLanguageModelChat
//
//  Created by Jerry Zhu on 2025/6/19.
//

import SwiftUI
import FoundationModels

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

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif

#if canImport(FoundationModels)
extension SystemLanguageModel {
    static var modelAvailableStatus: LocalizedStringResource {
        switch SystemLanguageModel.default.availability {
        case .available:
            "Apple Intelligence is available"
        case .unavailable(.deviceNotEligible):
            "Apple Intelligence is not supported on this device"
            // Show an alternative UI.
        case .unavailable(.appleIntelligenceNotEnabled):
            "Apple Intelligence is not turned on"
            // Ask the person to turn on Apple Intelligence.
        case .unavailable(.modelNotReady):
            "Apple Intelligence is not ready yet"
            // The model isn't ready because it's downloading or because of other system reasons.
        case .unavailable(_):
            "Apple Intelligence is unavailable"
            // The model is unavailable for an unknown reason.
        }
    }
}
#endif

func getLocalizedMonthDayWeekday(date: Date = Date(), locale: Locale = .current) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = locale
    
    dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd EEEE")
    
    return dateFormatter.string(from: date)
}

func getLocalizedTimestamp(from date: Date, locale: Locale = .current, calendar: Calendar = .current) -> String {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = locale
    dateFormatter.calendar = calendar

    let isToday = calendar.isDateInToday(date)
    let isSameYear = calendar.component(.year, from: date) == calendar.component(.year, from: now)

    if isToday {
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: date)
    } else if isSameYear {
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMdHmm") // 自动排序 + 本地化
        return dateFormatter.string(from: date)
    } else {
        dateFormatter.setLocalizedDateFormatFromTemplate("yMMMdHmm")
        return dateFormatter.string(from: date)
    }
}
