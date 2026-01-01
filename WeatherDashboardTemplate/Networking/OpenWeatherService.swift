//
//  OpenWeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by Shamila Ashan Gunarathna on 2025-12-27.
//

import Foundation
import CoreLocation
import MapKit

class OpenWeatherService {
    private let weatherApiKey = "0b9d7f2a9b12c8cd6ee1d3e81812031b"
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&exclude={part}&appid={weatherApiKey}"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}

class GeoCodeerService {
    private let geocoder = CLGeocoder()
    
    func fetchCoordinatesForCity(cityName: String) async throws {
        let placemark = try await geocoder.geocodeAddressString(cityName)
        
        guard let location = placemark.first?.location else {
            throw APIError.invalidResponse
        }
    }
}

class LocalSearchService {
    private let localSearch = MKLocalSearch()
    
    func fetchPlaces(query: String, near location: CLLocationCoordinate2D) async throws {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10)
    }
}
