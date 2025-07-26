// Views/SidebarView.swift
import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var manager: DocumentManager
    @EnvironmentObject var viewModel: EditorViewModel
    @State private var showAccordion = true

    var body: some View {
        VStack(alignment: .leading) {
            Picker("Font Style", selection: $viewModel.currentStyle) {
                ForEach(FontStyle.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding([.top, .horizontal])
            .onChange(of: viewModel.currentStyle) { style in
                viewModel.convertSelection.send(style)
            }

            DisclosureGroup("Convert Selection", isExpanded: $showAccordion) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(FontStyle.allCases) { style in
                        Button(style.rawValue) {
                            viewModel.convertSelection.send(style)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 4)
                .frame(maxHeight: 300)
            }
            .padding(.horizontal)

            List(selection: Binding(
                get: { manager.selectedDocument },
                set: { manager.selectedDocument = $0 }
            )) {
                ForEach(manager.documents) { doc in
                    Text(doc.name)
                }
            }
            .listStyle(.sidebar)
        }
    }
}
