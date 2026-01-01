//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

@MainActor
final class MainAppViewModel: ObservableObject {
    @Published var query = ""
//    @Published var currentWeather: Weather?
    @Published var currentWeather: Current?
//    @Published var forecast: [Weather] = []
    @Published var forecast: [Daily] = []
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var activePlaceName: String = ""
    private let defaultPlaceName = "London"
    @Published var selectedTab: Int = 0
//    private var lastLoadedPlaceId: UUID?
    
    /// Create and use a WeatherService model (class) to manage fetching and decoding weather data
    private let weatherService = WeatherService()
    
    /// Create and use a LocationManager model (class) to manage address conversion and tourist places
    private let locationManager = LocationManager()
    
    /// Use a context to manage database operations
    private let context: ModelContext
    
    init(context: ModelContext) {
        // Initialize the ModelContext and attempt to fetch previously visited places from SwiftData, sorted by most recent use.
        // If no visited places exist (first launch), load the default location.
        // Otherwise, load the most recently used place.
        self.context = context
        
        // Corrected FetchDescriptor to include sorting by 'lastUsedAt' in reverse order.
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            visited = results
        }
        
        // First launch: no data → perform full London setup
        if visited.isEmpty {
            Task {
                await loadDefaultLocation()
            }
        } else if let mostRecent = visited.first {
            // Otherwise, load most recently used place
            Task {
                await loadLocation(fromPlace: mostRecent)
            }
        }
    }
    
    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespaces)
        guard !city.isEmpty else {
            appError = .missingData(message: "Please enter a valid location.")
            return
        }
        Task {
            do {
                // MARK: call loadLocation(byName:)
                try await loadLocation(byName: city)
                query = ""
            } catch {
                appError = .networkError(error)
            }
        }
    }
    func loadDefaultLocation() async {
        // Attempts to select and load the hardcoded default location name.
        // If an error occurs during selection, sets an app error.
        do {
            try await loadLocation(byName: defaultPlaceName)
        } catch {
            appError = .networkError(error)
        }
    }
    
    func search() async throws {
        // If the query is not empty, calls `select(placeNamed:)` with the current query string.
        let city = query.trimmingCharacters(in: .whitespaces)
//        guard !city.isEmpty else { return }
        guard !city.isEmpty else {
            throw WeatherMapError.missingData(message: "Please enter a valid location.")
        }
        try await loadLocation(byName: city)
    }
    
    /// Validate weather before saving a new place; create POI children once.
    func loadLocation(byName: String) async throws {
        // Sets loading state, then attempts to load data for the given place name.
        isLoading = true
        defer { isLoading = false }
        
        do{
            // 1. Checks if the place is already in `visited` and, if so, loads all data for the existing `Place` object, updates its `lastUsedAt`, and saves the context.
            if let existing = visited.first(where: {
                $0.name.lowercased() == byName.lowercased()
            }) {
                existing.lastUsedAt = .now
                try context.save()
                await loadLocation(fromPlace: existing)
                //            appError = .missingData(message: "Load \(existing.name) from saved locations.")
                return
            }
            
            // 2. Otherwise, geocodes the fresh place name using `locationManager`.
            let geoCode = try await locationManager.geocodeAddress(byName)
            
            // 3. Fetches weather data using `weatherService` as a fail-fast check.
            let weather = try await weatherService.fetchWeather(
                lat: geoCode.lat,
                lon: geoCode.lon
            )
            
            // 4. Finds Points of Interest (POIs) using `locationManager`, converts them to `AnnotationModel`s, and associates them with the new `Place`.
            let fetchedPOIs = try await locationManager.findPOIs(
                lat: geoCode.lat,
                lon: geoCode.lon
            )
            
            let place = Place(
                name: geoCode.name,
                latitude: geoCode.lat,
                longitude: geoCode.lon
            )
            
            place.annotations.append(contentsOf: fetchedPOIs)
            
            // 5. Inserts the new `Place` into the `visited` array and saves the context.
            context.insert(place)
            try context.save()
            visited.insert(place, at: 0)
            
            // 6. Updates UI by setting `pois`, `activePlaceName`, and focusing the map.
            currentWeather = weather.current
            forecast = weather.daily
            pois = fetchedPOIs
            activePlaceName = geoCode.name
            
            focus(
                on: CLLocationCoordinate2D(
                    latitude: geoCode.lat,
                    longitude: geoCode.lon
                )
            )
            
            // 7. If any step fails, logs the error and reverts to the default location with an alert.
        }catch {
            appError = .missingData(message: "Failed to load location, Please try again later.")
            await loadDefaultLocation()
            throw error
        }
        
    }
    
    func loadLocation(fromPlace place: Place) async{
        // Sets loading state, then attempts to load all data for an existing `Place` object.
        do {
//            isLoading = true
//            
//            // Updates the place's `lastUsedAt` and saves the context upon success.
//            place.lastUsedAt = .now
//            try context.save()
//            
//            _ = try await weatherService.fetchWeather(lat: place.latitude, lon: place.longitude)
//            
//            activePlaceName = place.name
//            focus(on: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
            try await loadAll(for: place)
            
            // Catches and sets `appError` for any failure during the load process.
        } catch {
            appError = .networkError(error)
        }
    }
    
    private func revertToDefaultWithAlert(message: String) async {
        // Sets an `appError` with the given message, then calls `loadDefaultLocation()` to switch back to the default.
        appError = .missingData(message: message)
        await loadDefaultLocation()
    }
    
    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        // Animates the map region to center on the given coordinate with a specified zoom level (span).
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: zoom,
                longitudeDelta: zoom
            )
        )
    }
    
    private func loadAll(for place: Place) async throws {
        
//        if lastLoadedPlaceId == place.id {
//            return
//        }
//        
//        lastLoadedPlaceId = place.id
        
        isLoading = true
        defer { isLoading = false }
        
        // Sets `activePlaceName` and prints a loading message.
        activePlaceName = place.name
        print("Loading data for \(place.name)...")
        
        // Always refreshes weather data from the API.
//        do {
            let weatherResponse = try await weatherService.fetchWeather(
                lat: place.latitude,
                lon: place.longitude
            )
            
            currentWeather = weatherResponse.current
            forecast = weatherResponse.daily
            
            // Checks if the `Place` object has existing annotations (POIs).
            if place.annotations.isEmpty {
                
                // If annotations are empty, fetches new POIs via `MKLocalSearch`, converts them to `AnnotationModel`s, adds them to the `Place`, saves the context, and sets `self.pois`.
                let fetchedPOIs = try await locationManager.findPOIs(
                    lat: place.latitude,
                    lon: place.longitude
                )
                
                place.annotations.append(contentsOf: fetchedPOIs)
                try context.save()
                
                // If annotations exist, uses the cached list for `self.pois`.
                self.pois = fetchedPOIs
                
            } else {
                self.pois = place.annotations
            }
            
            // Calls `focus(on:zoom:)` to update the map view.
            focus(on: CLLocationCoordinate2D(
                latitude: place.latitude,
                longitude: place.longitude
            ))
            
            place.lastUsedAt = .now
            try context.save()
            
            // Ensures the place is at the top of the `visited` list (if not already).
//            if let index = visited.firstIndex(where: {$0.id == place.id}) {
            if let index = visited.firstIndex(of: place) {
                visited.remove(at: index)
                visited.insert(place, at: 0)
            }
            
//        } catch {
//            await revertToDefaultWithAlert(message: "Failed to load location data. Please try again.")
//            throw error
//        }
    }
    
    func delete(place: Place) {
        // Deletes the given `Place` object from the ModelContext and removes it from the `visited` array.
        context.delete(place)
        
        visited.removeAll{$0 == place}
//        if let index = visited.firstIndex(where: {$0.id == place.id}) {
//            visited.remove(at: index)
//        }
        
        // Attempts to save the context.
        
        try? context.save()
//        do {
//            try context.save()
//        } catch {
//            appError = .missingData(message: "Unabled to delete saveed places.")
//            print("Failed to save context after deleting a place: \(error)")
//        }
    }
    
}
