// Models/EditorViewModel.swift
import Foundation
import Combine

/// Holds the “current” dropdown style and emits one-off conversion events.
class EditorViewModel: ObservableObject {
    @Published var currentStyle: FontStyle = .normal
    let convertSelection = PassthroughSubject<FontStyle, Never>()
}
