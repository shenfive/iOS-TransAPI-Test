//
//  ContentView.swift
//  TransAPI
//
//  Created by DannyShen on 2025/6/23.
//
import SwiftUI
import Translation

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = "Hello"
    @State private var session: TranslationSession?

    // 五個語言選項
    let languages: [(label: String, lang: Locale.Language)] = [
        ("ZH-TW 🇹🇼", Locale.Language(identifier: "zh-Hant")),
        ("ZH-CN 🇨🇳", Locale.Language(identifier: "zh-Hans")),
        ("English 🇬🇧🇺🇸", Locale.Language(identifier: "en")),
        ("Korean 🇰🇷🇰🇵", Locale.Language(identifier: "ko")),
        ("Japanese 🇯🇵", Locale.Language(identifier: "ja"))
    ]
    @State private var selectedIndex = 2  // 預設 English

    var targetLang: Locale.Language {
        languages[selectedIndex].lang
    }

    var body: some View {
        VStack(spacing: 16) {
            // 輸入框
            TextEditor(text: $inputText)
                .frame(height: 130)
                .border(.gray)

            // 翻譯按鈕
            Button("翻譯") {
                Task {
                    await performTranslation()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            // 輸出框（只讀）
            TextEditor(text: $outputText)
                .frame(height: 130)
                .border(.gray)
                .disabled(true)

            // Segmented 語言選擇
            Picker("目標語言", selection: $selectedIndex) {
                ForEach(languages.indices, id: \.self) { idx in
                    Text(languages[idx].label)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .translationTask(source: Locale.Language(identifier: "zh-Hant"),
                         target: targetLang) { newSession in
            // 系統會在語言改變時自動建立新的 session
            session = newSession
        }
    }

    // 翻譯邏輯：由使用者點擊按鈕觸發
    func performTranslation() async {
        guard let session = session else {
            outputText = "翻譯引擎未就緒，請稍後。"
            return
        }

        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            outputText = "請先輸入文字。"
            return
        }

        do {
            outputText = try await session.translate(inputText).targetText
        } catch {
            outputText = "翻譯失敗：\(error.localizedDescription)"
        }
    }
}


#Preview {
    ContentView()
}
