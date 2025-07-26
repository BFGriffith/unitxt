// 𝐔𝐍𝐈𝐓𝐗𝐓: 🗒️ A simple＆unobtrusive Unicode CHARACTERS focused Text‑Editor 📄
// UniTXT.swift
// UniTXTApp.swift
import SwiftUI

@main
struct UniTXTApp: App {
    @StateObject private var manager   = DocumentManager()
    @StateObject private var viewModel = EditorViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
                .environmentObject(viewModel)
        }
    }
}
