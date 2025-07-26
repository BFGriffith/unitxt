// Models/DocumentManager.swift
import Foundation

struct TextDocument: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var url: URL?
    var content: String
}

class DocumentManager: ObservableObject {
    @Published var documents: [TextDocument] = []
    @Published var selectedDocument: TextDocument?

    private var documentsFolder: URL {
        let fm = FileManager.default
        return fm.homeDirectoryForCurrentUser.appendingPathComponent("Documents")
    }

    init() { load() }
    func load() {
        documents.removeAll()
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
                at: documentsFolder,
                includingPropertiesForKeys: nil) else { return }
        for file in files where file.pathExtension == "txt" {
            let txt  = (try? String(contentsOf: file)) ?? ""
            let name = file.deletingPathExtension().lastPathComponent
            documents.append(TextDocument(name: name, url: file, content: txt))
        }
        if selectedDocument == nil {
            selectedDocument = documents.first
        }
    }

    func createDocument() {
        let n = documents.filter { $0.name.starts(with: "Untitled") }.count + 1
        let name = "Untitled\(n)"
        let url  = documentsFolder.appendingPathComponent("\(name).txt")
        let doc  = TextDocument(name: name, url: url, content: "")
        documents.append(doc)
        selectedDocument = doc
        save(doc)
    }

    func save(_ doc: TextDocument) {
        guard let url = doc.url else { return }
        try? doc.content.write(to: url, atomically: true, encoding: .utf8)
        load()
    }

    func delete(_ doc: TextDocument) {
        guard let url = doc.url else { return }
        try? FileManager.default.removeItem(at: url)
        documents.removeAll { $0.id == doc.id }
        selectedDocument = documents.first
    }
}
