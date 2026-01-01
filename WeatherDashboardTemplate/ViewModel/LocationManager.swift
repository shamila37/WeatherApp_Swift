//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit


@MainActor
final class LocationManager {
    
    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
        // Uses `CLGeocoder` to convert a string address into geographic coordinates.
        let geocoder = CLGeocoder()
        // Extracts the name, latitude, and longitude from the first resulting placemark.
        let placemarks = try await geocoder.geocodeAddressString(address)
        // Throws a `WeatherMapError.geocodingFailed` if no valid location can be found.
        guard let place = placemarks.first, let location = place.location else {
            throw WeatherMapError.geocodingFailed(address)
        }
        
        let name = place.locality ?? address
        return (name, location.coordinate.latitude, location.coordinate.longitude)
        
        // DUMMY RETURN TO SATISFY COMPILER
        //        preconditionFailure("Stubbed function not implemented. Requires a (name: String, lat: Double, lon: Double) return.")
    }
    
    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {
        // Uses `MKLocalSearch` to find Points of Interest (POIs), specifically "Tourist Attractions," within a small region around the given latitude and longitude.
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tourist Attractions"
        
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        // Executes the search request.
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        // Maps the `MKMapItem` results into an array of `AnnotationModel`s, filtering out any without a name.
        return response.mapItems
            .compactMap{
            guard let name = $0.name else { return nil }
            return AnnotationModel(
                name: name,
                latitude: $0.placemark.coordinate.latitude,
                longitude: $0.placemark.coordinate.longitude
            )
        }
        // Limits the final array size to the specified `limit`.
        .prefix(limit)
        .map { $0 }
        
        // DUMMY RETURN TO SATISFY COMPILER
        //        preconditionFailure("Stubbed function not implemented. Requires a [AnnotationModel] return.")
    }
    
}
