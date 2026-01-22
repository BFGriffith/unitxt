// Views/SidebarView.swift
import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var manager: DocumentManager
    @EnvironmentObject var viewModel: EditorViewModel

    @State private var showStyleButtons = true
    @State private var showDocsList     = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ─── Font‐Style “Dropdown” ───
            Menu {
                ForEach(FontStyle.allCases) { style in
                    Button(style.rawValue) {
                        viewModel.currentStyle = style
                        viewModel.convertSelection.send(style)
                    }
                }
            } label: {
                Text(viewModel.currentStyle.rawValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .padding(.horizontal)

            // ─── Style Buttons Accordion Toggle ───
            HStack {
                Button(action: { showStyleButtons.toggle() }) {
                    Image(systemName: showStyleButtons ? "chevron.down" : "chevron.right")
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.horizontal, 4)

            if showStyleButtons {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(FontStyle.allCases) { style in
                            Button(action: {
                                viewModel.convertSelection.send(style)
                            }) {
                                Text(style.rawValue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 300)
            }

            // ─── Documents Accordion Toggle with Label ───
            HStack {
                Button(action: { showDocsList.toggle() }) {
                    Image(systemName: showDocsList ? "chevron.down" : "chevron.right")
                }
                .buttonStyle(PlainButtonStyle())

                Text("📑 .txt 📄")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 4)

            if showDocsList {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(manager.documents) { doc in
                            Text(doc.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 300)
            }

            Spacer()
        }
        .padding(5) // 5px padding around all controls
    }
}
