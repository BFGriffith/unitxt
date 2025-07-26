// Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: DocumentManager

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            if let doc = manager.selectedDocument {
                StyledTextView(
                    text: Binding(
                        get: { doc.content },
                        set: { new in
                            if var sel = manager.selectedDocument {
                                sel.content = new
                                manager.selectedDocument = sel
                            }
                        }
                    )
                )
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("New", action: manager.createDocument)
                            .keyboardShortcut("N", modifiers: .command)
                        Button("Save") {
                            manager.selectedDocument.map(manager.save)
                        }
                        .keyboardShortcut("S", modifiers: .command)
                        Button("Delete", role: .destructive) {
                            manager.selectedDocument.map(manager.delete)
                        }
                        .keyboardShortcut(.delete)
                    }
                }
            } else {
                Text("Select or create a document")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
