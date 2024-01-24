//
//  ContentView.swift
//  BucketList
//
//  Created by Alex on 23.12.2023.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @State private var switchMapStyle = false
    
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack {
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 40, height: 40)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(switchMapStyle ? .hybrid : .standard)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                }
                
                Button {
                    switchMapStyle.toggle()
                } label: {
                    Image(systemName: switchMapStyle ? "map.fill" : "map")
                }
                .buttonStyle(.borderedProminent)
                .offset(x: 150, y: -350)
            }
        } else {
            Button("Unlock map", action: viewModel.authenticate)
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ContentView()
}
