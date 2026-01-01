//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    // MARK:  add other necessary variables
    var body: some View {
        VStack{
            //            Text("Image shows the information to be presented in this view")
            //            Spacer()
            //            Image("map")
            //                .resizable()
            //
            //
            //            Spacer()
            Map(coordinateRegion: $vm.mapRegion, annotationItems: vm.pois){ poi in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: poi.latitude, longitude: poi.longitude
                    )
                ) {
                    VStack{
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text(poi.name)
                            .font(.caption)
                            .padding(5)
                            .background()
                            .cornerRadius(8)
                    }
                    .onTapGesture {
                        vm.focus(
                            on: CLLocationCoordinate2D(
                                latitude: poi.latitude,
                                longitude: poi.longitude
                            ),
                            zoom: 0.005
                        )
                    }
                    .onLongPressGesture {
                        let query = poi.name.replacingOccurrences(of: " ", with: "+")
                        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            
            Text("Top 5 tourist attraction places in \(vm.activePlaceName)")
                .font(.headline)
                .padding(.horizontal)
            
            List(vm.pois) { poi in
                Text(poi.name)
                    .onTapGesture {
                        vm.focus(
                            on: CLLocationCoordinate2D(
                                latitude: poi.latitude,
                                longitude: poi.longitude
                            ),
                            zoom: 0.005
                        )
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Place Map")
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.35), .cyan.opacity(0.15), .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}
