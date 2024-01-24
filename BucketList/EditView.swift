//
//  EditView.swift
//  BucketList
//
//  Created by Alex on 21.01.2024.
//

import SwiftUI

struct EditView: View {    
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: ViewModel
    let onSave: (Location) -> Void
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        _viewModel = State(initialValue: ViewModel(location: location))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }
                
                Section("Nearby..") {
                    switch viewModel.loadingState {
                    case .loading:
                        Text("Loading")
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Save") {     
                    viewModel.saveNewLocation {
                        onSave($0)
                    }
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchNearbyPlaces()
            }
        }
    }        
}

#Preview {
    EditView(location: Location.example, onSave: { _ in })
}
