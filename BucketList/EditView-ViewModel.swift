//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Alex on 24.01.2024.
//

import Foundation

extension EditView {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Observable
    final class ViewModel {
        var location: Location
        var name: String
        var description: String
        var loadingState = LoadingState.loading
        var pages: [Page] = []
                
        init(location: Location) {
            _location = location
            _name = location.name
            _description = location.description
        }
        
        func saveNewLocation(completion: (Location) -> Void) {
            var newLocation = location
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.description = description
            completion(newLocation)
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let items = try JSONDecoder().decode(Result.self, from: data)
                
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                loadingState = .failed
            }
        }
    }
}
