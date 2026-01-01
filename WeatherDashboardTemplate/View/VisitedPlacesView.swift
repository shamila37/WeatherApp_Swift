//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.modelContext) private var context // Not used in body, but kept for completeness
    
    // MARK:  add local variables for this view
    
    //    var body: some View {
    //        VStack{
    //            Text("Image shows the information to be presented in this view")
    //            Spacer()
    //            Image("places")
    //                .resizable()
    //
    //            Spacer()
    //        }
    //        .frame(height: 600)
    //    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("My Visited Places")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.horizontal)
                .padding(.top, 10)
            
            List {
                ForEach(vm.visited) { place in
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.headline)
                        
                        Text("Lat: \(place.latitude), Lon: \(place.longitude)")
                            .font(.caption)
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    .onTapGesture {
                        Task {
                            await vm.loadLocation(fromPlace: place)
                            vm.selectedTab = 0
                        }
                    }
                    .onLongPressGesture {
                        let query = place.name.replacingOccurrences(of: " ", with: "+")
                        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .onDelete{ indexSet in
                    indexSet.map{ vm.visited[$0] }.forEach(vm.delete)
                }
            }
        }
        .navigationTitle("Stored Places")
        .scrollContentBackground(.hidden)
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
    VisitedPlacesView()
        .environmentObject(vm)
}
