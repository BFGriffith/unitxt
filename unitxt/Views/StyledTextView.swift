// Views/StyledTextView.swift
import SwiftUI
import Combine
import AppKit

struct StyledTextView: NSViewRepresentable {
    @Binding var text: String
    @EnvironmentObject var viewModel: EditorViewModel

    func makeNSView(context: Context) -> NSTextView {
        let tv = NSTextView()
        tv.isRichText = false
        tv.isEditable = true
        tv.font       = .monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.delegate   = context.coordinator
        tv.string     = text
        context.coordinator.textView = tv

        // Subscribe to conversion events
        context.coordinator.subConvert = viewModel.convertSelection
            .receive(on: RunLoop.main)
            .sink { style in
                context.coordinator.convertSelection(to: style)
                text = tv.string
            }
        // Subscribe to typing-style changes
        context.coordinator.subStyle = viewModel.$currentStyle
            .sink { style in
                context.coordinator.currentStyle = style
            }

        return tv
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if nsView.string != text {
            nsView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var currentStyle: FontStyle = .normal
        weak var textView: NSTextView?
        var selectedRange: NSRange = .init(location: 0, length: 0)

        var subConvert: AnyCancellable?
        var subStyle:   AnyCancellable?

        init(text: Binding<String>) {
            self.text = text
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            if let tv = notification.object as? NSTextView {
                selectedRange = tv.selectedRange()
            }
        }

        func textDidChange(_ notification: Notification) {
            if let tv = notification.object as? NSTextView {
                text.wrappedValue = tv.string
            }
        }

        func textView(_ tv: NSTextView,
                      shouldChangeTextIn affectedCharRange: NSRange,
                      replacementString str: String?) -> Bool
        {
            guard let s = str else { return true }
            var didMap = false
            let out = s.map { c -> Character in
                let m = FontStyleMapper.shared.map(c, style: currentStyle)
                if m != c { didMap = true }
                return m
            }
            if didMap {
                let styled = String(out)
                tv.replaceCharacters(in: affectedCharRange, with: styled)
                text.wrappedValue = tv.string
                return false
            }
            return true
        }

        /// Convert exactly the last‐tracked selection to the given style.
        func convertSelection(to style: FontStyle) {
            guard let tv = textView, selectedRange.length > 0 else { return }
            let ns  = tv.string as NSString
            let sub = ns.substring(with: selectedRange)
            let conv = sub.map {
                FontStyleMapper.shared.map($0, style: style)
            }.map(String.init).joined()

            tv.replaceCharacters(in: selectedRange, with: conv)
            tv.setSelectedRange(
                NSRange(location: selectedRange.location,
                        length: conv.utf16.count)
            )
        }
    }
}
